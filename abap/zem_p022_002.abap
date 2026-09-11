*&---------------------------------------------------------------------*
*& Include ZEM_P022_002
*&---------------------------------------------------------------------*
*& Selection Screen Definitions
*&---------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- Form numarası artık hard-code değil, kullanıcı girişi
* *- added by markus.abap 11.09.2026
*-------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS p_formn TYPE zem_de_001 OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b01.

*-------------------------------------------------------------------*
* *- İmzalayacak kişinin bilgileri ve workflow'u başlatan kullanıcı
* *- artık hard-code değil, ekrandan alınıyor (kişisel veri programda
* *- sabit tutulmamalı)
* *- added by markus.abap 11.09.2026
*-------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS:
    p_sname  TYPE string OBLIGATORY,   " İmzalayan - Ad
    p_ssurn  TYPE string OBLIGATORY,   " İmzalayan - Soyad
    p_sidnr  TYPE string OBLIGATORY,   " İmzalayan - T.C. Kimlik No
    p_semail TYPE string OBLIGATORY.   " İmzalayan - E-posta
SELECTION-SCREEN END OF BLOCK b02.

*-------------------------------------------------------------------*
* *- Workflow'u başlatan kullanıcı imzalayandan ayrı bir blokta
* *- changed by markus.abap 11.09.2026
*-------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-b03.
  PARAMETERS:
    p_stdby TYPE string OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b03.
