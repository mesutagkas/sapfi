*&---------------------------------------------------------------------*
*& Include /MDPES/EREC_P01_I04
*&---------------------------------------------------------------------*
*& Event Definitions
*&---------------------------------------------------------------------*

INITIALIZATION.
  report = NEW #( ).
  report->initialization( ).

START-OF-SELECTION.
  report->prepare_data( ).
