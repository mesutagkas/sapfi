*&---------------------------------------------------------------------*
*& Include ZEM_P022_001
*&---------------------------------------------------------------------*
*& Data Definitions
*&---------------------------------------------------------------------*

* ---Type Definitions------------------
TYPES: BEGIN OF ty_form_key,
         formn TYPE zem_de_001,
         seqno TYPE seqno,
       END OF ty_form_key.

TYPES: BEGIN OF ty_login_info,
         login_id TYPE sysuuid_c,
         guid     TYPE sysuuid_c,
       END OF ty_login_info.

TYPES: BEGIN OF ty_signer_info,
         name    TYPE string,
         surname TYPE string,
         id_no   TYPE string,
         email   TYPE string,
       END OF ty_signer_info.

" P_FORMN için F4 (arama yardımı) popup'ında gösterilecek/seçilecek alanlar.
TYPES: BEGIN OF ty_form_search_help,
         formn TYPE zem_de_001,
         accno TYPE zem_de_005,
       END OF ty_form_search_help.
TYPES ty_t_form_search_help TYPE STANDARD TABLE OF ty_form_search_help WITH DEFAULT KEY.

" P_SNAME/P_SSURN/P_SEMAIL için F4 (arama yardımı) popup'ında gösterilecek/
" seçilecek alanlar. İmzacı (dış kullanıcı) artık ZEM_T010 yerine müşteri
" master'ındaki "E Mutabakat Yetkilisi" ilgili kişisinden (KNVK, PAFKT = 99)
" ve onun e-posta adresinden (ADR6, PERSNUMBER = KNVK-PRSNR) okunuyor.
TYPES: BEGIN OF ty_signer_search_help,
         kunnr TYPE knvk-kunnr,
         prsnr TYPE knvk-prsnr,
         namev TYPE knvk-namev,
         name1 TYPE knvk-name1,
         email TYPE adr6-smtp_addr,
       END OF ty_signer_search_help.
TYPES ty_t_signer_search_help TYPE STANDARD TABLE OF ty_signer_search_help WITH DEFAULT KEY.

* ---Object References-----------------
" lcl_report henüz zem_p022_003'te tanımlanmadığı için forward-declare edilir
CLASS lcl_report DEFINITION DEFERRED.
DATA report TYPE REF TO lcl_report.

* ---Constants--------------------------
CONSTANTS adobe_form_name TYPE string VALUE 'ZEM_AF_001'.

" ArkSigner servisi boolean alanları string 'true'/'false' bekliyor (abap_bool DEĞİL)
CONSTANTS arksigner_flag_true  TYPE string VALUE 'true'.
CONSTANTS arksigner_flag_false TYPE string VALUE 'false'.

CONSTANTS notification_mail TYPE char1 VALUE '1'.
CONSTANTS notification_sms  TYPE char1 VALUE '2'.
CONSTANTS privilege_view    TYPE char1 VALUE '1'.
CONSTANTS privilege_sign    TYPE char1 VALUE '2'.

CONSTANTS sign_type_pades      TYPE string VALUE 'PAdES'.
CONSTANTS sign_validation_est  TYPE string VALUE 'EST'.
CONSTANTS file_type_pdf        TYPE string VALUE '0'.
CONSTANTS file_name_pdf        TYPE string VALUE 'adobe.pdf'.
CONSTANTS workflow_order_first     TYPE string VALUE '1'.
CONSTANTS workflow_task_type_sign  TYPE string VALUE '0'.

" KNVK'da imzacıyı ("E Mutabakat Yetkilisi") işaretleyen partner fonksiyonu
CONSTANTS signer_partner_function TYPE knvk-pafkt VALUE '99'.
