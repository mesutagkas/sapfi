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

* ---Object References-----------------
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
