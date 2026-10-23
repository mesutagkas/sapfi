*&---------------------------------------------------------------------*
*&**********************************************************************
*&                         MDP Group                                   *
*&**********************************************************************
*&  Program : ZEM_P022                                                 *
*&  Version : 2.0                          Creation Date: 25.09.2026   *
*&  T.Code  :                                                          *
*&  Author  :                                                          *
*&**********************************************************************
*&  Program Description: E Mutabakat Gönderim ve E İmza Takip Programı *
*&  Portalda onaylanan (ZEM_T010-EIMZA = 2) formların PDF'ini üretip   *
*&  ArkSigner'a e-imza iş akışı olarak gönderir. Job olarak çalışır.   *
*&**********************************************************************
*&  Program - Changes                                                  *
*&  +---------------------------------------------------------------+  *
*&  | Code           | Programmer    | Title / Change               |  *
*&  +---------------------------------------------------------------+  *
*&  |                |               | NEW                          |  *
*&  |                |               | Tekli gönderimden job'a geçiş|  *
*&  |                |               | yanıt kontrolü, EIMZA statüsü|  *
*&  +---------------------------------------------------------------+  *
*&  Email : info@mdpgroup.com                                          *
*&**********************************************************************
report zem_p022.

include zem_p022_001. " Data Definitions
include zem_p022_002. " Selection Screen Definitions
include zem_p022_003. " Class Definitions
include zem_p022_004. " Events Definitions
