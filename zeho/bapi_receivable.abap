method bapi_receivable.
*
*  data: lv_knrze      type knb1-knrze,
*        lv_plant_type type t001w-zzplant_type.
*  data: lv_kunnr type knb1-kunnr,
*        lv_werks type t001w-werks.


*  data: lt_knvv type standard table of knvv,
*        ls_knvv type knvv,
*        lv_bayi type abap_bool.

*  data: lt_bayi_anlasma type standard table of zeho_t031,
*        ls_bayi_anlasma type zeho_t031,
*        lv_arama_metni  type string,
*        lv_match        type abap_bool,
*        lv_var30        type abap_bool,
*        lv_var60        type abap_bool,
*        lv_var50        type abap_bool.

  " Yataş.com.tr / VBAK-BSTNK eşleşmesi
*  data: lv_offset     type i,
*        lv_after      type string,
*        lv_siparis_no type string,
*        ls_vbak       type vbak,
*        lv_vbak_match type abap_bool.

*-------------------------------------------------------------------*
* *- Showroom iade süreci (find_other_acc_no ile aynı metin kalıbı)
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
*-- Metin normalizasyonu (regex kullanılmıyor). Eşleme çiftleri:
*-- İ→I, ı→I, Ş→S, ş→S ve - ( ) : . / → boşluk
  constants: lc_norm_map type string value `İIıIŞSşS- ( ) : . / `.
  data: lv_norm          type string,
        lv_txt_part      type string,
        lv_tok           type string,
        lt_tok           type standard table of string,
        lv_moff          type i,
        lv_loff          type i,
        lv_mlen          type i,
        lv_shw_found     type abap_bool,
        lv_shw_vbeln_txt type string,
        lv_shw_vbeln     type vbak-vbeln.
*-------------------------------------------------------------------*

*  clear: lv_knrze,
*         lv_plant_type,
*         lv_kunnr,
*         lv_werks.
*
*  clear: lv_knrze,
*         lv_plant_type,
*         lv_kunnr,
*         lv_werks.

  ch_receivable-itemno_acc = iv_item_no.
  ch_receivable-customer   = is_out-kunnr.
* ch_receivable-item_text  = is_out-butxt.
  ch_receivable-comp_code  = is_out-bukrs.
  ch_receivable-bus_area   = is_out-gsber.


*   is_out-prtyp eq '+'
  if   is_out-kunnr is not initial
      and is_out-xref3 is not initial.

    " XREF3, check_kna1 / check_tiban tarafından zaten hesaplanmış/doldurulmuştur
    " (VBAK/e-ticaret eşleşmesi, KNVV/BAYİ-Endüstriyel-KURUMSAL kuralları,
    " veya kullanıcının ALV'de elle/F4 ile değiştirdiği değer dahil).
    " bapi_receivable bu değeri tekrar hesaplamaz, doğrudan aktarır.
    select single vtweg from zsd_t_0005 into @data(ls_vtweg)
      where zzanlasma eq @is_out-xref3.

    ch_receivable-ref_key_3 = is_out-xref3.
    ch_receivable-ref_key_1 = ls_vtweg.

  else.

    "XREF3 boşsa veya gelen tahsilat değilse mevcut değer kullanılır
    ch_receivable-ref_key_3 = is_out-gsber_3.

  endif.

*-------------------------------------------------------------------*
* *- Showroom iade: sipariş no REF_KEY_2'ye (10 hane), rapordaki kâr
* *- merkezi (VBAP-PRCTR) müşteri kalemine yazılıyor. Sadece metninde
* *- "SHOWROOM İADE" / "SHW İADE" geçen kayıtlarda; diğer akışlar
* *- etkilenmez. Sipariş no find_other_acc_no ile aynı kuralla bulunur.
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
  clear: lv_shw_found, lv_shw_vbeln_txt, lv_shw_vbeln.

  lv_norm = is_out-butxt.
  translate lv_norm to upper case.
  translate lv_norm using lc_norm_map.
  condense lv_norm.

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
    shift lv_shw_vbeln_txt left deleting leading '0'.
    if lv_shw_vbeln_txt is not initial and strlen( lv_shw_vbeln_txt ) le 10.
      lv_shw_vbeln = lv_shw_vbeln_txt.
      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          input  = lv_shw_vbeln
        importing
          output = lv_shw_vbeln.

      ch_receivable-ref_key_2  = lv_shw_vbeln.
      ch_receivable-profit_ctr = is_out-prctr.
    endif.
  endif.
*-------------------------------------------------------------------*

  ch_receivable-sp_gl_ind  = is_out-umskz.
  ch_receivable-alloc_nmbr = is_out-zuonr.
  ch_receivable-gl_account = is_out-akont_ar.

  if is_out-prtyp eq '-'
     and is_out-vgint eq 'VRM'.

    ch_receivable-bline_date = is_out-valdt + 1.

    if is_out-valdt is initial.
      ch_receivable-bline_date = sy-datum.
    else.
      ch_receivable-bline_date = is_out-valdt.
    endif.

  else.

    if is_out-valdt is initial.
      ch_receivable-bline_date = sy-datum.
    else.
      ch_receivable-bline_date = is_out-valdt.
    endif.

  endif.

* IF sy-subrc = 0 AND lv_item_text IS NOT INITIAL.
*   ch_receivable-item_text = lv_item_text.
* ELSE.
  ch_receivable-item_text = is_out-butxt.
* ENDIF.

  ch_extension-structure  = 'kunnr'.
  ch_extension-valuepart1 = is_out-kunnr.
  ch_extension-valuepart2 = is_out-prtyp.
  ch_extension-valuepart3 = iv_item_no.

  if is_out-bschl is not initial
     and iv_second_step eq abap_true.

    ch_extension-valuepart4 = is_out-bschl.

  else.

    if is_out-prtyp eq '+'
       and is_out-umskz is initial.

      ch_extension-valuepart4 = '15'.

    elseif is_out-prtyp eq '+'
       and is_out-umskz is not initial.

      ch_extension-valuepart4 = '19'.

    elseif is_out-prtyp eq '-'
       and is_out-umskz is initial.

      ch_extension-valuepart4 = '05'.

    elseif is_out-prtyp eq '-'
       and is_out-umskz is not initial.

      ch_extension-valuepart4 = '09'.

    endif.

  endif.

  if ch_extension-valuepart4 is initial.
    clear ch_extension.
  endif.

endmethod.
