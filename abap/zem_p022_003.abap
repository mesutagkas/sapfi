*&---------------------------------------------------------------------*
*& Include ZEM_P022_003
*&---------------------------------------------------------------------*
*& Class Definitions
*&---------------------------------------------------------------------*

CLASS lcl_report DEFINITION.

  PUBLIC SECTION.
    METHODS:
      initialization,
      prepare_data,

      " P_FORMN için F4 (arama yardımı): ZEM_T010'daki form kayıtlarını
      " listeler, seçilen form numarasını P_FORMN'a yazar.
      f4_help_for_form
        IMPORTING retfield TYPE dfies-fieldname DEFAULT 'FORMN',

      " P_SNAME/P_SSURN/P_SEMAIL alanlarının HERHANGİ BİRİNDEN tetiklenebilen
      " F4: müşteri master'ındaki "E Mutabakat Yetkilisi" ilgili kişilerini
      " (KNVK, PAFKT = 99) ve e-posta adreslerini (ADR6) listeler, seçilen
      " kişinin ad/soyad/e-posta bilgisini ekrandaki ÜÇ alana birden yazar.
      f4_help_for_signer
        IMPORTING retfield TYPE dfies-fieldname DEFAULT 'NAMEV'.

  PRIVATE SECTION.
    METHODS:
      " ZEM_T003'te ilgili form_number için en son seqno'lu kaydı okur
      " Not: parametre bilerek "formn" değil "form_number" olarak adlandırıldı -
      " klasik (non-@) Open SQL'de yerel değişken adı tablo alanıyla (formn)
      " aynı olursa alan referansı önceliklidir ve WHERE formn = formn gibi
      " her zaman doğru olan (yanlış) bir koşula dönüşür.
      get_form_key
        IMPORTING form_number   TYPE zem_de_001
        RETURNING VALUE(result) TYPE ty_form_key,

      " ZEM_T008'de ilgili form_number için en son seqno'lu login/guid bilgisini okur
      get_login_info
        IMPORTING form_number   TYPE zem_de_001
        RETURNING VALUE(result) TYPE ty_login_info,

      " ZEM_T010'da ilgili form_number için en son seqno'lu partner numarasını okur
      get_partner_number
        IMPORTING form_number   TYPE zem_de_001
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

  METHOD f4_help_for_form.
    DATA search_help_list TYPE ty_t_form_search_help.
    DATA return_tab       TYPE STANDARD TABLE OF ddshretval.
    DATA return_line      LIKE LINE OF return_tab.
    DATA dynpfields       TYPE STANDARD TABLE OF dynpread.
    DATA dynpfield        LIKE LINE OF dynpfields.

    SELECT formn accno
      INTO CORRESPONDING FIELDS OF TABLE search_help_list
      FROM zem_t010
      ORDER BY formn.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = retfield
        value_org       = 'S'
      TABLES
        value_tab       = search_help_list
        return_tab      = return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    READ TABLE return_tab INTO return_line INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Test doğruladı: DYNP_VALUES_UPDATE ile elle yazdığımız alan HER ZAMAN
    " doluyor; F4'ün "tetikleyen alanı kendiliğinden doldurma" standart
    " davranışı bu (class method içinden çağrılan) senaryoda ÇALIŞMIYOR.
    " Bu yüzden tetikleyen alan (P_FORMN) da dahil olmak üzere elle yazıyoruz.
    dynpfield-fieldname  = 'P_FORMN'.
    dynpfield-fieldvalue = return_line-fieldval.
    APPEND dynpfield TO dynpfields.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-repid
        dynumb     = sy-dynnr
      TABLES
        dynpfields = dynpfields.
  ENDMETHOD.

  METHOD f4_help_for_signer.
    DATA search_help_list TYPE ty_t_signer_search_help.
    DATA selected_row     TYPE ty_signer_search_help.
    DATA return_tab       TYPE STANDARD TABLE OF ddshretval.
    DATA return_line      LIKE LINE OF return_tab.
    DATA dynpfields       TYPE STANDARD TABLE OF dynpread.
    DATA dynpfield        LIKE LINE OF dynpfields.

    " KNVK: müşteri master'ındaki ilgili kişiler (contact person).
    " PAFKT = '99' = "E Mutabakat Yetkilisi" partner fonksiyonu.
    " ADR6: kişinin e-posta adresi, KNVK-PRSNR = ADR6-PERSNUMBER ile eşleşir.
    SELECT knvk~kunnr knvk~prsnr knvk~namev knvk~name1
           adr6~smtp_addr AS email
      INTO CORRESPONDING FIELDS OF TABLE search_help_list
      FROM knvk
      INNER JOIN adr6 ON adr6~persnumber = knvk~prsnr
      WHERE knvk~pafkt = signer_partner_function
      ORDER BY knvk~kunnr.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = retfield
        value_org       = 'S'
      TABLES
        value_tab       = search_help_list
        return_tab      = return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    READ TABLE return_tab INTO return_line INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CASE retfield.
      WHEN 'NAME1'.
        READ TABLE search_help_list INTO selected_row
          WITH KEY name1 = return_line-fieldval.
      WHEN 'EMAIL'.
        READ TABLE search_help_list INTO selected_row
          WITH KEY email = return_line-fieldval.
      WHEN OTHERS.
        READ TABLE search_help_list INTO selected_row
          WITH KEY namev = return_line-fieldval.
    ENDCASE.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    dynpfield-fieldname  = 'P_SNAME'.
    dynpfield-fieldvalue = selected_row-namev.
    APPEND dynpfield TO dynpfields.
    CLEAR dynpfield.

    dynpfield-fieldname  = 'P_SSURN'.
    dynpfield-fieldvalue = selected_row-name1.
    APPEND dynpfield TO dynpfields.
    CLEAR dynpfield.

    dynpfield-fieldname  = 'P_SEMAIL'.
    dynpfield-fieldvalue = selected_row-email.
    APPEND dynpfield TO dynpfields.
    CLEAR dynpfield.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-repid
        dynumb     = sy-dynnr
      TABLES
        dynpfields = dynpfields.
  ENDMETHOD.

  METHOD prepare_data.
    " Not: eski/düşük ABAP sürümleriyle uyumluluk için inline DATA(...)
    " bildirimleri yerine klasik DATA tanımları kullanılıyor.
    DATA form_key          TYPE ty_form_key.
    DATA login_info        TYPE ty_login_info.
    DATA partner_no        TYPE parnr.
    DATA minfo             TYPE zem_s010.
    DATA sender_info       TYPE zem_s008.
    DATA receiver_info     TYPE zem_s009.
    DATA recdt             TYPE zem_tt018.
    DATA change_list       TYPE zchange_list_tt.
    DATA accno             TYPE zem_de_005.
    DATA form_subrc        TYPE sy-subrc.
    DATA total_amount      TYPE dmbtr.
    DATA pdf_data          TYPE xstring.
    DATA pdf_base64        TYPE string.
    DATA signer_info       TYPE ty_signer_info.
    DATA config            TYPE zeho_arksingerdt_sap_arksigne9.
    DATA error_description TYPE string.

    form_key   = get_form_key( p_formn ).
    login_info = get_login_info( p_formn ).
    partner_no = get_partner_number( p_formn ).

    get_form_details(
      EXPORTING
        form_key      = form_key
        login_info    = login_info
        partner_no    = partner_no
      IMPORTING
        minfo         = minfo
        sender_info   = sender_info
        receiver_info = receiver_info
        recdt         = recdt
        change_list   = change_list
        accno         = accno
        subrc         = form_subrc ).

    IF form_subrc <> 0.
      MESSAGE TEXT-e01 TYPE 'E'.
    ENDIF.

    total_amount = calculate_total_amount( recdt ).

    pdf_data = generate_pdf_form(
      minfo         = minfo
      sender_info   = sender_info
      receiver_info = receiver_info
      recdt         = recdt
      change_list   = change_list
      accno         = accno
      total_amount  = total_amount ).

    pdf_base64 = convert_pdf_to_base64( pdf_data ).

    signer_info-name    = p_sname.
    signer_info-surname = p_ssurn.
    signer_info-id_no   = p_sidnr.
    signer_info-email   = p_semail.

    config = get_arksigner_config( ).

    error_description = send_to_arksigner(
      pdf_base64  = pdf_base64
      signer_info = signer_info
      started_by  = p_stdby
      config      = config ).

    IF error_description IS NOT INITIAL.
      MESSAGE error_description TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD get_form_key.
    SELECT SINGLE formn seqno
      INTO (result-formn, result-seqno)
      FROM zem_t003
      WHERE formn = form_number
        AND seqno = ( SELECT MAX( seqno ) FROM zem_t003 WHERE formn = form_number ).

    IF sy-subrc <> 0.
      MESSAGE TEXT-e02 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD get_login_info.
    SELECT SINGLE lgnid guuid
      INTO (result-login_id, result-guid)
      FROM zem_t008
      WHERE formn = form_number
        AND seqno = ( SELECT MAX( seqno ) FROM zem_t008 WHERE formn = form_number ).

    IF sy-subrc <> 0.
      MESSAGE TEXT-e03 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD get_partner_number.
    SELECT SINGLE parnr
      INTO result
      FROM zem_t010
      WHERE formn = form_number
        AND seqno = ( SELECT MAX( seqno ) FROM zem_t010 WHERE formn = form_number ).

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
    DATA recdt_line  LIKE LINE OF recdt.
    DATA amount_text TYPE string.
    DATA amount      TYPE dmbtr.

    LOOP AT recdt INTO recdt_line.
      amount_text = recdt_line-nettr.
      CONDENSE amount_text NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN amount_text WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN amount_text WITH '.'.

      amount = amount_text.
      result = result + amount.
    ENDLOOP.
  ENDMETHOD.

  METHOD generate_pdf_form.
    DATA function_name TYPE rs38l_fnam.
    DATA outputparams  TYPE sfpoutputparams.
    DATA docparams     TYPE sfpdocparams.
    DATA form_output   TYPE fpformoutput.
    DATA fp_error      TYPE REF TO cx_fp_api.
    DATA error_text    TYPE string.
    DATA form_subrc    TYPE sy-subrc.
    DATA close_subrc   TYPE sy-subrc.

    " Form adından üretilen fonksiyon modülünün adını al
    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = adobe_form_name
          IMPORTING
            e_funcname = function_name.
      CATCH cx_fp_api INTO fp_error.
        error_text = fp_error->get_text( ).
        MESSAGE error_text TYPE 'E'.
    ENDTRY.

    " PDF'i xstring olarak üret (nodialog/getpdf) ve aynı zamanda ekranda
    " önizleme penceresinde göster (preview) - ArkSigner'a göndermeden
    " önce görsel kontrol yapılabilsin diye.
    outputparams-nodialog = abap_true.
    outputparams-getpdf   = abap_true.
    outputparams-preview  = abap_true.

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

    docparams-langu = sy-langu.

    CALL FUNCTION function_name
      EXPORTING
        /1bcdwb/docparams  = docparams
        minfo              = minfo
        senderinfo         = sender_info
        receiverinfo       = receiver_info
        rcdt               = recdt
        change_list        = change_list
        accno              = accno
        datum              = sy-datum
        toplam             = total_amount
        uzeit              = sy-uzeit
      IMPORTING
        /1bcdwb/formoutput = form_output
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS              = 4.

    form_subrc = sy-subrc.

    " Form çağrısı hata verse de job her durumda kapatılır
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.

    close_subrc = sy-subrc.

    IF form_subrc <> 0.
      MESSAGE TEXT-e06 TYPE 'E'.
    ENDIF.

    IF close_subrc <> 0.
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
    SELECT SINGLE app_id pass
      INTO (result-app_id, result-pass)
      FROM zem_t_arkcfg.

    IF sy-subrc <> 0.
      MESSAGE TEXT-e10 TYPE 'E'.
    ENDIF.

    " ZEM_T_ARKCFG-APP_ID/PASS sabit uzunluklu CHAR; result-app_id/pass ise
    " proxy'nin STRING tipindeki alanları. CHAR -> STRING aktarımında sona
    " dolan boşluklar KIRPILMAZ ve STRING'in bir parçası olarak kalır - bu
    " da XML/JSON'a gönderilen Pass/AppId değerinin sonunda görünmez
    " boşluklar olmasına, dolayısıyla servisin "kullanıcı validate
    " edilemedi" demesine yol açar. Burada açıkça kırpıyoruz.
    CONDENSE result-app_id.
    CONDENSE result-pass.
  ENDMETHOD.

  METHOD send_to_arksigner.
    DATA request            TYPE zeho_arksingermt_sap_arksigne1.
    DATA response            TYPE zeho_arksingermt_sap_arksigner.
    DATA document_line       TYPE zeho_arksingerdt_sap_arksigne6.
    DATA post_operation_line TYPE zeho_arksingerdt_sap_arksigne4.
    DATA file_line           TYPE zeho_arksingerdt_sap_arksigne5.
    DATA workflow_step_line  TYPE zeho_arksingerdt_sap_arksigne1.
    DATA workflow_line       TYPE zeho_arksingerdt_sap_arksigne2.
    DATA notification_line   TYPE zeho_arksingerdt_sap_arksigner.
    DATA privilege_line      TYPE zeho_arksingerdt_sap_arksigne3.
    DATA proxy               TYPE REF TO zeho_arksingerco_si_sap_to_3rd.
    DATA system_fault        TYPE REF TO cx_ai_system_fault.
    DATA application_fault   TYPE REF TO cx_ai_application_fault.

    document_line-name                 = 'tanım : deneme'.
    document_line-description          = 'aciklama : deneme'.
    document_line-sign_type            = sign_type_pades.
    document_line-sign_validation_time = sign_validation_est.

    post_operation_line-is_document_to_be_archived     = arksigner_flag_false.
    post_operation_line-send_ftp                       = arksigner_flag_false.
    post_operation_line-send_mail                      = arksigner_flag_false.
    post_operation_line-save_to_folder                 = arksigner_flag_false.
    post_operation_line-is_send_to_all_users_in_workfl = arksigner_flag_false.
    post_operation_line-send_to_web_service             = arksigner_flag_false.

    file_line-data      = pdf_base64.
    file_line-file_name = file_name_pdf.
    file_line-file_type = file_type_pdf.

    workflow_step_line-username      = ''.
    workflow_step_line-name          = signer_info-name.
    workflow_step_line-surname       = signer_info-surname.
    workflow_step_line-idnumber      = signer_info-id_no.
    workflow_step_line-email_address = signer_info-email.
    workflow_step_line-order_no      = workflow_order_first.
    workflow_step_line-task_type     = workflow_task_type_sign.

    notification_line-workflow_step_notification_typ = notification_mail.
    APPEND notification_line TO workflow_step_line-workflow_step_notification_lis.
    CLEAR notification_line.
    notification_line-workflow_step_notification_typ = notification_sms.
    APPEND notification_line TO workflow_step_line-workflow_step_notification_lis.
    CLEAR notification_line.

    privilege_line-workflow_privilege_type = privilege_view.
    APPEND privilege_line TO workflow_step_line-worflow_step_privilege_model_l.
    CLEAR privilege_line.
    privilege_line-workflow_privilege_type = privilege_sign.
    APPEND privilege_line TO workflow_step_line-worflow_step_privilege_model_l.
    CLEAR privilege_line.

    workflow_line-workflow_started_by            = started_by.
    workflow_line-send_notification_mail_to_firs = arksigner_flag_true.
    workflow_line-add_qr                         = arksigner_flag_true.

    APPEND post_operation_line TO workflow_line-post_operation.
    APPEND document_line       TO workflow_line-document_workflow.
    APPEND file_line           TO workflow_line-file_list.
    APPEND workflow_step_line  TO workflow_line-workflow_step_list.

    APPEND config        TO request-mt_sap_arksigner_mutabakat_eim-config.
    APPEND workflow_line TO request-mt_sap_arksigner_mutabakat_eim-workflow.

    TRY.
        CREATE OBJECT proxy.

        proxy->si_sap_to_3rd_arksinger_mutaba(
          EXPORTING
            output = request
          IMPORTING
            input  = response ).

      CATCH cx_ai_system_fault INTO system_fault.
        result = system_fault->errortext.

      CATCH cx_ai_application_fault INTO application_fault.
        result = application_fault->get_text( ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
