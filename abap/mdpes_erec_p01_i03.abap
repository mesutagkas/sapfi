*&---------------------------------------------------------------------*
*& Include /MDPES/EREC_P01_I03
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
        IMPORTING formn         TYPE zem_t003-formn
        RETURNING VALUE(result) TYPE ty_form_key,

      " ZEM_T008'de ilgili formn için en son seqno'lu login/guid bilgisini okur
      get_login_info
        IMPORTING formn         TYPE zem_t003-formn
        RETURNING VALUE(result) TYPE ty_login_info,

      " ZEM_T010'da ilgili formn için en son seqno'lu partner numarasını okur
      get_partner_number
        IMPORTING formn         TYPE zem_t003-formn
        RETURNING VALUE(result) TYPE zem_t010-parnr,

      " ZEM_F002_02 çağrısı ile form/gönderen/alıcı/tahsilat/değişiklik/hesap bilgilerini getirir
      get_form_details
        IMPORTING form_key      TYPE ty_form_key
                  login_info    TYPE ty_login_info
                  partner_no    TYPE zem_t010-parnr
        EXPORTING minfo         TYPE ty_minfo
                  sender_info   TYPE ty_senderinfo
                  receiver_info TYPE ty_receiverinfo
                  recdt         TYPE ty_t_recdt
                  change_list   TYPE zchange_list_tt
                  accno         TYPE ty_accno
                  subrc         TYPE sy-subrc,

      " Tahsilat listesindeki (recdt-nettr) tutarları toplayıp tek bir toplam döner
      calculate_total_amount
        IMPORTING recdt         TYPE ty_t_recdt
        RETURNING VALUE(result) TYPE dmbtr,

      " Adobe Form (ZEM_AF_001) job'ını açar, formu üretir, job'ı kapatır ve PDF xstring döner
      generate_pdf_form
        IMPORTING minfo         TYPE ty_minfo
                  sender_info   TYPE ty_senderinfo
                  receiver_info TYPE ty_receiverinfo
                  recdt         TYPE ty_t_recdt
                  change_list   TYPE zchange_list_tt
                  accno         TYPE ty_accno
                  total_amount  TYPE dmbtr
        RETURNING VALUE(result) TYPE xstring,

      " Üretilen PDF xstring'ini base64 string'e çevirir
      convert_pdf_to_base64
        IMPORTING pdf_data      TYPE xstring
        RETURNING VALUE(result) TYPE string,

      " ArkSigner servis kimlik bilgilerini (app_id/pass) hard-code yerine
      " uyarlama tablosundan okur
      get_arksigner_config
        RETURNING VALUE(result) TYPE ty_arksigner_config,

      " ArkSigner e-imza workflow talebini kurar, proxy üzerinden gönderir
      " ve hata mesajını (varsa) döner; başarılıysa boş string döner
      send_to_arksigner
        IMPORTING pdf_base64    TYPE string
                  signer_info   TYPE ty_signer_info
                  config        TYPE ty_arksigner_config
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
        /1bcdwb/formoutput = DATA(form_output)
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
    SELECT SINGLE app_id, app_pass, started_by
      FROM zem_t_arkcfg
      INTO CORRESPONDING FIELDS OF @result.

    IF sy-subrc <> 0.
      MESSAGE TEXT-e10 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD send_to_arksigner.
    "-----------------------------------------------------------------*
    " NOT: request/response tipleri, ArkSigner consumer proxy'sinin
    " (SPROXY ile üretilen) gerçek tipleriyle birebir aynı olmalıdır.
    " Aşağıda projede üretildiği varsayılan proxy sınıf/tip adları
    " kullanılmıştır - gerçek üretilmiş adlarla teyit edilip
    " gerekirse düzeltilmelidir.
    "-----------------------------------------------------------------*
    DATA request  TYPE zco_si_sap_to_3rd_arksinger_mutaba=>output.
    DATA response TYPE zco_si_sap_to_3rd_arksinger_mutaba=>input.

    DATA(config_line) = VALUE zsi_arksigner_config(
      app_id = config-app_id
      pass   = config-app_pass ).

    DATA(document_line) = VALUE zsi_arksigner_document(
      name                    = |tanım : deneme|
      description             = |aciklama : deneme|
      sign_type               = 'PAdES'
      sign_validation_time    = 'EST' ).

    DATA(post_operation_line) = VALUE zsi_arksigner_post_operation(
      is_document_to_be_archived      = abap_false
      send_ftp                        = abap_false
      send_mail                       = abap_false
      save_to_folder                  = abap_false
      is_send_to_all_users_in_workfl  = abap_false
      send_to_web_service              = abap_false ).

    DATA(file_line) = VALUE zsi_arksigner_file(
      data      = pdf_base64
      file_name = 'adobe.pdf'
      file_type = '0' ).

    DATA(workflow_step_line) = VALUE zsi_arksigner_workflow_step(
      username      = ''
      name          = signer_info-name
      surname       = signer_info-surname
      idnumber      = signer_info-id_no
      email_address = signer_info-email
      order_no      = '1'
      task_type     = '0'
      worflow_step_privilege_model_l = VALUE #(
        ( workflow_privilege_type = privilege_view )
        ( workflow_privilege_type = privilege_sign ) )
      workflow_step_notification_lis = VALUE #(
        ( workflow_step_notification_typ = notification_mail )
        ( workflow_step_notification_typ = notification_sms ) ) ).

    DATA(workflow_line) = VALUE zsi_arksigner_workflow(
      workflow_started_by             = config-started_by
      send_notification_mail_to_firs  = abap_true
      add_qr                          = abap_true
      post_operation                  = VALUE #( ( post_operation_line ) )
      document_workflow               = VALUE #( ( document_line ) )
      file_list                       = VALUE #( ( file_line ) )
      workflow_step_list              = VALUE #( ( workflow_step_line ) ) ).

    request-mt_sap_arksigner_mutabakat_eim-config = VALUE #( ( config_line ) ).
    request-mt_sap_arksigner_mutabakat_eim-workflow = VALUE #( ( workflow_line ) ).

    TRY.
        DATA(proxy) = NEW zco_si_sap_to_3rd_arksinger_mutaba( ).

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
