  method update_bank_item.
    data:
      lv_name1 type zeho_t012-txt50,
      lv_ktopl type t001-ktopl.

*-------------------------------------------------------------------*
* *- Muhasebeleşmiş satırın korunması için
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
*-- EHO muhasebeleştirme işlem kodu (belgenin EHO'dan atıldığının izi)
    constants lc_eho_tcode type bkpf-tcode value 'ZEHO003'.
    data: ls_message  type symsg,
          lv_statu    type zeho_t012-statu,
          lv_db_statu type zeho_t012-statu,
          lv_db_belnr type zeho_t012-belnr,
          lv_gjahr    type bkpf-gjahr,
          lv_stblg    type bkpf-stblg,
          lv_xblnr    type bkpf-xblnr,
          lv_tcode    type bkpf-tcode.
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

*-------------------------------------------------------------------*
* *- Muhasebeleşmiş satır korunuyor (BELNR dolu + statü 4 hatası):
* *- 1) DB'de BELNR dolu, gelen BELNR boş: ekrandaki satır eski
* *-    (başka oturumda muhasebeleşmiş). Satır eski bilgiyle ezilmez,
* *-    DB'deki belge ve statü ekrana alınır. Belge ters kayıtla iptal
* *-    edildiyse (BKPF-STBLG dolu) güncelleme normal yapılır.
* *- 2) BELNR doluyken statü 1-4 yazılmaz. DB'de aynı belgeyle 5/7
* *-    varsa o korunur; yoksa belgeye bakılır: EHO'dan atılmışsa
* *-    (XBLNR 'EHO-*' / TCODE ZEHO003) 5, değilse 7.
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
    lv_statu = iv_statu.
    lv_gjahr = cs_out-prdat+0(4).

    clear: lv_db_statu, lv_db_belnr.
    select single statu belnr from zeho_t012
      into (lv_db_statu, lv_db_belnr)
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
                                                and prtyp  = cs_out-prtyp.

*-- 1) Eski ekran satırı muhasebeleşmiş satırı ezmesin
    if lv_db_belnr is not initial and cs_out-belnr is initial.
      clear lv_stblg.
      select single stblg from bkpf
        into lv_stblg
        where bukrs = cs_out-bukrs
          and belnr = lv_db_belnr
          and gjahr = lv_gjahr.
      if sy-subrc ne 0 or lv_stblg is initial.     " belge iptal edilmemiş
        cs_out-belnr = lv_db_belnr.
        cs_out-statu = lv_db_statu.
        return.
      endif.
    endif.

*-- 2) BELNR doluyken açık statü (1-4) yazılmaz
    if cs_out-belnr is not initial
       and ( lv_statu = '1' or lv_statu = '2' or lv_statu = '3' or lv_statu = '4' ).
      if lv_db_belnr = cs_out-belnr
         and ( lv_db_statu = '5' or lv_db_statu = '7' ).
        lv_statu = lv_db_statu.
      else.
        clear: lv_xblnr, lv_tcode.
        select single xblnr tcode from bkpf
          into (lv_xblnr, lv_tcode)
          where bukrs = cs_out-bukrs
            and belnr = cs_out-belnr
            and gjahr = lv_gjahr.
        if sy-subrc = 0
           and lv_xblnr np 'EHO-*'
           and lv_tcode <> lc_eho_tcode.
          lv_statu = '7'.                             " EHO dışı belge
        else.
          lv_statu = '5'.
        endif.
      endif.
      cs_out-statu = lv_statu.
    endif.
*-------------------------------------------------------------------*

*-- Kalem tablosunu güncelle
*    update zeho_t012 set statu     = iv_statu
    update zeho_t012 set statu     = lv_statu
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
                         bschl     = cs_out-bschl
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
                                                and prtyp  = cs_out-prtyp.
*                                                and vgint  = cs_out-vgint.
    if sy-dbcnt = 0.
*-- Satır bulunamadı: sessiz geçme, logla
*      data ls_message type symsg.
      clear ls_message.
      ls_message-msgid = 'ZEHO'.
      ls_message-msgno = '052'.           " yeni mesaj: EHO kalemi güncellenemedi
      ls_message-msgty = 'E'.
      ls_message-msgv1 = cs_out-belnr.
      zeho_cl020=>collect_message( is_message = ls_message is_out = cs_out ).
    endif.

    commit work and wait.

  endmethod.
