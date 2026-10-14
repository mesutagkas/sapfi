*-------------------------------------------------------------------*
* check_tiban içindeki ZPER (personel) bloğu.
* Sadece bu blok değişti; geri kalan kod aynen kalır.
*-------------------------------------------------------------------*
    if vendor_group = 'ZPER'.
      clear document_type.
      select single blart from t003 into @document_type where blart = 'PM'.
      ch_out-blart = document_type.
*-------------------------------------------------------------------*
* *- ZPER (personel) satıcıda check_lfa1 ile aynı: belge türü PM ve
* *- özel defter ana hesap göstergesi (UMSKZ) M
* *- added by <kullanıcı> 14.10.2026
*-------------------------------------------------------------------*
      if document_type eq 'PM'.
        ch_out-umskz = 'M'.
      endif.
*-------------------------------------------------------------------*
    endif.
  endif.
