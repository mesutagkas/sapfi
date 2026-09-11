*&---------------------------------------------------------------------*
*& Include ZEM_P022_003
*&---------------------------------------------------------------------*
*& Class Definitions
*&---------------------------------------------------------------------*

CLASS lcl_report DEFINITION.

  PUBLIC SECTION.
    METHODS:
      initialization,
      prepare_data.

  PRIVATE SECTION.
    METHODS:
      " ZEM_T003'te ilgili formn için en son seqno'lu kaydı okur
      get_form_key
        IMPORTING formn         TYPE zem_de_001
        RETURNING VALUE(result) TYPE ty_form_key,

      " ZEM_T008'de ilgili formn için en son seqno'lu login/guid bilgisini okur
      get_login_info
        IMPORTING formn         TYPE zem_de_001
        RETURNING VALUE(result) TYPE ty_login_info,

      " ZEM_T010'da ilgili formn için en son seqno'lu partner numarasını okur
      get_partner_number
        IMPORTING formn         TYPE zem_de_001
        RETURNING VALUE(result) TYPE parnr,

      " ZEM_F002_02 çağrısı ile form/gönderen/alıcı/tahsilat/değişiklik/hesap bilgilerini getirir
      get_form_details
        IMPORTING form_key      TYPE ty_form_key
                  login_info    TYPE ty_login_info
                  partner_no    TYPE parnr
        EXPORTING minfo         TYPE zem_s010
                  sender_info   TYPE zem_s008
                  receiver_info TYPE zem_s009
                  recdt         TYPE zem_tt018
                  change_list   TYPE zchange_list_tt
                  accno         TYPE zem_de_005
                  subrc         TYPE sy-subrc,

      " Tahsilat listesindeki (recdt-nettr) tutarları toplayıp tek bir toplam döner
      calculate_total_amount
        IMPORTING recdt         TYPE zem_tt018
        RETURNING VALUE(result) TYPE dmbtr,

      " Adobe Form (ZEM_AF_001) job'ını açar, formu üretir, job'ı kapatır ve PDF xstring döner
      generate_pdf_form
        IMPORTING minfo         TYPE zem_s010
                  sender_info   TYPE zem_s008
                  receiver_info TYPE zem_s009
                  recdt         TYPE zem_tt018
                  change_list   TYPE zchange_list_tt
                  accno         TYPE zem_de_005
                  total_amount  TYPE dmbtr
        RETURNING VALUE(result) TYPE xstring,

      " Üretilen PDF xstring'ini base64 string'e çevirir
      convert_pdf_to_base64
        IMPORTING pdf_data      TYPE xstring
        RETURNING VALUE(result) TYPE string,

      " ArkSigner servis kimlik bilgilerini (app_id/pass) hard-code yerine
      " uyarlama tablosundan okur
      get_arksigner_config
        RETURNING VALUE(result) TYPE zeho_arksingerdt_sap_arksigne9,

      " ArkSigner e-imza workflow talebini kurar, proxy üzerinden gönderir
      " ve hata mesajını (varsa) döner; başarılıysa boş string döner
      send_to_arksigner
        IMPORTING pdf_base64    TYPE string
                  signer_info   TYPE ty_signer_info
                  started_by    TYPE string
                  config        TYPE zeho_arksingerdt_sap_arksigne9
        RETURNING VALUE(result) TYPE string.

ENDCLASS.


CLASS lcl_report IMPLEMENTATION.

  METHOD initialization.
    " Başlangıç değerlerini ata (gerekli değilse boş bırakılabilir)
  ENDMETHOD.

  METHOD prepare_data.
    DATA(form_key)   = get_form_key( p_formn ).
    DATA(login_info) = get_login_info( p_formn ).
    DATA(partner_no) = get_partner_number( p_formn ).

    get_form_details(
      EXPORTING
        form_key      = form_key
        login_info    = login_info
        partner_no    = partner_no
      IMPORTING
        minfo         = DATA(minfo)
        sender_info   = DATA(sender_info)
        receiver_info = DATA(receiver_info)
        recdt         = DATA(recdt)
        change_list   = DATA(change_list)
        accno         = DATA(accno)
        subrc         = DATA(form_subrc) ).

    IF form_subrc <> 0.
      MESSAGE TEXT-e01 TYPE 'E'.
    ENDIF.

    DATA(total_amount) = calculate_total_amount( recdt ).

    DATA(pdf_data) = generate_pdf_form(
      minfo         = minfo
      sender_info   = sender_info
      receiver_info = receiver_info
      recdt         = recdt
      change_list   = change_list
      accno         = accno
      total_amount  = total_amount ).

    DATA(pdf_base64) = convert_pdf_to_base64( pdf_data ).

    DATA(signer_info) = VALUE ty_signer_info(
      name    = p_name
      surname = p_surn
      id_no   = p_idnr
      email   = p_email ).

    DATA(config) = get_arksigner_config( ).

    DATA(error_description) = send_to_arksigner(
      pdf_base64  = pdf_base64
      signer_info = signer_info
      started_by  = p_stdby
      config      = config ).

    IF error_description IS NOT INITIAL.
      MESSAGE error_description TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD get_form_key.
    SELECT SINGLE formn, seqno
      FROM zem_t003
      INTO CORRESPONDING FIELDS OF @result
      WHERE formn = @formn
        AND seqno = ( SELECT MAX( seqno ) FROM zem_t003 WHERE formn = @formn ).

    IF sy-subrc <> 0.
      MESSAGE TEXT-e02 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD get_login_info.
    SELECT SINGLE lgnid, guuid
      FROM zem_t008
      INTO CORRESPONDING FIELDS OF @result
      WHERE formn = @formn
        AND seqno = ( SELECT MAX( seqno ) FROM zem_t008 WHERE formn = @formn ).

    IF sy-subrc <> 0.
      MESSAGE TEXT-e03 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD get_partner_number.
    SELECT SINGLE parnr
      FROM zem_t010
      INTO @result
      WHERE formn = @formn
        AND seqno = ( SELECT MAX( seqno ) FROM zem_t010 WHERE formn = @formn ).

    IF sy-subrc <> 0.
      MESSAGE TEXT-e04 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD get_form_details.
    CALL FUNCTION 'ZEM_F002_02'
      EXPORTING
        formn      = form_key-formn
        guid       = login_info-guid
        loginid    = login_info-login_id
        parnr      = partner_no
        seqno      = form_key-seqno
        i_form_pdf = abap_true
      IMPORTING
        minfo        = minfo
        senderinfo   = sender_info
        receiverinfo = receiver_info
        recdt        = recdt
        e_change     = change_list
        accno        = accno
        subrc        = subrc.
  ENDMETHOD.

  METHOD calculate_total_amount.
    LOOP AT recdt INTO DATA(recdt_line).
      DATA(amount_text) = CONV string( recdt_line-nettr ).
      CONDENSE amount_text NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN amount_text WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN amount_text WITH '.'.

      result = result + CONV dmbtr( amount_text ).
    ENDLOOP.
  ENDMETHOD.

  METHOD generate_pdf_form.
    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = adobe_form_name
      IMPORTING
        e_funcname = DATA(function_name).

    DATA outputparams TYPE sfpoutputparams.

    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.

    IF sy-subrc <> 0.
      MESSAGE TEXT-e05 TYPE 'E'.
    ENDIF.

    " Not: function_name runtime'da belirlendiği için (dinamik çağrı),
    " burada inline DATA(...) bildirimi kullanılamaz - arayüz compile
    " time'da bilinmiyor. Bu yüzden form_output önceden tanımlanır.
    DATA form_output TYPE fpformoutput.

    CALL FUNCTION function_name
      EXPORTING
        /1bcdwb/docparams = VALUE sfpdocparams( )
        minfo             = minfo
        senderinfo        = sender_info
        receiverinfo      = receiver_info
        rcdt              = recdt
        change_list       = change_list
        accno             = accno
        datum             = sy-datum
        toplam            = total_amount
        uzeit             = sy-uzeit
      IMPORTING
        /1bcdwb/formoutput = form_output
      EXCEPTIONS
        usage_error       = 1
        system_error      = 2
        internal_error    = 3
        OTHERS            = 4.

    IF sy-subrc <> 0.
      MESSAGE TEXT-e06 TYPE 'E'.
    ENDIF.

    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error     = 1
        system_error    = 2
        internal_error  = 3
        OTHERS          = 4.

    IF sy-subrc <> 0.
      MESSAGE TEXT-e07 TYPE 'E'.
    ENDIF.

    result = form_output-pdf.

    IF result IS INITIAL.
      MESSAGE TEXT-e08 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD convert_pdf_to_base64.
    CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
      EXPORTING
        input  = pdf_data
      IMPORTING
        output = result.

    IF result IS INITIAL.
      MESSAGE TEXT-e09 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD get_arksigner_config.
    "-----------------------------------------------------------------*
    " *- app_id/pass artık program içinde hard-code tutulmuyor, bir
    " *- uyarlama (Z) tablosundan okunuyor. ZEM_T_ARKCFG bu amaçla
    " *- oluşturulması gereken varsayımsal bir tablo adıdır - gerçek
    " *- sistemde mevcut bir uyarlama tablosuyla değiştirilmelidir.
    " *- added by markus.abap 11.09.2026
    "-----------------------------------------------------------------*
    SELECT SINGLE app_id, pass
      FROM zem_t_arkcfg
      INTO CORRESPONDING FIELDS OF @result.

    IF sy-subrc <> 0.
      MESSAGE TEXT-e10 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD send_to_arksigner.
    DATA request  TYPE zeho_arksingermt_sap_arksigne1.
    DATA response TYPE zeho_arksingermt_sap_arksigner.

    DATA(document_line) = VALUE zeho_arksingerdt_sap_arksigne6(
      name                 = 'tanım : deneme'
      description          = 'aciklama : deneme'
      sign_type            = sign_type_pades
      sign_validation_time = sign_validation_est ).

    DATA(post_operation_line) = VALUE zeho_arksingerdt_sap_arksigne4(
      is_document_to_be_archived     = arksigner_flag_false
      send_ftp                       = arksigner_flag_false
      send_mail                      = arksigner_flag_false
      save_to_folder                 = arksigner_flag_false
      is_send_to_all_users_in_workfl = arksigner_flag_false
      send_to_web_service            = arksigner_flag_false ).

    DATA(file_line) = VALUE zeho_arksingerdt_sap_arksigne5(
      data      = pdf_base64
      file_name = file_name_pdf
      file_type = file_type_pdf ).

    DATA(workflow_step_line) = VALUE zeho_arksingerdt_sap_arksigne1(
      username      = ''
      name          = signer_info-name
      surname       = signer_info-surname
      idnumber      = signer_info-id_no
      email_address = signer_info-email
      order_no      = workflow_order_first
      task_type     = workflow_task_type_sign
      worflow_step_privilege_model_l = VALUE #(
        ( workflow_privilege_type = privilege_view )
        ( workflow_privilege_type = privilege_sign ) )
      workflow_step_notification_lis = VALUE #(
        ( workflow_step_notification_typ = notification_mail )
        ( workflow_step_notification_typ = notification_sms ) ) ).

    DATA(workflow_line) = VALUE zeho_arksingerdt_sap_arksigne2(
      workflow_started_by            = started_by
      send_notification_mail_to_firs = arksigner_flag_true
      add_qr                         = arksigner_flag_true
      post_operation                 = VALUE #( ( post_operation_line ) )
      document_workflow              = VALUE #( ( document_line ) )
      file_list                      = VALUE #( ( file_line ) )
      workflow_step_list             = VALUE #( ( workflow_step_line ) ) ).

    APPEND config TO request-mt_sap_arksigner_mutabakat_eim-config.
    APPEND workflow_line TO request-mt_sap_arksigner_mutabakat_eim-workflow.

    TRY.
        DATA(proxy) = NEW zeho_arksingerco_si_sap_to_3rd( ).

        proxy->si_sap_to_3rd_arksinger_mutaba(
          EXPORTING
            output = request
          IMPORTING
            input  = response ).

      CATCH cx_ai_system_fault INTO DATA(system_fault).
        result = system_fault->errortext.

      CATCH cx_ai_application_fault INTO DATA(application_fault).
        result = application_fault->get_text( ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
