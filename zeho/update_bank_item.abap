  method update_bank_item.
    data:
      lv_name1 type zeho_t012-txt50,
      lv_ktopl type t001-ktopl.
*-------------------------------------------------------------------*
* *- Kalem bulunamazsa log için
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
    data ls_message type symsg.
*-------------------------------------------------------------------*

*-- Müşteri satıcı ana hesap metin lerini bul
    if cs_out-kunnr is not initial.
      select single name1 from kna1 into lv_name1 where kunnr = cs_out-kunnr.
    elseif cs_out-lifnr is not initial.
      select single name1 from lfa1 into lv_name1 where lifnr = cs_out-lifnr.
    elseif cs_out-saknr is not initial.
      select single ktopl from t001 into lv_ktopl where bukrs = cs_out-bukrs.
      if sy-subrc = 0.
        select single txt50 from skat into lv_name1 where spras = sy-langu
                                                      and ktopl = lv_ktopl
                                                      and saknr = cs_out-saknr.

      endif.
    endif.

    cs_out-txt50 = lv_name1.

*-- Kalem tablosunu güncelle
    update zeho_t012 set statu     = iv_statu
                         kunnr     = cs_out-kunnr
                         lifnr     = cs_out-lifnr
                         saknr     = cs_out-saknr
                         blart     = cs_out-blart
                         kosak     = cs_out-kosak
                         umskz     = cs_out-umskz
                         mwskz     = cs_out-mwskz
                         gsber     = cs_out-gsber
                         kostl     = cs_out-kostl
                         prctr     = cs_out-prctr
                         pspel     = cs_out-pspel
                         aufnr     = cs_out-aufnr
                         kursf     = cs_out-kursf
                         vgint     = cs_out-vgint
                         xref3     = cs_out-xref3
                         txt50     = lv_name1
                         customtype = cs_out-customtype
                         kosak_val = cs_out-kosak_val
                         belnr     = cs_out-belnr
                                              where bankc  = cs_out-bankc
                                                and bukrs  = cs_out-bukrs
                                                and hbkid  = cs_out-hbkid
                                                and hktid  = cs_out-hktid
                                                and bankn  = cs_out-bankn
                                                and trnid  = cs_out-trnid
                                                and refbk  = cs_out-refbk
                                                and prdat  = cs_out-prdat
                                                and prtim  = cs_out-prtim
                                                and seqnr  = cs_out-seqnr
                                                and waers  = cs_out-waers
                                                and amount = cs_out-amount
*-------------------------------------------------------------------*
* *- vgint WHERE'den çıkarıldı: SET'te güncelleniyor. check_t004 boş
* *- vgint'i doldurduğunda WHERE satırı bulamıyordu.
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
*                                                and prtyp  = cs_out-prtyp
*                                                and vgint  = cs_out-vgint.
                                                and prtyp  = cs_out-prtyp.

    if sy-dbcnt = 0.
*-- EHO kalemi bulunamadı: sessiz geçme, logla
      clear ls_message.
      ls_message-msgid = 'ZEHO'.
      ls_message-msgno = '052'.     " EHO kalemi güncellenemedi (belge &1)
      ls_message-msgty = 'E'.
      ls_message-msgv1 = cs_out-belnr.
      zeho_cl020=>collect_message( is_message = ls_message is_out = cs_out ).
    endif.
*-------------------------------------------------------------------*

    commit work and wait.

  endmethod.
