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
