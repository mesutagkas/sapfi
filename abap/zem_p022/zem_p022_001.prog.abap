*&---------------------------------------------------------------------*
*& Include ZEM_P022_001
*&---------------------------------------------------------------------*
*& Data Definitions
*&---------------------------------------------------------------------*

* ---Type Definitions------------------
types: begin of ty_form_key,
         formn type zem_de_001,
         seqno type seqno,
       end of ty_form_key.

types: begin of ty_login_info,
         login_id type sysuuid_c,
         guid     type sysuuid_c,
       end of ty_login_info.

types: begin of ty_signer_info,
         name    type string,
         surname type string,
         id_no   type string,
         email   type string,
       end of ty_signer_info.

" S_FORMN F4 listesi (ZEM_T010)
types: begin of ty_form_search_help,
         formn type zem_de_001,
         accno type zem_de_005,
       end of ty_form_search_help.
types ty_t_form_search_help type standard table of ty_form_search_help with default key.

" İmzacı ilgili kişi kaydı - KNVK (teknik alan PRSNR dahil)
types: begin of ty_signer_contact,
         parnr type parnr,
         namev type namev_vp,
         name1 type name1_gp,
         prsnr type ad_persnum,
       end of ty_signer_contact.
types ty_t_signer_contact type standard table of ty_signer_contact with default key.

" Gönderilecek form: ZEM_T010'da e-imza statüsü 2 (yeniden denemede 3)
" olan satır
types: begin of ty_eimza_form,
         formn type zem_de_001,
         seqno type seqno,
         kunnr type kunnr,
         lifnr type lifnr,
         eimza type zem_de_210,
       end of ty_eimza_form.
types ty_t_eimza_form type standard table of ty_eimza_form with default key.

" ArkSigner CreateWorkflow sonucu
types: begin of ty_send_result,
         workflow_key type string,
         error_code   type string,
         error_text   type string,
       end of ty_send_result.

" Durumu sorgulanacak form: ZEM_T016_EIMZA'da gönderilmiş (2) ve workflowKey'i olan
types: begin of ty_tracked_form,
         formn type zem_de_001,
         seqno type seqno,
         wfkey type sysuuid_c36,
       end of ty_tracked_form.
types ty_t_tracked_form type standard table of ty_tracked_form with default key.

" ArkSigner GetStatus sonucu
types: begin of ty_status_result,
         " İş akışı kapandığında dönen durum metni (ör. "İş Akışı Tamamlandı")
         data_text  type string,
         " İmzacı listesi döndüyse iş akışı hâlâ devam ediyor
         pending    type abap_bool,
         error_text type string,
       end of ty_status_result.

" Job çıktısı (önde ALV, arka planda spool)
types: begin of ty_output,
         formn type zem_de_001,
         seqno type seqno,
         eimza type zem_de_210,
         wfkey type sysuuid_c36,
         ermsg type bapi_msg,
       end of ty_output.
types ty_t_output type standard table of ty_output with default key.

* ---Global Data------------------------
" S_FORMN'in referans alanı
data form_number type zem_de_001.

* ---Object References-----------------
" lcl_report zem_p022_003'te tanımlandığı için forward-declare edilir
class lcl_report definition deferred.
data report type ref to lcl_report.

* ---Constants--------------------------
" Adobe Form - SFP'deki gerçek adı kontrol edin (eski program ZEM_AF_001 kullanıyordu)
constants adobe_form_name type fpname    value 'ZEM_AF_001'.
" Kullanıcının SU3 varsayılan yazıcısı yoksa kullanılacak çıktı cihazı (SPAD'de tanımlı olmalı)
constants output_device   type rspopname value 'LP01'.
constants form_country    type land1     value 'TR'.

" İmzacı işlev kodu (KNVK-PAFKT, "Bayi Mutabakat Mail")
" Not: MDP standardına göre hard code Teknik Lider onayı gerektirir
constants signer_function type pafkt value '99'.

" E-imza statüleri (ZEM_DE_210 domain sabit değerleri)
constants eimza_sent     type zem_de_210 value '2'. " E-imza Gönderildi
constants eimza_error    type zem_de_210 value '3'. " E-imza Gönderiminde Hata Alındı
constants eimza_rejected type zem_de_210 value '4'. " E-imza Reddedildi (takip job'ı)
constants eimza_signed   type zem_de_210 value '5'. " E-imza Onaylandı (takip job'ı)

" ArkSigner servisi boolean alanları string 'true'/'false' bekliyor (abap_bool DEĞİL)
constants arksigner_flag_true  type string value 'true'.
constants arksigner_flag_false type string value 'false'.
" CreateWorkflow başarılı olduğunda ErrorCode (API dok. 6.2.1)
constants arksigner_error_code_ok type string value '0'.

constants notification_mail type char1 value '1'.
constants notification_sms  type char1 value '2'.
constants privilege_view    type char1 value '1'.
constants privilege_sign    type char1 value '2'.

constants sign_type_pades          type string value 'PAdES'.
constants sign_validation_est      type string value 'EST'.
constants file_type_pdf            type string value '0'.
constants file_extension_pdf       type string value '.pdf'.
constants workflow_order_first     type string value '1'.
constants workflow_task_type_sign  type string value '0'.
