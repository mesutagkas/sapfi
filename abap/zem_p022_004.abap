*&---------------------------------------------------------------------*
*& Include ZEM_P022_004
*&---------------------------------------------------------------------*
*& Events Definitions
*&---------------------------------------------------------------------*

INITIALIZATION.
  CREATE OBJECT report.
  report->initialization( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_formn.
  report->f4_help_for_form( ).

START-OF-SELECTION.
  report->prepare_data( ).
