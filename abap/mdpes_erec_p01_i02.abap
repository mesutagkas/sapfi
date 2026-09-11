*&---------------------------------------------------------------------*
*& Include /MDPES/EREC_P01_I02
*&---------------------------------------------------------------------*
*& Selection Screen Definitions
*&---------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- Form numarası artık hard-code değil, kullanıcı girişi
* *- added by markus.abap 11.09.2026
*-------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS p_formn TYPE zem_t003-formn OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b01.

*-------------------------------------------------------------------*
* *- İmzalayacak kişinin bilgileri artık hard-code değil, ekrandan
* *- alınıyor (kişisel veri programda sabit tutulmamalı)
* *- added by markus.abap 11.09.2026
*-------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS:
    p_name  TYPE string OBLIGATORY,
    p_surn  TYPE string OBLIGATORY,
    p_idnr  TYPE string OBLIGATORY,
    p_email TYPE string OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b02.
