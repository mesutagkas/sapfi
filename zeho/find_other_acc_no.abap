method find_other_acc_no.
* Types
*-------------------------------------------------------------------*
* *- Manuel muhasebeleşen kayıtların ACDOCA kontrolü
* *- added by <kullanıcı> DD.MM.YYYY HH:MM:SS
*-------------------------------------------------------------------*
  types: begin of ty_acdoca,
           rbukrs type acdoca-rbukrs,
           gjahr  type acdoca-gjahr,
           belnr  type acdoca-belnr,
           racct  type acdoca-racct,
           budat  type acdoca-budat,
           tsl    type acdoca-tsl,
           rtcur  type acdoca-rtcur,
           kunnr  type acdoca-kunnr,
           lifnr  type acdoca-lifnr,
*-------------------------------------------------------------------*
* *- EHO'dan atılan belgeyi tanımak için belge türü ve referans (BKPF)
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
           blart  type bkpf-blart,
           xblnr  type bkpf-xblnr,
           bktxt  type bkpf-bktxt,                " tam banka referansı (yeni belgeler)
*-------------------------------------------------------------------*
* *- Virman karşı bacağı: kalemin belgedeki sırası (1 = banka kalemi)
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
           buzei  type acdoca-buzei,
*-------------------------------------------------------------------*
* *- EHO'dan atıldığının izi: işlem kodu (ZEHO003)
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
           tcode  type bkpf-tcode,
*-------------------------------------------------------------------*
         end of ty_acdoca,
         begin of ty_acdoca_kun,
           rbukrs type acdoca-rbukrs,
           gjahr  type acdoca-gjahr,
           belnr  type acdoca-belnr,
           kunnr  type acdoca-kunnr,
           lifnr  type acdoca-lifnr,
         end of ty_acdoca_kun.
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- EHO'dan atılan belgeyi tanımak için BKPF referans tipi
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
  types: begin of ty_bkpf_ref,
           bukrs type bkpf-bukrs,
           belnr type bkpf-belnr,
           gjahr type bkpf-gjahr,
           blart type bkpf-blart,
           xblnr type bkpf-xblnr,
           bktxt type bkpf-bktxt,
           tcode type bkpf-tcode,                 " EHO izi - added by <kullanıcı> 09.10.2026
         end of ty_bkpf_ref.
*-------------------------------------------------------------------*

  types: begin of ty_tckn,
           taxnum type dfkkbptaxnum-taxnum,
         end of ty_tckn,
         begin of ty_tckn_vend,
           taxnum type dfkkbptaxnum-taxnum,
           vendor type cvi_vend_link-vendor,
         end of ty_tckn_vend.

  data: lt_tckn      type sorted table of ty_tckn with unique key taxnum,
        lt_tckn_vend type sorted table of ty_tckn_vend with non-unique key taxnum,
        lv_tckn      type dfkkbptaxnum-taxnum.

* Fıeld-Symbls
  field-symbols:
    <fs_out>    type zeho_s004,
    <fs_kna1_x> type ty_kna1_x,
    <fs_lfa1_x> type ty_lfa1_x,
    <fs_acdoca> type ty_acdoca.

* Structures
  data: ls_t005       type zeho_t005,
        ls_t007       type zeho_t007,
        ls_t006       type zeho_t006,
        ls_t002       type zeho_t002,
        ls_t004       type zeho_t004,
        ls_t018       type zeho_t018,
        ls_message    type symsg,
        ls_t024       like line of mt_t024,       " YENİ (IBAN bloğundan taşındı)
        ls_acdoca     type ty_acdoca,
        ls_acdoca_kun type ty_acdoca_kun.

* Tables
  data: lt_t005       type standard table of zeho_t005,
        lt_t006       type standard table of zeho_t006,
        lt_t007       type standard table of zeho_t007,
        lt_t002       type standard table of zeho_t002,
        lt_t004       type standard table of zeho_t004,
        lt_t003       type standard table of zeho_t003,
        lt_t018       type standard table of zeho_t018,
        lt_t019       type standard table of zeho_t019,
        lt_t028       type standard table of zeho_t028,
        lt_kna1       type sorted table of kna1 with unique key kunnr,
        lt_knb1       type sorted table of knb1 with unique key kunnr bukrs,
        lt_lfa1       type sorted table of lfa1 with unique key lifnr,
        lt_lfb1       type sorted table of lfb1 with unique key lifnr bukrs,
        lt_kna1_x     type sorted table of ty_kna1_x with unique key kunnr,
        lt_lfa1_x     type sorted table of ty_lfa1_x with unique key lifnr,
        lt_knbk       type zeho_tt011,
        lt_lfbk       type zeho_tt012,
        lt_tiban      type zeho_tt009,
        lt_out_ref1   type zeho_tt004,
        lt_out_ref2   type zeho_tt004,
        lt_acdoca     type standard table of ty_acdoca,
        lt_acdoca_kun type standard table of ty_acdoca_kun.

* Variables
  data: lv_subrc       type sy-subrc,
        lv_butxt       type zeho_s004-butxt,
        lv_index       type sy-fdpos,
        lv_index_dschr type i,
        lv_tabix       type sy-tabix,
        lv_tsl         type acdoca-tsl,
        lv_found       type abap_bool,
        lv_tckn_count  type i,
        lv_count       type i.


  constants: return_keyword    type string value 'iade',
             return_keyword_tr type string value 'İADE'.
  data: is_return      type abap_bool,
        is_customer_mv type abap_bool.

*-------------------------------------------------------------------*
* *- EHO'dan atılan belgeyi tanımak için değişkenler
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
  data: lt_bkpf_ref  type sorted table of ty_bkpf_ref with unique key bukrs belnr gjahr,
        ls_bkpf_ref  type ty_bkpf_ref,
        lv_xblnr_eho type bkpf-xblnr,
        lv_bktxt_eho type bkpf-bktxt,
        lv_own_doc   type abap_bool,
        lv_first_idx type sy-tabix.
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- BELNR dolu gelen satırın belgesini kontrol için
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
  data: ls_bkpf_chk  type ty_bkpf_ref,
        lv_gjahr_chk type bkpf-gjahr.
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- DB'deki güncel statü / belge numarası (başka oturumda
* *- muhasebeleşmiş satırın eski haliyle ezilmemesi için)
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
  types: begin of ty_db_state,
           seqnr type zeho_t012-seqnr,
           bukrs type zeho_t012-bukrs,
           bankc type zeho_t012-bankc,
           statu type zeho_t012-statu,
           belnr type zeho_t012-belnr,
         end of ty_db_state.
  data: lt_db_state type sorted table of ty_db_state
                    with non-unique key seqnr bukrs bankc,
        ls_db_state type ty_db_state.
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- Virman karşı bacağı / belge-satır bağları
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
  types: begin of ty_link,
           bukrs type zeho_t012-bukrs,
           belnr type zeho_t012-belnr,
           hkont type zeho_t012-hkont,
           seqnr type zeho_t012-seqnr,
         end of ty_link,
         begin of ty_heal_line,
           rbukrs type acdoca-rbukrs,
           gjahr  type acdoca-gjahr,
           belnr  type acdoca-belnr,
           racct  type acdoca-racct,
           buzei  type acdoca-buzei,
         end of ty_heal_line.
  data: lt_link       type sorted table of ty_link with non-unique key belnr hkont,
        lt_heal_key   type standard table of ty_bkpf_ref,
        lt_heal_line  type standard table of ty_heal_line,
        ls_heal_line  type ty_heal_line,
        lv_skip       type abap_bool,
        lv_heal       type abap_bool,
        lv_cand_idx   type sy-tabix,
        lv_link_seqnr type zeho_t012-seqnr.
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- SSH İade süreci
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
*-- Metin normalizasyonu (regex kullanılmıyor: POSIX regex bazı metinlerde
*-- CX_SY_REGEX_TOO_COMPLEX dump'ı veriyordu). Eşleme çiftleri:
*-- İ→I, ı→I, Ş→S, ş→S ve - ( ) : . / → boşluk
  constants: lc_norm_map  type string value `İIıIŞSşS- ( ) : . / `,
             lc_ssh_xref3 type xref3  value '2301.SSH',
             lc_ssh_bukrs type bukrs  value '1000'.
  data: lv_norm          type string,
        lv_txt_part      type string,
        lv_tok           type string,
        lt_tok           type standard table of string,
        lv_moff          type i,
        lv_loff          type i,
        lv_mlen          type i,
        lv_ssh_kunnr_txt type string,
        lv_ssh_kunnr     type kna1-kunnr,
        lv_ssh_check     type kna1-kunnr.
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- Showroom iade süreci
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
  constants: lc_shw_blart type blart  value 'MN'.
*-------------------------------------------------------------------*
* *- EHO muhasebeleştirme işlem kodu (belgenin EHO'dan atıldığının izi)
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
  constants: lc_eho_tcode type bkpf-tcode value 'ZEHO003'.
*-------------------------------------------------------------------*
  data: lv_shw_found     type abap_bool,
        lv_shw_vbeln_txt type string,
        lv_shw_vbeln     type vbak-vbeln,
        lv_shw_kunnr     type vbak-kunnr,
        lv_shw_anlasma   type vbak-zzanlasma,
        lv_shw_prctr     type vbap-prctr.
*-------------------------------------------------------------------*

****************************************-- OPEN --*********************************************
******************************-- UYARLAMADAN DAN CARİ/HESAP ARAMA  --**************************

  if ct_out is not initial.

*-------------------------------------------------------------------*
* *- Ekrandaki satırlar başka bir oturumda muhasebeleşmiş olabilir.
* *- Bellekte BELNR boş ama DB'de doluysa DB'deki değer alınıyor;
* *- aksi halde update_bank_item eski hali (statü 4, BELNR boş) DB'ye
* *- yazıp belge bağını koparıyordu.
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
    free lt_db_state.
    select seqnr bukrs bankc statu belnr
      from zeho_t012
      into table lt_db_state
      for all entries in ct_out
      where seqnr = ct_out-seqnr
        and bukrs = ct_out-bukrs
        and bankc = ct_out-bankc.

    loop at ct_out assigning <fs_out> where belnr is initial.
      read table lt_db_state into ls_db_state
           with table key seqnr = <fs_out>-seqnr
                          bukrs = <fs_out>-bukrs
                          bankc = <fs_out>-bankc.
      if sy-subrc = 0 and ls_db_state-belnr is not initial.
        <fs_out>-belnr = ls_db_state-belnr.
        <fs_out>-statu = ls_db_state-statu.
      endif.
    endloop.
*-------------------------------------------------------------------*

    free mt_t024.
    select * from zeho_t024
      into corresponding fields of table mt_t024.       "#EC CI_NOWHERE

*-- Şirket parametreleri
    free lt_t028 .
    select * from zeho_t028 into table lt_t028 .

*-- Şirketler arası para transferi ise 102 ye karşı çalışcak 102 yi bul...
    free lt_t002.
    select * from zeho_t002 into table lt_t002.         "#EC CI_NOWHERE

*-- Banka ya Tanımlı İşlem kodları bulunması
    free lt_t004.
    select * from zeho_t004 into table lt_t004
    for all entries in ct_out
    where bankc = ct_out-bankc
    and   vgext = ct_out-vgext.

*-- Banka ya karşı çalışacak hesap ı bul banka hesap eşleşmesi.
    free lt_t005.
    select * from zeho_t005 into table lt_t005
    for all entries in ct_out
    where bankc = ct_out-bankc
    and   bukrs = ct_out-bukrs
    and   hbkid = ct_out-hbkid
    and   hktid = ct_out-hktid
    and   vgint = ct_out-vgint.

*-- Banka ya karşı çalışacak hesap ı bul cari bazlı hesap eşleşmesi.
    free lt_t006.
    select * from zeho_t006 into table lt_t006
    for all entries in ct_out
    where bankc = ct_out-bankc
    and   bukrs = ct_out-bukrs
    and   vgint = ct_out-vgint.

*-- Bankaya karşı çalışacak hesabı bul istisna tablosu
    free lt_t007.
    select * from zeho_t007 into table lt_t007
    for all entries in ct_out
    where bankc = ct_out-bankc
    and   bukrs = ct_out-bukrs
    and   vgint = ct_out-vgint.

*-- Aktif carileri bul
    free lt_t018.
    select * from zeho_t018 into table lt_t018
    for all entries in ct_out
    where bankc = ct_out-bankc
    and   bukrs = ct_out-bukrs
    and   vgint = ct_out-vgint.

    free lt_t019.
    select * from zeho_t019 into table lt_t019
    for all entries in ct_out
    where iban  = ct_out-iban.

*-------------------------------------------------------------------*
* *- Manuel muhasebeleşen kayıtlar için ACDOCA okunuyor
* *- added by <kullanıcı> DD.MM.YYYY HH:MM:SS
*-------------------------------------------------------------------*
    free: lt_acdoca, lt_acdoca_kun.

*-- Banka satırları
*-------------------------------------------------------------------*
* *- Kalem sırası (BUZEI) da okunuyor: virman karşı bacağı tespiti
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
*    select rbukrs gjahr belnr racct budat tsl rtcur
    select rbukrs gjahr belnr buzei racct budat tsl rtcur
*-------------------------------------------------------------------*
      from acdoca
      into corresponding fields of table lt_acdoca
      for all entries in ct_out
      where rldnr      = '0L'
        and rbukrs     = ct_out-bukrs
        and racct      = ct_out-hkont
        and budat      = ct_out-prdat
        and xreversing = space
        and xreversed  = space.

    if lt_acdoca is not initial.
*-- Aynı belgelerin müşteri satırları
      select rbukrs gjahr belnr kunnr lifnr
        from acdoca
        into table lt_acdoca_kun
        for all entries in lt_acdoca
        where rldnr  = '0L'
          and rbukrs = lt_acdoca-rbukrs
          and gjahr  = lt_acdoca-gjahr
          and belnr  = lt_acdoca-belnr
           and ( kunnr <> space or lifnr <> space ).
      sort lt_acdoca_kun by rbukrs gjahr belnr.

*-------------------------------------------------------------------*
* *- EHO'dan atılan belgeyi tanımak için BKPF referansı
* *- (ACDOCA'da XBLNR / TCODE yok, BKPF'ten okunuyor)
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
      free lt_bkpf_ref.
*      select bukrs belnr gjahr blart xblnr bktxt
      select bukrs belnr gjahr blart xblnr bktxt tcode   " TCODE - added by <kullanıcı> 09.10.2026
        from bkpf
        into table lt_bkpf_ref
        for all entries in lt_acdoca
        where bukrs = lt_acdoca-rbukrs
          and belnr = lt_acdoca-belnr
          and gjahr = lt_acdoca-gjahr.
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- Adaylardan hangileri zaten bir EHO satırına bağlı? Aynı banka
* *- hesabındaki başka bir satıra bağlı belge bu satıra verilmez.
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
      free lt_link.
      select bukrs belnr hkont seqnr
        from zeho_t012
        into table lt_link
        for all entries in lt_acdoca
        where bukrs = lt_acdoca-rbukrs
          and belnr = lt_acdoca-belnr.
*-------------------------------------------------------------------*

*-- Müşteri / satıcıyı banka satırına taşı
      loop at lt_acdoca assigning <fs_acdoca>.
        read table lt_acdoca_kun into ls_acdoca_kun
             with key rbukrs = <fs_acdoca>-rbukrs
                      gjahr  = <fs_acdoca>-gjahr
                      belnr  = <fs_acdoca>-belnr
             binary search.
        if sy-subrc = 0.
          <fs_acdoca>-kunnr = ls_acdoca_kun-kunnr.
          <fs_acdoca>-lifnr = ls_acdoca_kun-lifnr.
        endif.

*-------------------------------------------------------------------*
* *- Belge türü ve referansı banka satırına taşınıyor
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
        read table lt_bkpf_ref into ls_bkpf_ref
             with table key bukrs = <fs_acdoca>-rbukrs
                            belnr = <fs_acdoca>-belnr
                            gjahr = <fs_acdoca>-gjahr.
        if sy-subrc = 0.
          <fs_acdoca>-blart = ls_bkpf_ref-blart.
          <fs_acdoca>-xblnr = ls_bkpf_ref-xblnr.
          <fs_acdoca>-bktxt = ls_bkpf_ref-bktxt.
          <fs_acdoca>-tcode = ls_bkpf_ref-tcode.     " added by <kullanıcı> 09.10.2026
        endif.
*-------------------------------------------------------------------*
      endloop.

      sort lt_acdoca by rbukrs racct budat tsl rtcur.
    endif.

*    -------------------------------------------------------------------*
* *- İcra ödemeleri: metindeki TC kimlik no ile personel satıcısı bulunuyor
* *- added by <kullanıcı> DD.MM.YYYY HH:MM:SS
*-------------------------------------------------------------------*magkas
*    loop at ct_out assigning <fs_out> where manuel = abap_false.
*      clear lv_tckn.
*      find first occurrence of regex 'K[İI]ML[İI]K\D*(\d{10,11})'
*           in <fs_out>-butxt                   " kalem metni alanı
*           submatches lv_tckn.
*      if sy-subrc = 0.
*        insert value #( taxnum = lv_tckn ) into table lt_tckn.
*      endif.
*    endloop.
*
*    if lt_tckn is not initial.
*      select t~taxnum, l~vendor
*        from dfkkbptaxnum as t
*        inner join but000        as b on b~partner      = t~partner
*        inner join cvi_vend_link as l on l~partner_guid = b~partner_guid
*        for all entries in @lt_tckn
*        where t~taxnum = @lt_tckn-taxnum
*        into table @lt_tckn_vend.
*    endif.
*-------------------------------------------------------------------*

    loop at ct_out assigning <fs_out> where ( statu  = cv_01
                                        or    statu  = cv_02
                                        or    statu  = cv_03
                                        or    statu  = cv_04 )
*                                        OR    statu  = cv_06 )
                                        and   manuel = abap_false.

      if <fs_out>-belnr is not initial.
*-- Muhasebeleşmiş ama statüsü güncellenmemiş
*        <fs_out>-statu = cv_05.
*-------------------------------------------------------------------*
* *- BELNR doluysa belge kontrol ediliyor. Önceden belge kimden atılmış
* *- olursa olsun statü 5 veriliyordu; EHO dışından atılan belge de 5
* *- görünüyordu. EHO'dan atılmışsa (XBLNR 'EHO-*' ya da işlem kodu
* *- ZEHO003) statü 5, değilse 7. Belge bulunamazsa eski davranış (5).
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
        clear ls_bkpf_chk.
        lv_gjahr_chk = <fs_out>-prdat+0(4).
        select single bukrs belnr gjahr blart xblnr bktxt tcode
          from bkpf
          into ls_bkpf_chk
          where bukrs = <fs_out>-bukrs
            and belnr = <fs_out>-belnr
            and gjahr = lv_gjahr_chk.
        if sy-subrc = 0
           and ls_bkpf_chk-xblnr np 'EHO-*'
           and ls_bkpf_chk-tcode <> lc_eho_tcode.
          <fs_out>-statu = '7'.                         " EHO dışı belge
        else.
          <fs_out>-statu = cv_05.
        endif.
*-------------------------------------------------------------------*


      else.
*-- Şirket kodunda karşı hesap arama etkin ??
        data: ls_t028 like line of lt_t028.
        read table lt_t028 into ls_t028 with key bukrs = <fs_out>-bukrs .

        if sy-subrc eq 0 and ls_t028-faccn eq 'X' .

          clear: <fs_out>-blart,
                 <fs_out>-bschl,
                 <fs_out>-saknr,
                 <fs_out>-kunnr,
                 <fs_out>-lifnr,
                 <fs_out>-kostl,
                 <fs_out>-mwskz,
                 <fs_out>-aufnr,
                 <fs_out>-pspel,
                 <fs_out>-umskz,
                 <fs_out>-gsber,
                 <fs_out>-gsber_2,
                 <fs_out>-kosak.

**-- open :  İstisna kontrolü
          if  ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
           or ( iv_fiori eq abap_true ).
            call method zeho_cl020=>check_exit
              exporting
                it_t005 = lt_t005[]
                it_t006 = lt_t006[]
                it_t007 = lt_t007[]
                it_t018 = lt_t018[]
              changing
                ch_out  = <fs_out>.
          endif.
**-- closed : İstisna kontrolü!!!

**-- open : özel koşul tablosuna  ara!!!
          sort lt_t007 ascending by bankc bukrs hbkid hktid vgint protp seqnr.
          sort lt_t007 descending by seqnr.
          call method zeho_cl020=>check_t007
            exporting
              it_t007 = lt_t007[]
            changing
              ch_out  = <fs_out>.
**-- closed : özel koşul tablosuna ara!!!

*-------------------------------------------------------------------*
* *- SSH / Showroom iade için normalize metin: büyük harf, Türkçe
* *- karakterler sade (İ/ı→I, Ş→S), - ( ) : . / boşluk, tek boşluk
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
          lv_norm = <fs_out>-butxt.
          translate lv_norm to upper case.
          translate lv_norm using lc_norm_map.
          condense lv_norm.
*-------------------------------------------------------------------*

**-- Open : SSH İade - metindeki müşteri kodu ile müşteri bul
*-------------------------------------------------------------------*
* *- SSH İade süreci: kalem metninde "<müşteri kodu>-SSH İade" geçiyorsa
* *- (büyük/küçük harf, boşluk ve tire farkları tolere edilir) müşteri
* *- kodu şirket 1000 için KNB1'de varsa müşteri alanına yazılır,
* *- bağlantı anlaşması (XREF3) 2301.SSH olarak gelir.
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
          if ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true ).
            if <fs_out>-bukrs eq lc_ssh_bukrs.
              clear: lv_ssh_kunnr_txt, lv_ssh_kunnr, lv_ssh_check.
*-- "SSH İADE" işaretinin hemen önündeki kelime müşteri kodu
              find first occurrence of 'SSH IADE' in lv_norm match offset lv_moff.
              if sy-subrc ne 0.
                find first occurrence of 'SSHIADE' in lv_norm match offset lv_moff.
              endif.
              if sy-subrc eq 0 and lv_moff > 0.
                lv_txt_part = lv_norm(lv_moff).
                condense lv_txt_part.
                clear lt_tok.
                split lv_txt_part at space into table lt_tok.
                read table lt_tok into lv_tok index lines( lt_tok ).
                if sy-subrc eq 0 and lv_tok is not initial and lv_tok co '0123456789'.
                  lv_ssh_kunnr_txt = lv_tok.
                endif.
              endif.
              if lv_ssh_kunnr_txt is not initial.
*-- Baştaki sıfırlar atılıp uzunluk kontrol ediliyor (müşteri no en fazla 10 hane)
                shift lv_ssh_kunnr_txt left deleting leading '0'.
                if lv_ssh_kunnr_txt is not initial and strlen( lv_ssh_kunnr_txt ) le 10.
                  lv_ssh_kunnr = lv_ssh_kunnr_txt.
                  call function 'CONVERSION_EXIT_ALPHA_INPUT'
                    exporting
                      input  = lv_ssh_kunnr
                    importing
                      output = lv_ssh_kunnr.

                  select single kunnr from knb1
                    into lv_ssh_check
                    where kunnr = lv_ssh_kunnr
                      and bukrs = <fs_out>-bukrs.
                  if sy-subrc eq 0.
                    clear: <fs_out>-lifnr, <fs_out>-saknr.
                    <fs_out>-kunnr = lv_ssh_kunnr.
                    <fs_out>-koart = 'D'.
                    <fs_out>-xref3 = lc_ssh_xref3.
                    if <fs_out>-blart is initial.
                      read table mt_t024 into ls_t024 with key koart = 'D'
                                                               protp = <fs_out>-prtyp.
                      if sy-subrc eq 0.
                        <fs_out>-blart = ls_t024-blart.
                      endif.
                    endif.
                    <fs_out>-statu = '4'.
                  endif.
                endif.
              endif.
            endif.
          endif.
*-------------------------------------------------------------------*
**-- Closed : SSH İade

**-- Open : Showroom iade - metindeki sipariş no ile müşteri bul
*-------------------------------------------------------------------*
* *- Showroom iade: kalem metninde "SHOWROOM İADE" / "SHW İADE" geçiyorsa
* *- sipariş no önce "SİP NO / SİPARİŞ NO" etiketinden, yoksa "SHW İADE"
* *- öncesindeki sayıdan alınır. Örnekler:
* *-   "SİPARİŞ NO : (11568726 SHW İADE )"
* *-   "Havale Ücreti ... showroom iade-Sip no:1500251162"
* *- (büyük/küçük harf, boşluk, tire farkları tolere edilir) Sipariş no
* *- 10 haneye tamamlanıp: VBAK-KUNNR → müşteri, VBAK-ZZANLASMA → bağlantı
* *- anlaşması (XREF3), VBAP-PRCTR → kâr merkezi, belge türü MN.
* *- Sipariş no muhasebeleştirmede bapi_receivable'da REF_KEY_2'ye yazılır.
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
          if ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true ).
            clear: lv_shw_found, lv_shw_vbeln_txt, lv_shw_vbeln, lv_shw_kunnr, lv_shw_anlasma, lv_shw_prctr.
*-- Showroom iade işareti
            find first occurrence of 'SHOWROOM IADE' in lv_norm match offset lv_moff.
            if sy-subrc ne 0.
              find first occurrence of 'SHOWROOMIADE' in lv_norm match offset lv_moff.
            endif.
            if sy-subrc ne 0.
              find first occurrence of 'SHW IADE' in lv_norm match offset lv_moff.
            endif.
            if sy-subrc ne 0.
              find first occurrence of 'SHWIADE' in lv_norm match offset lv_moff.
            endif.
            if sy-subrc eq 0.
              lv_shw_found = abap_true.
            endif.

            if lv_shw_found eq abap_true.
*-- 1) "SİPARİŞ NO / SİP NO" etiketinden sonraki ilk kelime
              find first occurrence of 'SIPARIS NO' in lv_norm match offset lv_loff match length lv_mlen.
              if sy-subrc ne 0.
                find first occurrence of 'SIPARISNO' in lv_norm match offset lv_loff match length lv_mlen.
              endif.
              if sy-subrc ne 0.
                find first occurrence of 'SIP NO' in lv_norm match offset lv_loff match length lv_mlen.
              endif.
              if sy-subrc ne 0.
                find first occurrence of 'SIPNO' in lv_norm match offset lv_loff match length lv_mlen.
              endif.
              if sy-subrc eq 0.
                lv_loff = lv_loff + lv_mlen.
                lv_txt_part = lv_norm+lv_loff.
                condense lv_txt_part.
                clear lt_tok.
                split lv_txt_part at space into table lt_tok.
                read table lt_tok into lv_tok index 1.
                if sy-subrc eq 0 and lv_tok is not initial and lv_tok co '0123456789'.
                  lv_shw_vbeln_txt = lv_tok.
                endif.
              endif.

*-- 2) Etiket yoksa "SHW İADE" işaretinin hemen önündeki kelime
              if lv_shw_vbeln_txt is initial and lv_moff > 0.
                lv_txt_part = lv_norm(lv_moff).
                condense lv_txt_part.
                clear lt_tok.
                split lv_txt_part at space into table lt_tok.
                read table lt_tok into lv_tok index lines( lt_tok ).
                if sy-subrc eq 0 and lv_tok is not initial and lv_tok co '0123456789'.
                  lv_shw_vbeln_txt = lv_tok.
                endif.
              endif.
            endif.

            if lv_shw_vbeln_txt is not initial.
*-- Baştaki sıfırlar atılıp uzunluk kontrol ediliyor (sipariş no en fazla 10 hane)
              shift lv_shw_vbeln_txt left deleting leading '0'.
              if lv_shw_vbeln_txt is not initial and strlen( lv_shw_vbeln_txt ) le 10.
                lv_shw_vbeln = lv_shw_vbeln_txt.
                call function 'CONVERSION_EXIT_ALPHA_INPUT'
                  exporting
                    input  = lv_shw_vbeln
                  importing
                    output = lv_shw_vbeln.

                select single kunnr zzanlasma
                  from vbak
                  into (lv_shw_kunnr, lv_shw_anlasma)
                  where vbeln = lv_shw_vbeln.
                if sy-subrc eq 0 and lv_shw_kunnr is not initial.

*-- Kâr merkezi: siparişin kâr merkezi dolu ilk kalemi
                  select prctr
                    from vbap
                    into lv_shw_prctr
                    up to 1 rows
                    where vbeln = lv_shw_vbeln
                      and prctr ne space
                    order by posnr.
                  endselect.

                  clear: <fs_out>-lifnr, <fs_out>-saknr.
                  <fs_out>-kunnr = lv_shw_kunnr.
                  <fs_out>-koart = 'D'.
                  <fs_out>-xref3 = lv_shw_anlasma.
                  <fs_out>-prctr = lv_shw_prctr.
                  <fs_out>-blart = lc_shw_blart.
                  <fs_out>-statu = '4'.
                endif.
              endif.
            endif.
          endif.
*-------------------------------------------------------------------*
**-- Closed : Showroom iade

*      **-- Open : İcra ödemesi - TC kimlik no ile personel satıcısı-----magkas
*          if <fs_out>-kunnr is initial and <fs_out>-lifnr is initial
*             and <fs_out>-saknr is initial and lt_tckn_vend is not initial.
*            clear: lv_tckn, lv_tckn_count.
*            find first occurrence of regex 'T\.?\s*C\.?\s*K[İI]ML[İI]K\D*(\d{10,11})'
*                 in <fs_out>-butxt                   " kalem metni alanı
*                 submatches lv_tckn.
*            if sy-subrc = 0.
**-- Bu TC ile kaç personel eşleşiyor?
*              loop at lt_tckn_vend into data(ls_tckn_vend)
*                   where taxnum = lv_tckn.
*                lv_tckn_count = lv_tckn_count + 1.
*              endloop.
*
*              if lv_tckn_count = 1.
**-- Tek personel: otomatik ata
*                <fs_out>-lifnr = ls_tckn_vend-vendor.
*                if <fs_out>-blart is initial.
*                  read table mt_t024 into ls_t024 with key koart = 'K'
*                                                           protp = <fs_out>-prtyp.
*                  if sy-subrc = 0.
*                    <fs_out>-blart = ls_t024-blart.
*                  endif.
*                endif.
*              elseif lv_tckn_count > 1.
**-- Birden fazla personel: atama yapılmaz, kullanıcı manuel girer
*                ls_message-msgid = 'ZEHO'.
*                ls_message-msgno = '050'.     " TC kimlik no ile birden fazla personel bulundu, cariyi manuel giriniz
*                ls_message-msgty = 'W'.
*                zeho_cl020=>collect_message( is_message = ls_message is_out = <fs_out> ).
*              endif.
*            endif.
*          endif.
**-- Closed : İcra ödemesi

**-- Open : aktif cari tablosunda ara!!!
          if  ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true ).
            call method zeho_cl020=>check_t006
              exporting
                it_t006 = lt_t006[]
              changing
                ch_out  = <fs_out>.
          endif.
**-- Closed : aktif cari tablosunda ara!!!

**-- Open : banka hesap eşleşmesi tablosunda ara!!!
          if ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true ).
            call method zeho_cl020=>check_t005
              exporting
                it_t005 = lt_t005[]
              changing
                ch_out  = <fs_out>.
          endif.
**-- Closed : banka hesap eşleşmesi tablosunda ara!!!

**-- Open : Banka Tanımlarını kontrol et
          if ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true ).
            call method zeho_cl020=>check_t018
              exporting
                it_t018 = lt_t018[]
              changing
                ch_out  = <fs_out>.
          endif.
**-- Closed : Banka Tanımlarını kontrol et

**-- Open : Banka Tanımlarını kontrol et
          if ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true ).
            call method zeho_cl020=>check_t019
              exporting
                it_t019 = lt_t019[]
              changing
                ch_out  = <fs_out>.
          endif.
**-- Closed : Banka Tanımlarını kontrol et

**-- Open : IBAN ile şirket banka hesabı
          if ( <fs_out>-saknr is initial and <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true ).
            if <fs_out>-iban is not initial.
              data: ls_t002_iban type zeho_t002.
              select single * from zeho_t002 into ls_t002_iban
               where iban = <fs_out>-iban.
              if sy-subrc eq 0.
                <fs_out>-saknr = ls_t002_iban-hkont.
                <fs_out>-gsber = ls_t002_iban-gsber.
                if <fs_out>-blart is initial .
*                  data ls_t024 like line of mt_t024.
                  read table mt_t024 into ls_t024 with key koart = 'S'
                                                           protp = <fs_out>-prtyp.
                  if sy-subrc eq 0.
                    <fs_out>-blart   = ls_t024-blart.
                  endif.
                endif.
                <fs_out>-statu = '4'.
              endif.
            endif.
          endif.
**-- closed : IBAN ile şirket banka hesabı

**-- Open : LFA1, KNA1 tablolarından VKN ile satıcı veya müşteri bul
          if ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true and <fs_out>-txt50 is initial ).


            is_return = xsdbool( <fs_out>-butxt cs return_keyword
                             or <fs_out>-butxt cs return_keyword_tr ).

            is_customer_mv = xsdbool(
                 ( <fs_out>-prtyp = '+' and is_return = abap_false )     " tahsilat
              or ( <fs_out>-prtyp = '-' and is_return = abap_true ) ).   " müşteriye iade

            if is_customer_mv = abap_true.
              " Müşteri
              zeho_cl020=>check_kna1( changing ch_out = <fs_out> ).
            else.
              " Satıcı
              zeho_cl020=>check_lfa1( changing ch_out = <fs_out> ).
            endif.

*            if <fs_out>-prtyp = '+'.
*              " Müşteri
*              call method zeho_cl020=>check_kna1
*                changing
*                  ch_out = <fs_out>.
*            else.
*              " Satıcı
*              call method zeho_cl020=>check_lfa1
*                changing
*                  ch_out = <fs_out>.
*            endif.

            if <fs_out>-kunnr is not initial or <fs_out>-lifnr is not initial or <fs_out>-saknr is not initial and <fs_out>-statu ne '6'.
              <fs_out>-statu = '4'.
            else.
              <fs_out>-statu = '2'.
            endif.
          endif.
**-- Closed : LFA1, KNA1 tablolarından VKN ile satıcı veya müşteri bul

**-- open : tiban tablosundan iban ile müşteri veya satıcı bul
          if ( <fs_out>-kunnr is initial and <fs_out>-lifnr is initial and <fs_out>-saknr is initial and <fs_out>-statu ne '6' and iv_fiori eq space )
          or ( iv_fiori eq abap_true ).
            call method zeho_cl020=>check_tiban
              changing
                ch_out = <fs_out>.
          endif.
**-- Closed : TIBAN tablosundan IBAN ile müşteri veya satıcı bul

**-- open : Mutabakat Hesabını bulma
          data lv_check(1).
          clear lv_check.                                 " önceki satırdan kalmasın

          if <fs_out>-kunnr is not initial.
            lv_check = 'D'.
          elseif <fs_out>-lifnr is not initial .
            lv_check = 'K'.
          endif.
          if lv_check is not initial.
            call method zeho_cl020=>check_account
              exporting
                iv_check = lv_check                " Müşteri (D) , Satıcı (K)
              changing
                ch_out   = <fs_out>.
          endif.
**-- Closed : Mutabakat Hesabını bulma

**-- Open : Banka işlem kodu karşılıkları
          if <fs_out>-vgint is initial.
            call method zeho_cl020=>check_t004
              exporting
                it_t004 = lt_t004[]
              changing
                ch_out  = <fs_out>.
          endif.
**-- Closed : Banka işlem kodu karşılıkları.

*-------------------------------------------------------------------*
* *- Manuel muhasebeleşmiş kayıt kontrolü (müşteri bulunduktan sonra)
* *- added by <kullanıcı> DD.MM.YYYY HH:MM:SS
*-------------------------------------------------------------------*
          clear: lv_found, lv_count.
          lv_tsl = cond #( when <fs_out>-prtyp = '+' then abs( <fs_out>-amount )
                           else abs( <fs_out>-amount ) * -1 ).

*-------------------------------------------------------------------*
* *- Bu satırdan EHO ile atılan belgenin referansı (bapi_header ile aynı)
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
          clear: lv_tabix, lv_first_idx, lv_xblnr_eho, lv_bktxt_eho.
          lv_xblnr_eho = 'EHO-' && <fs_out>-refbk.  " 16 karaktere kesilir
          lv_bktxt_eho = <fs_out>-refbk.            " tam banka referansı
*-------------------------------------------------------------------*

*-- Aynı hesap/tarih/tutar/para birimindeki ilk aday
          read table lt_acdoca transporting no fields
               with key rbukrs = <fs_out>-bukrs
                        racct  = <fs_out>-hkont
                        budat  = <fs_out>-prdat
                        tsl    = lv_tsl
                        rtcur  = <fs_out>-waers
               binary search.

          if sy-subrc = 0.
*-------------------------------------------------------------------*
* *- Önce bu satırdan EHO ile atılmış belgeyi ara (kesin eşleşme).
* *- Cari türetmesi belgeden farklı olsa da kendi belgesi bulunur.
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
            lv_first_idx = sy-tabix.

            loop at lt_acdoca into ls_acdoca from lv_first_idx.
              if ls_acdoca-rbukrs <> <fs_out>-bukrs or
                 ls_acdoca-racct  <> <fs_out>-hkont or
                 ls_acdoca-budat  <> <fs_out>-prdat or
                 ls_acdoca-tsl    <> lv_tsl         or
                 ls_acdoca-rtcur  <> <fs_out>-waers.
                exit.                                     " adaylar bitti
              endif.

*-------------------------------------------------------------------*
* *- Aynı banka hesabındaki başka bir satıra bağlı belge atlanır
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
              lv_cand_idx = sy-tabix.                     " iç döngüden önce saklanıyor
              clear lv_skip.
              loop at lt_link transporting no fields
                   where belnr = ls_acdoca-belnr
                     and hkont = <fs_out>-hkont
                     and seqnr <> <fs_out>-seqnr.
                lv_skip = abap_true.
                exit.
              endloop.
              if lv_skip = abap_true.
                continue.
              endif.
*-------------------------------------------------------------------*

*-- Yeni belge: başlık metni = tam referans. Eski belge (BKTXT boş): XBLNR.
*              if ( ls_acdoca-bktxt is not initial and ls_acdoca-bktxt = lv_bktxt_eho )
*              or ( ls_acdoca-bktxt is initial     and ls_acdoca-xblnr = lv_xblnr_eho ).
*-------------------------------------------------------------------*
* *- Kendi belgesi sayılmak için:
* *- - belge EHO'dan atılmış olmalı (XBLNR 'EHO-*' ya da işlem kodu
* *-   ZEHO003); elle atılan belgenin başlık metnine de banka
* *-   referansı yazılabiliyor
* *- - banka referansı dolu olmalı (boşsa 'EHO-' her boş referanslı
* *-   satırın belgesiyle eşleşir)
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
              if <fs_out>-refbk is not initial
                 and ( ls_acdoca-xblnr cp 'EHO-*' or ls_acdoca-tcode = lc_eho_tcode )
                 and ( ( ls_acdoca-bktxt is not initial and ls_acdoca-bktxt = lv_bktxt_eho )
                    or ( ls_acdoca-bktxt is initial     and ls_acdoca-xblnr = lv_xblnr_eho ) ).
*-------------------------------------------------------------------*
                lv_tabix = lv_cand_idx.
                lv_found = abap_true.
                exit.
              endif.
            endloop.

*-- Kendi EHO belgesi yoksa mevcut mantık: müşteriye/satıcıya göre seç
            if lv_found = abap_false.
*-- Adayları dolaş, müşteriye göre seç
*            loop at lt_acdoca into ls_acdoca from sy-tabix.
              loop at lt_acdoca into ls_acdoca from lv_first_idx.
                if ls_acdoca-rbukrs <> <fs_out>-bukrs or
                   ls_acdoca-racct  <> <fs_out>-hkont or
                   ls_acdoca-budat  <> <fs_out>-prdat or
                   ls_acdoca-tsl    <> lv_tsl         or
                   ls_acdoca-rtcur  <> <fs_out>-waers.
                  exit.                                   " adaylar bitti
                endif.

*-------------------------------------------------------------------*
* *- Aday olamayacak belgeler atlanır:
* *- - aynı banka hesabındaki başka bir satıra bağlı belge
* *- - başka bir EHO hareketinin kendi banka kalemi (EHO belgesi ve
* *-   1. kalem): o hareketin belgesidir, bu satırın değil
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
                lv_cand_idx = sy-tabix.                   " iç döngüden önce saklanıyor
                clear lv_skip.
                loop at lt_link transporting no fields
                     where belnr = ls_acdoca-belnr
                       and hkont = <fs_out>-hkont
                       and seqnr <> <fs_out>-seqnr.
                  lv_skip = abap_true.
                  exit.
                endloop.
                if lv_skip = abap_false
                   and ls_acdoca-xblnr cp 'EHO-*'
                   and ls_acdoca-buzei = '001'.
                  lv_skip = abap_true.
                endif.
                if lv_skip = abap_true.
                  continue.
                endif.
*-------------------------------------------------------------------*

                if <fs_out>-kunnr is not initial.
                  if ls_acdoca-kunnr = <fs_out>-kunnr.    " müşteri tutuyor
*                    lv_tabix = sy-tabix.
                    lv_tabix = lv_cand_idx.
                    lv_found = abap_true.
                    exit.
                  endif.
                elseif <fs_out>-lifnr is not initial.
                  if ls_acdoca-lifnr = <fs_out>-lifnr.    " satıcı tutuyor
*                    lv_tabix = sy-tabix.
                    lv_tabix = lv_cand_idx.
                    lv_found = abap_true.
                    exit.
                  endif.
                else.
                  lv_count = lv_count + 1.                " cari yok: adayları say
*                  lv_tabix = sy-tabix.
                  lv_tabix = lv_cand_idx.
                endif.
              endloop.

*-- Cari bulunamadıysa sadece tek aday varsa kabul et
              if <fs_out>-kunnr is initial and <fs_out>-lifnr is initial
                 and lv_count = 1.
                lv_found = abap_true.
              endif.
            endif.                                        " lv_found = abap_false
*-------------------------------------------------------------------*
          endif.

          if lv_found = abap_true.
            read table lt_acdoca into ls_acdoca index lv_tabix.
            <fs_out>-belnr = ls_acdoca-belnr.

            if <fs_out>-kunnr is initial and <fs_out>-lifnr is initial.
              <fs_out>-kunnr = ls_acdoca-kunnr.           " cariyi belgeden al
              <fs_out>-lifnr = ls_acdoca-lifnr.
            endif.
*            <fs_out>-statu = '7'.
*-------------------------------------------------------------------*
* *- Belge bu satırdan EHO ile atılmışsa EHO dışı (7) değil,
* *- muhasebeleşmiş (5). Statü 5 muhasebeleştirme sırasında
* *- yazılamamış demektir; burada tamamlanıyor.
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
*            lv_own_doc = xsdbool(
*                 ( ls_acdoca-bktxt is not initial and ls_acdoca-bktxt = lv_bktxt_eho )
*              or ( ls_acdoca-bktxt is initial     and ls_acdoca-xblnr = lv_xblnr_eho ) ).
*-------------------------------------------------------------------*
* *- Kendi belgesi için EHO izi ve dolu banka referansı şartı
* *- (yukarıdaki arama ile aynı kural)
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
            lv_own_doc = xsdbool( <fs_out>-refbk is not initial
              and ( ls_acdoca-xblnr cp 'EHO-*' or ls_acdoca-tcode = lc_eho_tcode )
              and ( ( ls_acdoca-bktxt is not initial and ls_acdoca-bktxt = lv_bktxt_eho )
                 or ( ls_acdoca-bktxt is initial     and ls_acdoca-xblnr = lv_xblnr_eho ) ) ).
*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
* *- Virman karşı bacağı: belge başka bir EHO satırından atılmış
* *- (XBLNR 'EHO-*') ve bu satırın hesabına düşen kalem banka kalemi
* *- değil (1. kalem olanlar adaylıktan zaten çıkarıldı) → bu hareket de
* *- EHO'dan muhasebeleşmiştir: statü 5.
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
*            if lv_own_doc = abap_true.
            if lv_own_doc = abap_true or ls_acdoca-xblnr cp 'EHO-*'.
*-------------------------------------------------------------------*
              <fs_out>-blart = ls_acdoca-blart.           " rapordaki tür = belgedeki tür
              <fs_out>-statu = cv_05.

              clear ls_message.
              ls_message-msgid = 'ZEHO'.
              ls_message-msgno = '038'.     " İlgili kayıt daha önce muhasebeleştirilmiştir. Kayıt güncellenmiştir.
              ls_message-msgty = 'S'.
              zeho_cl020=>collect_message( is_message = ls_message is_out = <fs_out> ).
            else.
              <fs_out>-statu = '7'.
            endif.
*-------------------------------------------------------------------*
            delete lt_acdoca index lv_tabix.
          else.
*-------------------------------------------------------------------*
**-- open : Log tablosuna yaz - Statu güncelle - hesap metni bul
            if <fs_out>-kunnr is not initial or <fs_out>-lifnr is not initial or <fs_out>-saknr is not initial.
              <fs_out>-statu = '4'.
            else.
              <fs_out>-statu = '2'.
            endif.

            if <fs_out>-statu eq '4'.
              ls_message-msgid     = 'ZEHO'.
              ls_message-msgno     = '032' .
              ls_message-msgty     = 'S'   .
              zeho_cl020=>collect_message( is_message = ls_message is_out = <fs_out> ).
            elseif <fs_out>-statu eq '6'.
              ls_message-msgid     = 'ZEHO'.
              ls_message-msgno     = '016' .
              ls_message-msgty     = 'E'   .
              zeho_cl020=>collect_message( is_message = ls_message is_out = <fs_out> ).
            else.
              ls_message-msgid     = 'ZEHO'.
              ls_message-msgno     = '037' .
              ls_message-msgty     = 'E'   .
              zeho_cl020=>collect_message( is_message = ls_message is_out = <fs_out> ).
            endif.
          endif.     " lv_found

        endif.       " faccn
      endif.         " belnr

*-- Tek update: her satır buradan geçer
      call method zeho_cl020=>update_bank_item(
        exporting
          iv_statu = <fs_out>-statu
        changing
          cs_out   = <fs_out> ).

    endloop.

*-------------------------------------------------------------------*
* *- Statüsü 7 olan ama belgesi EHO'dan atılmış satırlar statü 5'e
* *- çekiliyor: satırın kendi belgesi ya da virman karşı bacağı
* *- (satırın hesabına düşen kalem belgenin 1. kalemi değil). Belge
* *- aynı banka hesabındaki başka bir satıra bağlıysa dokunulmaz.
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
    free: lt_heal_key, lt_heal_line, lt_bkpf_ref.
    loop at ct_out assigning <fs_out> where statu  = '7'
                                        and belnr  is not initial
                                        and manuel = abap_false.
      clear ls_bkpf_ref.
      ls_bkpf_ref-bukrs = <fs_out>-bukrs.
      ls_bkpf_ref-belnr = <fs_out>-belnr.
      ls_bkpf_ref-gjahr = <fs_out>-prdat+0(4).
      append ls_bkpf_ref to lt_heal_key.
    endloop.

    if lt_heal_key is not initial.
      select bukrs belnr gjahr blart xblnr bktxt
        from bkpf
        into table lt_bkpf_ref
        for all entries in lt_heal_key
        where bukrs = lt_heal_key-bukrs
          and belnr = lt_heal_key-belnr
          and gjahr = lt_heal_key-gjahr
          and stblg = space.

      select rbukrs gjahr belnr racct buzei
        from acdoca
        into table lt_heal_line
        for all entries in lt_heal_key
        where rldnr  = '0L'
          and rbukrs = lt_heal_key-bukrs
          and gjahr  = lt_heal_key-gjahr
          and belnr  = lt_heal_key-belnr.

      loop at ct_out assigning <fs_out> where statu  = '7'
                                          and belnr  is not initial
                                          and manuel = abap_false.
        read table lt_bkpf_ref into ls_bkpf_ref
             with table key bukrs = <fs_out>-bukrs
                            belnr = <fs_out>-belnr
                            gjahr = <fs_out>-prdat+0(4).
        if sy-subrc ne 0 or ls_bkpf_ref-xblnr np 'EHO-*'.
          continue.                                   " EHO belgesi değil: 7 kalır
        endif.

*-- Belge aynı banka hesabındaki başka bir satıra bağlıysa o hareketin belgesidir
        clear lv_link_seqnr.
        select single seqnr from zeho_t012
          into lv_link_seqnr
          where bukrs = <fs_out>-bukrs
            and belnr = <fs_out>-belnr
            and hkont = <fs_out>-hkont
            and seqnr <> <fs_out>-seqnr.
        if sy-subrc eq 0.
          continue.
        endif.

        clear lv_heal.
        lv_xblnr_eho = 'EHO-' && <fs_out>-refbk.
        lv_bktxt_eho = <fs_out>-refbk.
        if ( ls_bkpf_ref-bktxt is not initial and ls_bkpf_ref-bktxt = lv_bktxt_eho )
        or ( ls_bkpf_ref-bktxt is initial     and ls_bkpf_ref-xblnr = lv_xblnr_eho ).
          lv_heal = abap_true.                        " satırın kendi belgesi
        else.
*-- Virman karşı bacağı: satırın hesabına düşen kalem 1. kalem değil
          loop at lt_heal_line into ls_heal_line
               where rbukrs = <fs_out>-bukrs
                 and belnr  = <fs_out>-belnr
                 and racct  = <fs_out>-hkont.
            if ls_heal_line-buzei ne '001'.
              lv_heal = abap_true.
            endif.
            exit.
          endloop.
        endif.

        if lv_heal = abap_true.
          <fs_out>-blart = ls_bkpf_ref-blart.         " rapordaki tür = belgedeki tür
          <fs_out>-statu = cv_05.

          clear ls_message.
          ls_message-msgid = 'ZEHO'.
          ls_message-msgno = '038'.
          ls_message-msgty = 'S'.
          zeho_cl020=>collect_message( is_message = ls_message is_out = <fs_out> ).

          call method zeho_cl020=>update_bank_item(
            exporting
              iv_statu = <fs_out>-statu
            changing
              cs_out   = <fs_out> ).
        endif.
      endloop.
    endif.
*-------------------------------------------------------------------*

    commit work.

  endif.             " ct_out

endmethod.
