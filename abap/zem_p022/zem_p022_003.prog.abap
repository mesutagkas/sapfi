*&---------------------------------------------------------------------*
*& Include ZEM_P022_003
*&---------------------------------------------------------------------*
*& Class Definitions / Implementations
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcx_eimza_error DEFINITION
*----------------------------------------------------------------------*
* Form bazlı hata: job'ı durdurmadan ilgili forma statü 3 yazdırır
*----------------------------------------------------------------------*
class lcx_eimza_error definition inheriting from cx_static_check.

  public section.
    data error_text type string read-only.

    methods constructor
      importing error_text type csequence optional.

endclass.                    "lcx_eimza_error DEFINITION

class lcx_eimza_error implementation.

  method constructor.
    super->constructor( ).
    me->error_text = error_text.
  endmethod.                    "constructor

endclass.                    "lcx_eimza_error IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS lcl_report DEFINITION
*----------------------------------------------------------------------*
class lcl_report definition.

  public section.
    methods:
      initialization,

      " P_SEND: onaylanan formları ArkSigner'a gönderir
      " P_CHECK: gönderilmiş formların e-imza sonucunu sorgular
      prepare_data,

      " İşlenen formların sonucunu listeler (job'da spool'a düşer)
      display_output,

      " S_FORMN için F4: ZEM_T010'daki e-imza bekleyen form numaralarını listeler
      f4_help_for_form
        importing field_name type dynfnam.


  private section.
    data:
      " ArkSigner kimlik bilgileri ve iş akışını başlatan kullanıcı
      m_config type zem_t017_eimza,
      " Job sonuç listesi
      m_output type ty_t_output,
      " ArkSigner durum metni → EIMZA eşlemesi (ZEM_T018_EIMZA)
      m_status_map type sorted table of zem_t018_eimza with unique key dtext.

    methods:
      " Gönderim adımı: EIMZA = 2 (P_RETRY ile 3) formları ArkSigner'a gönderir
      send_forms,

      " Takip adımı: gönderilmiş formların e-imza sonucunu sorgulayıp 4 / 5 yazar
      check_statuses,

      " Tek bir formun durumunu sorgular ve sonuç kesinleştiyse statüyü günceller
      process_status
        importing tracked_form type ty_tracked_form,

      " ArkSigner GetStatus çağrısı (PI proxy)
      call_get_status
        importing workflow_key  type sysuuid_c36
        returning value(result) type ty_status_result,

      " Takip sonucunu ZEM_T016_EIMZA'ya, kesinleştiyse ZEM_T010-EIMZA'ya yazar
      save_status_result
        importing tracked_form type ty_tracked_form
                  new_status   type zem_de_210
                  message_text type csequence,

      " ZEM_T010'dan gönderilecek formları seçer: EIMZA = 2 (P_RETRY ile 3)
      " olup ZEM_T016_EIMZA'da workflowKey'i olmayanlar
      get_forms_to_send
        returning value(result) type ty_t_eimza_form,

      " Tek bir formu PDF'leyip gönderir ve sonucu kaydeder; hata olursa
      " yalnızca bu form statü 3 alır, job sonraki formla devam eder
      process_form
        importing form type ty_eimza_form,

      " Form detaylarını okuyup Adobe Form PDF'ini base64 olarak döner
      build_pdf_base64
        importing form          type ty_eimza_form
        returning value(result) type string
        raising   lcx_eimza_error,

      " Carinin imzacısını (KNVK işlev 99 + ADR6 e-posta) okur
      " Not: İmzacı kaynağı (KNVK / ZEM_T015_EIMZA) henüz kesinleşmedi;
      " kaynak değişirse yalnızca bu metot değişir
      get_signer_info
        importing form          type ty_eimza_form
        returning value(result) type ty_signer_info
        raising   lcx_eimza_error,

      " ZEM_T003'te ilgili form için en son seqno'lu kaydı okur
      " Not: parametre bilerek "formn" değil "form_number" olarak adlandırıldı -
      " klasik Open SQL'de yerel değişken adı tablo alanıyla aynı olursa
      " WHERE formn = formn her zaman doğru olan bir koşula dönüşür.
      get_form_key
        importing form_number   type zem_de_001
        returning value(result) type ty_form_key
        raising   lcx_eimza_error,

      " ZEM_T008'de ilgili form için en son seqno'lu login/guid bilgisini okur
      get_login_info
        importing form_number   type zem_de_001
        returning value(result) type ty_login_info
        raising   lcx_eimza_error,

      " ZEM_T010'da ilgili form için en son seqno'lu partner numarasını okur
      get_partner_number
        importing form_number   type zem_de_001
        returning value(result) type parnr
        raising   lcx_eimza_error,

      " ZEM_F002_02 ile form/gönderen/alıcı/tahsilat/değişiklik/hesap bilgilerini getirir
      get_form_details
        importing form_key      type ty_form_key
                  login_info    type ty_login_info
                  partner_no    type parnr
        exporting minfo         type zem_s010
                  sender_info   type zem_s008
                  receiver_info type zem_s009
                  recdt         type zem_tt018
                  change_list   type zchange_list_tt
                  accno         type zem_de_005
                  subrc         type sy-subrc,

      " Tahsilat listesindeki (recdt-nettr) tutarları toplar
      calculate_total_amount
        importing recdt         type zem_tt018
        returning value(result) type dmbtr
        raising   lcx_eimza_error,

      " Kullanıcının varsayılan çıktı cihazını (SU3) okur, yoksa sabiti döner
      get_output_device
        returning value(result) type rspopname,

      " Adobe Form'u çalıştırıp PDF'i xstring olarak döner
      generate_pdf_form
        importing minfo         type zem_s010
                  sender_info   type zem_s008
                  receiver_info type zem_s009
                  recdt         type zem_tt018
                  change_list   type zchange_list_tt
                  accno         type zem_de_005
                  total_amount  type dmbtr
        returning value(result) type xstring
        raising   lcx_eimza_error,

      " PDF xstring'ini base64 string'e çevirir
      convert_pdf_to_base64
        importing pdf_data      type xstring
        returning value(result) type string
        raising   lcx_eimza_error,

      " ArkSigner servis kimlik bilgilerini (app_id/pass) ZEM_T017_EIMZA'dan döner
      get_arksigner_config
        returning value(result) type zeho_arksingerdt_sap_arksigne9,

      " ArkSigner e-imza workflow talebini kurar, proxy üzerinden gönderir ve
      " yanıtı kontrol eder; başarılıysa workflowKey, değilse hata metni döner
      send_to_arksigner
        importing form_number   type zem_de_001
                  pdf_base64    type string
                  signer_info   type ty_signer_info
        returning value(result) type ty_send_result,

      " Gönderim sonucunu ZEM_T016_EIMZA'ya ve ZEM_T010-EIMZA'ya yazar
      save_send_result
        importing form        type ty_eimza_form
                  send_result type ty_send_result.

endclass.                    "lcl_report DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_report implementation.

  method initialization.
    " Başlangıç değerleri gerekmiyor
  endmethod.                    "initialization

  method f4_help_for_form.
    data search_help_list type ty_t_form_search_help.
    data selected_row     type ty_form_search_help.
    data return_tab       type standard table of ddshretval.
    data return_line      like line of return_tab.
    data dynpfields       type standard table of dynpread.
    data dynpfield        like line of dynpfields.

    " Yalnızca job'ın işleyebileceği formlar listelenir
    select formn accno
      into corresponding fields of table search_help_list
      from zem_t010
      where eimza = eimza_sent
         or eimza = eimza_error.

    " Aynı form birden fazla seqno ile tutulduğu için tekilleştirilir
    sort search_help_list by formn.
    delete adjacent duplicates from search_help_list comparing formn.

    call function 'F4IF_INT_TABLE_VALUE_REQUEST'
      exporting
        retfield        = 'FORMN'
        value_org       = 'S'
      tables
        value_tab       = search_help_list
        return_tab      = return_tab
      exceptions
        parameter_error = 1
        no_values_found = 2
        others          = 3.

    if sy-subrc <> 0.
      return.
    endif.

    read table return_tab into return_line index 1.
    if sy-subrc <> 0.
      return.
    endif.

    read table search_help_list into selected_row
      with key formn = return_line-fieldval.
    if sy-subrc <> 0.
      return.
    endif.

    " F4'ün tetikleyen alanı kendiliğinden doldurma davranışı class
    " method içinden çağrıldığında çalışmadığı için alan elle yazılır
    dynpfield-fieldname  = field_name.
    dynpfield-fieldvalue = selected_row-formn.
    append dynpfield to dynpfields.

    call function 'DYNP_VALUES_UPDATE'
      exporting
        dyname     = sy-repid
        dynumb     = sy-dynnr
      tables
        dynpfields = dynpfields.
  endmethod.                    "f4_help_for_form

  method prepare_data.
    select single * from zem_t017_eimza into m_config.
    if sy-subrc <> 0.
      message text-e10 type 'E'.
    endif.

    if p_send = abap_true.
      send_forms( ).
    endif.

    if p_check = abap_true.
      check_statuses( ).
    endif.
  endmethod.                    "prepare_data

  method send_forms.
    data forms type ty_t_eimza_form.
    data form  type ty_eimza_form.

    forms = get_forms_to_send( ).
    if forms is initial.
      message text-i01 type 'S'.
      return.
    endif.

    loop at forms into form.
      process_form( form ).
    endloop.
  endmethod.                    "send_forms

  method check_statuses.
    data tracked_forms type ty_t_tracked_form.
    data tracked_form  type ty_tracked_form.

    select * from zem_t018_eimza into table m_status_map.
    if m_status_map is initial.
      message text-e18 type 'E'.
    endif.

    " ZEM_T016_EIMZA'daki statü job tarafından ZEM_T010 ile birlikte
    " güncellendiği için takip bu tablodan yürütülür
    select formn seqno wfkey
      into corresponding fields of table tracked_forms
      from zem_t016_eimza
      where formn in s_formn
        and eimza = eimza_sent
        and wfkey <> space.

    if tracked_forms is initial.
      message text-i02 type 'S'.
      return.
    endif.

    loop at tracked_forms into tracked_form.
      process_status( tracked_form ).
    endloop.
  endmethod.                    "check_statuses

  method process_status.
    data status_result type ty_status_result.
    data status_map    type zem_t018_eimza.
    data message_text  type string.

    status_result = call_get_status( tracked_form-wfkey ).

    " Teknik hata: statüye dokunulmaz, sonraki çalışmada tekrar sorulur
    if status_result-error_text is not initial.
      save_status_result( tracked_form = tracked_form
                          new_status   = eimza_sent
                          message_text = status_result-error_text ).
      return.
    endif.

    " İmzacı listesi döndü: iş akışı hâlâ devam ediyor
    if status_result-pending = abap_true.
      save_status_result( tracked_form = tracked_form
                          new_status   = eimza_sent
                          message_text = text-i03 ).
      return.
    endif.

    " Durum metni ZEM_T018_EIMZA'da tanımlı değilse statü değiştirilmez;
    " ArkSigner metni değiştirdiyse tabloya eklenmesi yeterli
    read table m_status_map into status_map
      with table key dtext = status_result-data_text.
    if sy-subrc <> 0.
      concatenate text-w02 status_result-data_text into message_text separated by space.
      save_status_result( tracked_form = tracked_form
                          new_status   = eimza_sent
                          message_text = message_text ).
      return.
    endif.

    save_status_result( tracked_form = tracked_form
                        new_status   = status_map-eimza
                        message_text = status_result-data_text ).
  endmethod.                    "process_status

  method call_get_status.
    " PI proxy (ZCO_SI_SAP_TO_3RD_ARKSIGNER_GE) istek/yanıt yapıları
    " netleşince doldurulacak. O zamana kadar her form için teknik hata
    " döner; statüler değişmez, gönderim adımı etkilenmez.
    result-error_text = text-e17.
  endmethod.                    "call_get_status

  method save_status_result.
    data output_line type ty_output.
    data checked_on  type sy-datum.
    data checked_at  type sy-uzeit.
    data short_text  type bapi_msg.

    checked_on = sy-datum.
    checked_at = sy-uzeit.
    short_text = message_text.

    update zem_t016_eimza
       set eimza = new_status
           ermsg = short_text
           chkdt = checked_on
           chktm = checked_at
     where formn = tracked_form-formn.

    " ZEM_T010 yalnızca sonuç kesinleştiğinde (4 / 5) güncellenir
    if new_status <> eimza_sent.
      update zem_t010 set eimza = new_status
        where formn = tracked_form-formn
          and seqno = tracked_form-seqno.
    endif.

    commit work.

    output_line-formn = tracked_form-formn.
    output_line-seqno = tracked_form-seqno.
    output_line-eimza = new_status.
    output_line-wfkey = tracked_form-wfkey.
    output_line-ermsg = short_text.
    append output_line to m_output.
  endmethod.                    "save_status_result

  method get_forms_to_send.
    data status_range type range of zem_de_210.
    data status_line  like line of status_range.
    data sent_forms   type standard table of zem_de_001 with default key.
    data form         type ty_eimza_form.
    data form_index   type sy-tabix.

    status_line-sign   = 'I'.
    status_line-option = 'EQ'.
    status_line-low    = eimza_sent.
    append status_line to status_range.

    if p_retry = abap_true.
      status_line-low = eimza_error.
      append status_line to status_range.
    endif.

    " formn <> space: ZEM_F002_03 'eimza' isteği kayıt bulamadığında boş
    " anahtarlı satır ekleyebiliyor; bu satırlar işlenmez
    select formn seqno kunnr lifnr eimza
      into corresponding fields of table result
      from zem_t010
      where formn in s_formn
        and formn <> space
        and eimza in status_range.

    " Aynı formda birden fazla satır işaretliyse en son seqno işlenir.
    " Portalın EIMZA'yı hangi seqno satırına yazdığından bağımsız olarak
    " statünün bulunduğu satır güncellenir.
    sort result by formn ascending seqno descending.
    delete adjacent duplicates from result comparing formn.

    if result is initial.
      return.
    endif.

    " Portal onayda EIMZA = 2 yazdığı için "onaylandı, henüz gönderilmedi"
    " ile "gönderildi" ayrımı workflowKey üzerinden yapılır: workflow'u
    " açılmış formlar tekrar gönderilmez.
    select formn
      into table sent_forms
      from zem_t016_eimza
      for all entries in result
      where formn = result-formn
        and wfkey <> space.

    sort sent_forms.

    loop at result into form.
      form_index = sy-tabix.
      read table sent_forms with key table_line = form-formn
        binary search transporting no fields.
      if sy-subrc = 0.
        delete result index form_index.
      endif.
    endloop.
  endmethod.                    "get_forms_to_send

  method process_form.
    data pdf_base64  type string.
    data signer_info type ty_signer_info.
    data send_result type ty_send_result.
    data form_error  type ref to lcx_eimza_error.

    try.
        pdf_base64  = build_pdf_base64( form ).
        signer_info = get_signer_info( form ).

        send_result = send_to_arksigner(
          form_number = form-formn
          pdf_base64  = pdf_base64
          signer_info = signer_info ).

      catch lcx_eimza_error into form_error.
        send_result-error_text = form_error->error_text.
    endtry.

    save_send_result( form        = form
                      send_result = send_result ).
  endmethod.                    "process_form

  method build_pdf_base64.
    data form_key      type ty_form_key.
    data login_info    type ty_login_info.
    data partner_no    type parnr.
    data minfo         type zem_s010.
    data sender_info   type zem_s008.
    data receiver_info type zem_s009.
    data recdt         type zem_tt018.
    data change_list   type zchange_list_tt.
    data accno         type zem_de_005.
    data form_subrc    type sy-subrc.
    data total_amount  type dmbtr.
    data pdf_data      type xstring.

    form_key   = get_form_key( form-formn ).
    login_info = get_login_info( form-formn ).
    partner_no = get_partner_number( form-formn ).

    get_form_details(
      exporting
        form_key      = form_key
        login_info    = login_info
        partner_no    = partner_no
      importing
        minfo         = minfo
        sender_info   = sender_info
        receiver_info = receiver_info
        recdt         = recdt
        change_list   = change_list
        accno         = accno
        subrc         = form_subrc ).

    if form_subrc <> 0.
      raise exception type lcx_eimza_error exporting error_text = text-e01.
    endif.

    total_amount = calculate_total_amount( recdt ).

    pdf_data = generate_pdf_form(
      minfo         = minfo
      sender_info   = sender_info
      receiver_info = receiver_info
      recdt         = recdt
      change_list   = change_list
      accno         = accno
      total_amount  = total_amount ).

    result = convert_pdf_to_base64( pdf_data ).
  endmethod.                    "build_pdf_base64

  method get_signer_info.
    data contacts      type ty_t_signer_contact.
    data contact_line  type ty_signer_contact.
    data contact_count type i.
    data email         type ad_smtpadr.

    " Müşteri formlarında KUNNR, satıcı formlarında LIFNR dolu gelir
    if form-kunnr is not initial.
      select parnr namev name1 prsnr
        into corresponding fields of table contacts
        from knvk
        where kunnr = form-kunnr
          and pafkt = signer_function.
    else.
      select parnr namev name1 prsnr
        into corresponding fields of table contacts
        from knvk
        where lifnr = form-lifnr
          and pafkt = signer_function.
    endif.

    " Job'da elle seçim yapılamadığı için imzacı tekil olmalı
    contact_count = lines( contacts ).
    if contact_count = 0.
      raise exception type lcx_eimza_error exporting error_text = text-e11.
    elseif contact_count > 1.
      raise exception type lcx_eimza_error exporting error_text = text-e12.
    endif.

    read table contacts into contact_line index 1.

    if contact_line-prsnr is not initial.
      select single smtp_addr
        into email
        from adr6
        where persnumber = contact_line-prsnr
          and flgdefault = abap_true.
    endif.

    if email is initial.
      raise exception type lcx_eimza_error exporting error_text = text-e13.
    endif.

    result-name    = contact_line-namev.
    result-surname = contact_line-name1.
    result-email   = email.
    " TCKN (IDNumber) KNVK'da yok; API dokümanında zorunlu görünse de boş
    " gönderim kabul ediliyor. İmzacı kaynağı netleşince doldurulacak.
  endmethod.                    "get_signer_info

  method get_form_key.
    select single formn seqno
      into (result-formn, result-seqno)
      from zem_t003
      where formn = form_number
        and seqno = ( select max( seqno ) from zem_t003 where formn = form_number ).

    if sy-subrc <> 0.
      raise exception type lcx_eimza_error exporting error_text = text-e02.
    endif.
  endmethod.                    "get_form_key

  method get_login_info.
    select single lgnid guuid
      into (result-login_id, result-guid)
      from zem_t008
      where formn = form_number
        and seqno = ( select max( seqno ) from zem_t008 where formn = form_number ).

    if sy-subrc <> 0.
      raise exception type lcx_eimza_error exporting error_text = text-e03.
    endif.
  endmethod.                    "get_login_info

  method get_partner_number.
    select single parnr
      into result
      from zem_t010
      where formn = form_number
        and seqno = ( select max( seqno ) from zem_t010 where formn = form_number ).

    if sy-subrc <> 0.
      raise exception type lcx_eimza_error exporting error_text = text-e04.
    endif.
  endmethod.                    "get_partner_number

  method get_form_details.
    call function 'ZEM_F002_02'
      exporting
        formn        = form_key-formn
        guid         = login_info-guid
        loginid      = login_info-login_id
        parnr        = partner_no
        seqno        = form_key-seqno
        i_form_pdf   = abap_true
      importing
        minfo        = minfo
        senderinfo   = sender_info
        receiverinfo = receiver_info
        recdt        = recdt
        e_change     = change_list
        accno        = accno
        subrc        = subrc.
  endmethod.                    "get_form_details

  method calculate_total_amount.
    data recdt_line  like line of recdt.
    data amount_text type string.
    data amount      type dmbtr.

    loop at recdt into recdt_line.
      amount_text = recdt_line-nettr.
      condense amount_text no-gaps.
      replace all occurrences of '.' in amount_text with ''.
      replace all occurrences of ',' in amount_text with '.'.

      " Beklenmeyen formatta tutar job'ı dump ile durdurmamalı
      try.
          amount = amount_text.
        catch cx_sy_conversion_error.
          raise exception type lcx_eimza_error exporting error_text = text-e14.
      endtry.

      result = result + amount.
    endloop.
  endmethod.                    "calculate_total_amount

  method get_output_device.
    select single spld
      from usr01
      into result
      where bname = sy-uname.

    if result is initial.
      result = output_device.
    endif.
  endmethod.                    "get_output_device

  method generate_pdf_form.
    data function_name type rs38l_fnam.
    data outputparams  type sfpoutputparams.
    data docparams     type sfpdocparams.
    data form_output   type fpformoutput.
    data fp_error      type ref to cx_fp_api.
    data error_text    type string.
    data form_subrc    type sy-subrc.
    data close_subrc   type sy-subrc.

    " Form adından üretilen fonksiyon modülünün adını al
    try.
        call function 'FP_FUNCTION_MODULE_NAME'
          exporting
            i_name     = adobe_form_name
          importing
            e_funcname = function_name.
      catch cx_fp_api into fp_error.
        error_text = fp_error->get_text( ).
        raise exception type lcx_eimza_error exporting error_text = error_text.
    endtry.

    " Job'da yazdırma penceresi açılmadan PDF xstring olarak alınır
    outputparams-nodialog = abap_true.
    outputparams-dest     = get_output_device( ).
    outputparams-getpdf   = abap_true.

    call function 'FP_JOB_OPEN'
      changing
        ie_outputparams = outputparams
      exceptions
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        others          = 5.

    if sy-subrc <> 0.
      raise exception type lcx_eimza_error exporting error_text = text-e05.
    endif.

    docparams-langu   = sy-langu.
    docparams-country = form_country.

    " function_name runtime'da belirlendiği için (dinamik çağrı)
    " form_output'un tipi önceden tanımlanmalıdır
    call function function_name
      exporting
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
      importing
        /1bcdwb/formoutput = form_output
      exceptions
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        others             = 4.

    form_subrc = sy-subrc.

    " Form çağrısı hata verse de job her durumda kapatılır
    call function 'FP_JOB_CLOSE'
      exceptions
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        others         = 4.

    close_subrc = sy-subrc.

    if form_subrc <> 0.
      raise exception type lcx_eimza_error exporting error_text = text-e06.
    endif.

    if close_subrc <> 0.
      raise exception type lcx_eimza_error exporting error_text = text-e07.
    endif.

    result = form_output-pdf.

    if result is initial.
      raise exception type lcx_eimza_error exporting error_text = text-e08.
    endif.
  endmethod.                    "generate_pdf_form

  method convert_pdf_to_base64.
    call function 'SCMS_BASE64_ENCODE_STR'
      exporting
        input  = pdf_data
      importing
        output = result.

    if result is initial.
      raise exception type lcx_eimza_error exporting error_text = text-e09.
    endif.
  endmethod.                    "convert_pdf_to_base64

  method get_arksigner_config.
    result-app_id = m_config-appid.
    result-pass   = m_config-apass.
  endmethod.                    "get_arksigner_config

  method send_to_arksigner.
    data request             type zeho_arksingermt_sap_arksigne1.
    data response            type zeho_arksingermt_sap_arksigner.
    data response_data       like line of response-mt_sap_arksigner_mutabakat_eim-data.
    data config              type zeho_arksingerdt_sap_arksigne9.
    data document_line       type zeho_arksingerdt_sap_arksigne6.
    data post_operation_line type zeho_arksingerdt_sap_arksigne4.
    data file_line           type zeho_arksingerdt_sap_arksigne5.
    data workflow_step_line  type zeho_arksingerdt_sap_arksigne1.
    data workflow_line       type zeho_arksingerdt_sap_arksigne2.
    data notification_line   type zeho_arksingerdt_sap_arksigner.
    data privilege_line      type zeho_arksingerdt_sap_arksigne3.
    data proxy               type ref to zeho_arksingerco_si_sap_to_3rd.
    data system_fault        type ref to cx_ai_system_fault.
    data application_fault   type ref to cx_ai_application_fault.
    data success             type string.

    config = get_arksigner_config( ).

    " Doküman tanımı - ArkSigner ekranında form numarasıyla görünür
    concatenate text-d01 form_number into document_line-name separated by space.
    document_line-description          = text-d02.
    document_line-sign_type            = sign_type_pades.
    document_line-sign_validation_time = sign_validation_est.

    " İmza sonrası işlemler
    post_operation_line-is_document_to_be_archived     = arksigner_flag_false.
    post_operation_line-send_ftp                       = arksigner_flag_false.
    post_operation_line-send_mail                      = arksigner_flag_false.
    post_operation_line-save_to_folder                 = arksigner_flag_false.
    post_operation_line-is_send_to_all_users_in_workfl = arksigner_flag_false.
    post_operation_line-send_to_web_service            = arksigner_flag_false.

    " İmzalanacak dosya
    file_line-data = pdf_base64.
    concatenate form_number file_extension_pdf into file_line-file_name.
    file_line-file_type = file_type_pdf.

    " İmzacı adımı
    clear workflow_step_line-username.
    workflow_step_line-name          = signer_info-name.
    workflow_step_line-surname       = signer_info-surname.
    workflow_step_line-idnumber      = signer_info-id_no.
    workflow_step_line-email_address = signer_info-email.
    workflow_step_line-order_no      = workflow_order_first.
    workflow_step_line-task_type     = workflow_task_type_sign.

    notification_line-workflow_step_notification_typ = notification_mail.
    append notification_line to workflow_step_line-workflow_step_notification_lis.
    clear notification_line.
    notification_line-workflow_step_notification_typ = notification_sms.
    append notification_line to workflow_step_line-workflow_step_notification_lis.
    clear notification_line.

    privilege_line-workflow_privilege_type = privilege_view.
    append privilege_line to workflow_step_line-worflow_step_privilege_model_l.
    clear privilege_line.
    privilege_line-workflow_privilege_type = privilege_sign.
    append privilege_line to workflow_step_line-worflow_step_privilege_model_l.
    clear privilege_line.

    " Workflow
    workflow_line-workflow_started_by            = m_config-strby.
    workflow_line-send_notification_mail_to_firs = arksigner_flag_true.
    workflow_line-add_qr                         = arksigner_flag_true.

    append post_operation_line to workflow_line-post_operation.
    append document_line       to workflow_line-document_workflow.
    append file_line           to workflow_line-file_list.
    append workflow_step_line  to workflow_line-workflow_step_list.

    append config        to request-mt_sap_arksigner_mutabakat_eim-config.
    append workflow_line to request-mt_sap_arksigner_mutabakat_eim-workflow.

    try.
        create object proxy.

        proxy->si_sap_to_3rd_arksinger_mutaba(
          exporting
            output = request
          importing
            input  = response ).

      catch cx_ai_system_fault into system_fault.
        result-error_text = system_fault->errortext.
        return.

      catch cx_ai_application_fault into application_fault.
        result-error_text = application_fault->get_text( ).
        return.
    endtry.

    " Exception olmaması başarı anlamına gelmez: ArkSigner hatayı
    " Success = false / ErrorCode <> 0 ile döner (API dok. 6.2.1)
    success = response-mt_sap_arksigner_mutabakat_eim-success.
    translate success to lower case.
    result-error_code = response-mt_sap_arksigner_mutabakat_eim-error_code.

    if success <> arksigner_flag_true
       or ( result-error_code is not initial
            and result-error_code <> arksigner_error_code_ok ).
      result-error_text = response-mt_sap_arksigner_mutabakat_eim-error.
      if result-error_text is initial.
        concatenate text-e15 result-error_code into result-error_text separated by space.
      endif.
      return.
    endif.

    " DATA proxy'de tablo olarak üretildi; workflowKey ilk satırda gelir
    read table response-mt_sap_arksigner_mutabakat_eim-data into response_data index 1.
    if sy-subrc = 0.
      result-workflow_key = response_data-workflow_key.
    endif.

    if result-workflow_key is initial.
      result-error_text = text-e16.
    endif.
  endmethod.                    "send_to_arksigner

  method save_send_result.
    data eimza_log   type zem_t016_eimza.
    data output_line type ty_output.
    data new_status  type zem_de_210.

    if send_result-error_text is initial.
      new_status = eimza_sent.
    else.
      new_status = eimza_error.
    endif.

    " Yeniden denemede kayıt üzerine yazılır; son denemenin sonucu tutulur
    eimza_log-formn = form-formn.
    eimza_log-seqno = form-seqno.
    eimza_log-wfkey = send_result-workflow_key.
    eimza_log-eimza = new_status.
    eimza_log-errcd = send_result-error_code.
    eimza_log-ermsg = send_result-error_text.
    eimza_log-snddt = sy-datum.
    eimza_log-sndtm = sy-uzeit.
    eimza_log-sndus = sy-uname.
    modify zem_t016_eimza from eimza_log.

    update zem_t010 set eimza = new_status
      where formn = form-formn
        and seqno = form-seqno.

    " Her form kendi LUW'unda kaydedilir; sonraki formdaki hata bunu geri almaz
    commit work.

    output_line-formn = form-formn.
    output_line-seqno = form-seqno.
    output_line-eimza = new_status.
    output_line-wfkey = eimza_log-wfkey.
    output_line-ermsg = eimza_log-ermsg.
    append output_line to m_output.
  endmethod.                    "save_send_result

  method display_output.
    data alv        type ref to cl_salv_table.
    data salv_error type ref to cx_salv_msg.

    if m_output is initial.
      return.
    endif.

    try.
        cl_salv_table=>factory(
          importing
            r_salv_table = alv
          changing
            t_table      = m_output ).

        alv->get_functions( )->set_all( abap_true ).
        alv->get_columns( )->set_optimize( abap_true ).
        alv->display( ).

      catch cx_salv_msg into salv_error.
        message salv_error type 'S' display like 'E'.
    endtry.
  endmethod.                    "display_output

endclass.                    "lcl_report IMPLEMENTATION
