*&---------------------------------------------------------------------*
*& Include ZEM_P022_002
*&---------------------------------------------------------------------*
*& Selection Screen Definitions
*&---------------------------------------------------------------------*

selection-screen begin of block b01 with frame title text-b01.
" Boş bırakılırsa statüsü uygun tüm formlar işlenir (job kullanımı)
select-options s_formn for form_number.
" İşaretlenirse gönderimde hata almış (statü 3) formlar da yeniden gönderilir
parameters p_retry as checkbox.
selection-screen end of block b01.

selection-screen begin of block b02 with frame title text-b02.
" Portalda onaylanan formları ArkSigner'a gönder (EIMZA 2 / 3)
parameters p_send  as checkbox default 'X'.
" Gönderilmiş formların e-imza sonucunu sorgula (EIMZA 4 / 5)
parameters p_check as checkbox default 'X'.
selection-screen end of block b02.
