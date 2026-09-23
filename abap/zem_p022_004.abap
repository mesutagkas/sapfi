*&---------------------------------------------------------------------*
*& Include ZEM_P022_004
*&---------------------------------------------------------------------*
*& Events Definitions
*&---------------------------------------------------------------------*

INITIALIZATION.
  CREATE OBJECT report.
  report->initialization( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_formn.
  report->f4_help_for_form( retfield = 'FORMN' ).

*-------------------------------------------------------------------*
* *- İmzacı alanlarının F4'ü ZEM_T010 yerine KNVK/ADR6 tabanlı
* *- f4_help_for_signer metoduna bağlandı. P_SNAME/P_SSURN F4'leri
* *- açıldı; üç alandan hangisinden tetiklenirse tetiklensin ad,
* *- soyad ve e-posta birlikte dolar.
* *- changed by markus.abap 23.09.2026
*-------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_semail.
*  report->f4_help_for_form( retfield = 'EMAIL' ).
*
*" P_SNAME/P_SSURN için F4, ZEM_T010'a SNAME/SSURN alanları eklenince
*" (bkz. zem_p022_text_symbols.md) buraya geri eklenmeli:
*" AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_sname.
*"   report->f4_help_for_form( retfield = 'SNAME' ).
*" AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ssurn.
*"   report->f4_help_for_form( retfield = 'SSURN' ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_sname.
  report->f4_help_for_signer( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ssurn.
  report->f4_help_for_signer( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_semail.
  report->f4_help_for_signer( ).
*-------------------------------------------------------------------*

START-OF-SELECTION.
  report->prepare_data( ).
