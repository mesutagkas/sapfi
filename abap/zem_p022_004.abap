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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_sname.
  report->f4_help_for_form( retfield = 'SNAME' ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ssurn.
  report->f4_help_for_form( retfield = 'SSURN' ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_semail.
  report->f4_help_for_form( retfield = 'EMAIL' ).

START-OF-SELECTION.
  report->prepare_data( ).
