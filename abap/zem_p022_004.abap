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

" İmzacı (dış kullanıcı) bilgisi artık KNVK (PAFKT=99) + ADR6'dan geliyor -
" hangi alandan F4 açılırsa açılsın aynı liste, üç alan birlikte dolar.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_sname.
  report->f4_help_for_signer( retfield = 'NAMEV' ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ssurn.
  report->f4_help_for_signer( retfield = 'NAME1' ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_semail.
  report->f4_help_for_signer( retfield = 'EMAIL' ).

START-OF-SELECTION.
  report->prepare_data( ).
