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
  constants: lc_shw_mark  type string value `(SHOWROOM|SHW)\s*-?\s*[İIıi]ADE`,
             lc_shw_sipno type string value `S[İIıi]P(AR[İIıi][ŞSşs])?\.?\s*NO\s*[:.]?\s*\(?\s*(\d+)`,
             lc_shw_regex type string value `(\d+)\s*-?\s*(SHOWROOM|SHW)\s*-?\s*[İIıi]ADE`.
  data: lv_shw_dummy     type string,
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
  clear: lv_shw_dummy, lv_shw_vbeln_txt, lv_shw_vbeln.
  find first occurrence of regex lc_shw_mark
       in is_out-butxt
       ignoring case.
  if sy-subrc eq 0.
    find first occurrence of regex lc_shw_sipno
         in is_out-butxt
         ignoring case
         submatches lv_shw_dummy lv_shw_vbeln_txt.
    if sy-subrc ne 0.
      find first occurrence of regex lc_shw_regex
           in is_out-butxt
           ignoring case
           submatches lv_shw_vbeln_txt.
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
