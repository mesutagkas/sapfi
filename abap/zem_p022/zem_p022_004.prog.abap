*&---------------------------------------------------------------------*
*& Include ZEM_P022_004
*&---------------------------------------------------------------------*
*& Events Definitions
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
initialization.
  create object report.
  report->initialization( ).

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
at selection-screen on value-request for s_formn-low.
  report->f4_help_for_form( 'S_FORMN-LOW' ).

at selection-screen on value-request for s_formn-high.
  report->f4_help_for_form( 'S_FORMN-HIGH' ).

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
start-of-selection.
  report->prepare_data( ).
  report->display_output( ).
