*-------------------------------------------------------------------*
* oto_recognation içinde check_referance çağrısından sonraki blok.
* Sadece "if lv_subrc eq 0." kısmı değişti; geri kalan kod aynen kalır.
*-------------------------------------------------------------------*
              if lv_subrc eq 0.
                move-corresponding <fs_out> to ls_t012.
                ls_t012-belnr = ls_bseg-belnr.
*                ls_t012-statu = '5'.
*                <fs_out>-statu = '5'.
*-------------------------------------------------------------------*
* *- Bulunan belgenin işlem kodu ZEHO003 ise 5, değilse (dışarıdan
* *- atılmış) 7. Her iki durumda da tekrar muhasebeleştirme yapılmaz.
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
                data lv_tcode_ref type bkpf-tcode.
                clear lv_tcode_ref.
                select single tcode from bkpf
                  into lv_tcode_ref
                  where bukrs = ls_bseg-bukrs
                    and belnr = ls_bseg-belnr
                    and gjahr = ls_bseg-gjahr.
                if sy-subrc = 0 and lv_tcode_ref <> 'ZEHO003'.
                  ls_t012-statu = '7'.
                else.
                  ls_t012-statu = '5'.
                endif.
                <fs_out>-statu = ls_t012-statu.
*-------------------------------------------------------------------*
                <fs_out>-icon     = '@08@'.
                <fs_out>-belnr = ls_bseg-belnr.
                modify zeho_t012 from ls_t012.
                message s038(zeho) display like 'S'.
* İlgili Kayıt Daha Önce Muhasebeleştirilmiştir. Kayıt Güncellenmiştir.

              else.
