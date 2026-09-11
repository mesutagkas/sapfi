*&---------------------------------------------------------------------*
*& Include /MDPES/EREC_P01_I01
*&---------------------------------------------------------------------*
*& Global Data Definitions
*&---------------------------------------------------------------------*

* ---Type Definitions------------------
TYPES: BEGIN OF ty_form_key,
         formn TYPE zem_t003-formn,
         seqno TYPE zem_t003-seqno,
       END OF ty_form_key.

TYPES: BEGIN OF ty_login_info,
         login_id TYPE zem_t008-lgnid,
         guid     TYPE zem_t008-guuid,
       END OF ty_login_info.

TYPES: BEGIN OF ty_signer_info,
         name    TYPE string,
         surname TYPE string,
         id_no   TYPE string,
         email   TYPE string,
       END OF ty_signer_info.

*-------------------------------------------------------------------*
* NOT: aşağıdaki tipler ZEM_F002_02 fonksiyon modülünün gerçek
* arayüzüyle (minfo, senderinfo, receiverinfo, recdt, accno) birebir
* eşleşmelidir. Burada projede mevcut olduğu varsayılan dictionary
* nesne isimleri kullanılmıştır - gerçek isimlerle teyit edilmelidir.
*-------------------------------------------------------------------*
TYPES ty_minfo         TYPE zem_s_minfo.
TYPES ty_senderinfo    TYPE zem_s_senderinfo.
TYPES ty_receiverinfo  TYPE zem_s_receiverinfo.
TYPES ty_recdt         TYPE zem_s_recdt.
TYPES ty_t_recdt       TYPE STANDARD TABLE OF ty_recdt WITH DEFAULT KEY.
TYPES ty_accno         TYPE zem_s_accno.

TYPES: BEGIN OF ty_arksigner_config,
         app_id      TYPE string,
         app_pass    TYPE string,
         started_by  TYPE string,
       END OF ty_arksigner_config.

* ---Object References-----------------
DATA report TYPE REF TO lcl_report.

* ---Constants--------------------------
CONSTANTS adobe_form_name    TYPE fpname  VALUE 'ZEM_AF_001'.
CONSTANTS notification_mail  TYPE char1   VALUE '1'.
CONSTANTS notification_sms   TYPE char1   VALUE '2'.
CONSTANTS privilege_view     TYPE char1   VALUE '1'.
CONSTANTS privilege_sign     TYPE char1   VALUE '2'.
