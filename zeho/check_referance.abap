method check_referance.

    data: lv_ftr03    type xfeld,
          lv_check    type xfeld,
          lv_subtotal type i,
          lv_begda    type zeho_t016-begda,
*          lv_xblnr    type char20,
          lv_srtlen   type i,
          lv_srt_1    type i,
          lv_srt_2    type i,
          ls_bkpf     type bkpf,
          ls_bseg     type bseg,
          ls_t012     type zeho_t012.

*-------------------------------------------------------------------*
* *- Mükerrer kontrolü düzeltmesi:
* *- - lv_xblnr CHAR20 idi; BKPF-XBLNR 16 karakter olduğu için refbk'si
* *-   12 karakterden uzun bankalarda (ör. ISB) önceki belge hiç
* *-   bulunamıyordu. Artık bkpf-xblnr tipinde (bapi_header ile aynı kesilme).
* *- - Yeni belgelerde başlık metni (BKTXT) tam banka referansını taşıyor;
* *-   önce ona bakılıyor. Eski belgelerde (BKTXT boş) XBLNR kullanılıyor.
* *- - select single yerine aynı referanstaki tüm belgeler dolaşılıyor;
* *-   başka bir EHO satırına bağlı belgeler atlanıyor.
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
    types: begin of ty_bkpf_ref,
             bukrs type bkpf-bukrs,
             belnr type bkpf-belnr,
             gjahr type bkpf-gjahr,
             xblnr type bkpf-xblnr,
             bktxt type bkpf-bktxt,
           end of ty_bkpf_ref.

    data: lt_bkpf_ref   type standard table of ty_bkpf_ref,
          ls_bkpf_ref   type ty_bkpf_ref,
          lv_xblnr      type bkpf-xblnr,
          lv_bktxt      type bkpf-bktxt,
          lv_gjahr      type bkpf-gjahr,
          lv_belnr_t012 type zeho_t012-belnr.

*-------------------------------------------------------------------*
* *- Virman karşı bacağı kontrolü
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
    types: begin of ty_counter,
             rbukrs type acdoca-rbukrs,
             gjahr  type acdoca-gjahr,
             belnr  type acdoca-belnr,
             buzei  type acdoca-buzei,
           end of ty_counter.
    data: lt_counter type standard table of ty_counter,
          ls_counter type ty_counter,
          lv_tsl     type acdoca-tsl.
*-------------------------------------------------------------------*

    clear es_bseg.
    ev_subrc = 4.

    lv_xblnr = 'EHO-' && is_out-refbk.     " bapi_header ile aynı (16 karaktere kesilir)
    lv_bktxt = is_out-refbk.               " yeni belgelerde tam banka referansı
    lv_gjahr = is_out-prdat+0(4).

*-- Aynı gün, aynı referansla atılmış ve ters çevrilmemiş tüm belgeler
*-------------------------------------------------------------------*
* *- Banka referansı boşsa referansla arama yapılmıyor: boş başlık
* *- metni o günün başlık metni boş tüm belgeleriyle eşleşiyordu.
* *- added by <kullanıcı> 09.10.2026
*-------------------------------------------------------------------*
    if is_out-refbk is not initial.
      select bukrs belnr gjahr xblnr bktxt
        from bkpf
        into table lt_bkpf_ref
        where bukrs = is_out-bukrs
          and gjahr = lv_gjahr
          and bldat = is_out-prdat
          and ( xblnr = lv_xblnr or bktxt = lv_bktxt )
          and stblg = space.
    endif.
*-------------------------------------------------------------------*

    loop at lt_bkpf_ref into ls_bkpf_ref.

*-- Yeni belge: tam referans birebir tutmalı. Eski belge: XBLNR tutmalı.
      if ls_bkpf_ref-bktxt is not initial.
        if ls_bkpf_ref-bktxt <> lv_bktxt.
          continue.
        endif.
      elseif ls_bkpf_ref-xblnr <> lv_xblnr.
        continue.
      endif.

*-- Başka bir EHO satırına bağlı belge bu satırın olamaz. Bu satırın
*-- kendisi (SEQNR aynı) hariç tutuluyor: belge başka bir oturumda bu
*-- satırdan atılmış ve DB'de bu satıra bağlıysa bulunmalı.
      clear lv_belnr_t012.
      select single belnr from zeho_t012
        into lv_belnr_t012
        where bukrs = ls_bkpf_ref-bukrs
          and belnr = ls_bkpf_ref-belnr
          and seqnr <> is_out-seqnr.
      if sy-subrc = 0.
        continue.
      endif.

*-- Banka kalemi (1. kalem) tutarı hareketle aynı olmalı
      clear ls_bseg.
      select single * from bseg
        into ls_bseg
        where bukrs = ls_bkpf_ref-bukrs
          and belnr = ls_bkpf_ref-belnr
          and gjahr = ls_bkpf_ref-gjahr
          and buzei = 1.
      if sy-subrc <> 0.
        continue.
      endif.

      if ls_bseg-shkzg eq 'H'.
        multiply ls_bseg-wrbtr by -1.
      endif.

      if ls_bseg-wrbtr eq is_out-amount.
        es_bseg  = ls_bseg.
        ev_subrc = 0.
        exit.
      endif.
    endloop.
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
* *- Virman karşı bacağı: bu satırın banka hesabına, başka bir EHO
* *- satırından atılmış bir belgenin karşı kalemi (1. kalem değil)
* *- aynı tarih/tutar/para birimiyle düşmüşse hareket zaten
* *- muhasebeleşmiştir; ikinci bir virman belgesi atılmaz, satır o
* *- belgeye bağlanır. Aynı hesaptaki başka bir satıra bağlı belge
* *- (aynı gün aynı tutarlı ikinci virman) atlanır.
* *- added by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
    if ev_subrc ne 0.
      lv_tsl = cond #( when is_out-prtyp = '+' then abs( is_out-amount )
                       else abs( is_out-amount ) * -1 ).

      select a~rbukrs a~gjahr a~belnr a~buzei
        from acdoca as a
        inner join bkpf as b
          on  b~bukrs = a~rbukrs
          and b~belnr = a~belnr
          and b~gjahr = a~gjahr
        into table lt_counter
        where a~rldnr      = '0L'
          and a~rbukrs     = is_out-bukrs
          and a~racct      = is_out-hkont
          and a~budat      = is_out-prdat
          and a~tsl        = lv_tsl
          and a~rtcur      = is_out-waers
          and a~xreversing = space
          and a~xreversed  = space
          and a~buzei      <> '001'
          and b~xblnr      like 'EHO-%'
          and b~stblg      = space.

      loop at lt_counter into ls_counter.
        clear lv_belnr_t012.
        select single belnr from zeho_t012
          into lv_belnr_t012
          where bukrs = ls_counter-rbukrs
            and belnr = ls_counter-belnr
            and hkont = is_out-hkont
            and seqnr <> is_out-seqnr.
        if sy-subrc = 0.
          continue.
        endif.

        clear ls_bseg.
        select single * from bseg
          into ls_bseg
          where bukrs = ls_counter-rbukrs
            and belnr = ls_counter-belnr
            and gjahr = ls_counter-gjahr
            and buzei = ls_counter-buzei.
        if sy-subrc = 0.
          es_bseg  = ls_bseg.
          ev_subrc = 0.
          exit.
        endif.
      endloop.
    endif.
*-------------------------------------------------------------------*

*    lv_srtlen = lv_srt_1 = lv_srt_2 = 0.
*    lv_srtlen = strlen( is_out-refbk ).
*    clear lv_xblnr.
*    lv_xblnr  = 'EHO-' && is_out-refbk.
*
*
*    clear ls_bkpf.
*    select single * from bkpf                 "#EC CI_ALL_FIELDS_NEEDED
*      into ls_bkpf
*      where bukrs = is_out-bukrs
*      and   gjahr = is_out-prdat+0(4)
*      and   bldat = is_out-prdat
*      and   xblnr like lv_xblnr
*      and   stblg = space.
*    if sy-subrc eq 0.
*      clear ls_bseg.
*      select single * from bseg
*      into es_bseg
*      where bukrs = ls_bkpf-bukrs
*      and   belnr = ls_bkpf-belnr
*      and   gjahr = ls_bkpf-gjahr
*      and   buzei = 1.
*      if es_bseg-shkzg eq 'H'.
*        multiply es_bseg-wrbtr by -1.
*      endif.
*      if es_bseg-wrbtr eq is_out-amount.
*        ev_subrc = 0.
*      else.
*        ev_subrc = 4.
*      endif.
*    else.
*      ev_subrc = sy-subrc.
*    endif.

  endmethod.
