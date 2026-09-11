*&---------------------------------------------------------------------*
*&**********************************************************************
*&                         MDP Group                                   *
*&**********************************************************************
*&  Program : /MDPES/EREC_P01                                         *
*&  Version : 1.0                          Creation Date: 11.09.2026   *
*&  T.Code  : /MDPES/EREC01                                           *
*&  Author  : Markus                                                   *
*&**********************************************************************
*&  Program Description: En son ZEM_T003/T008/T010 kayıtlarından form  *
*&  bilgilerini okur, ZEM_F002_02 ile form detaylarını ve tahsilat     *
*&  listesini getirir, Adobe Form (ZEM_AF_001) ile PDF üretir ve       *
*&  üretilen PDF'i ArkSigner e-imza servisine gönderir.                *
*&                                                                     *
*&**********************************************************************
*&  Program - Changes                                                  *
*&  +---------------------------------------------------------------+  *
*&  | Code           | Programmer    | Title / Change               |  *
*&  +---------------------------------------------------------------+  *
*&  |                | markus.abap   | NEW - method tabanlı refactor|  *
*&  +---------------------------------------------------------------+  *
*&  Email : info@mdpgroup.com                                          *
*&**********************************************************************

REPORT /mdpes/erec_p01.

INCLUDE /mdpes/erec_p01_i01.    " Global Data
INCLUDE /mdpes/erec_p01_i02.    " Selection Screen
INCLUDE /mdpes/erec_p01_i03.    " Class Definitions
INCLUDE /mdpes/erec_p01_i04.    " Event Definitions
INCLUDE /mdpes/erec_p01_i05.    " Form Definitions (legacy uyumluluk - kullanılmıyor)
