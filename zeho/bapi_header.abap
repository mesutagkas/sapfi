  method bapi_header.

    data: lv_srtlen     type i,
          lv_srt_1      type i,
          lv_srt_2      type i,
          ls_t024       type zeho_t024,
          ls_bseg_dmbtr type bseg.
    DATA: lv_default_blart TYPE bkpf-blart,
      lv_exception     TYPE xfeld.

    clear ch_header.
    ch_header-obj_type    = 'BKPFF'           .
    ch_header-bus_act     = 'RFBU'            .
    ch_header-username    = sy-uname          .
    ch_header-comp_code   = is_out-bukrs      .
    ch_header-doc_date    = is_out-prdat      .
    ch_header-pstng_date  = is_out-prdat      .
    ch_header-fisc_year   = is_out-prdat(4)   .
    ch_header-fis_period  = is_out-prdat+4(2) .
    ch_header-doc_type    = is_out-blart.
*    if is_out-blart is initial.
*      data lt_t024 type table of zeho_t024.
*      select * from zeho_t024
*        into table lt_t024.
*      if sy-subrc eq 0.
*        if is_out-kunnr is not initial and is_out-prtyp eq '+'.
*          read table lt_t024 into ls_t024 with key koart = 'D'
*                                                   protp = '+'.
*          ch_header-doc_type    = ls_t024-blart.
*        elseif is_out-kunnr is not initial and is_out-prtyp eq '-'.
*          read table lt_t024 into ls_t024 with key koart = 'D'
*                                                   protp = '-'.
*          ch_header-doc_type    = ls_t024-blart.
*        elseif is_out-lifnr is not initial and is_out-prtyp eq '+'.
*          read table lt_t024 into ls_t024 with key koart = 'K'
*                                                   protp = '+'.
*          ch_header-doc_type    = ls_t024-blart.
*        elseif is_out-lifnr is not initial and is_out-prtyp eq '-'.
*          read table lt_t024 into ls_t024 with key koart = 'K'
*                                             protp = '-'.
*          ch_header-doc_type    = ls_t024-blart.
*        elseif is_out-saknr is not initial and is_out-prtyp eq '+'.
*          read table lt_t024 into ls_t024 with key koart = 'S'
*                                                   protp = '+'.
*          ch_header-doc_type    = ls_t024-blart.
*        elseif is_out-saknr is not initial and is_out-prtyp eq '-'.
*          read table lt_t024 into ls_t024 with key koart = 'S'
*                                                   protp = '-'.
*          ch_header-doc_type    = ls_t024-blart.
*        endif.
*      endif.
*    else.
*      ch_header-doc_type    = is_out-blart.
*    endif.
*
*
*    lv_srtlen = lv_srt_1 = lv_srt_2 = 0.
*    lv_srtlen = strlen( is_out-refbk ).
*
*    lv_default_blart = ch_header-doc_type.


*    if is_out-lifnr is not initial and is_out-prtyp eq '-'.
*
*      if is_out-waers ne 'TRY'.
*         CLEAR lv_exception.
*
*    SELECT SINGLE active
*      FROM zeho_t030
*      INTO lv_exception
*      WHERE bukrs  EQ is_out-bukrs
*        AND lifnr  EQ is_out-lifnr
*        AND active EQ 'X'.
*
*    IF sy-subrc EQ 0.
*
*      ch_header-doc_type = lv_default_blart.
*
*    ELSE.
*
*        select single blart from t003 into @data(lv_blartks)
*          where blart eq 'KS'.
*
*        ch_header-doc_type = lv_blartks.
*
*      endif.
*      endif.
*
*      select single lifnr from zfi_t_0052 into @data(lv_lifnr)
*        where lifnr eq @is_out-lifnr.
*
*      if lv_lifnr is not initial.
*
*        select single blart from t003 into @data(lv_blartsd)
*          where blart eq 'SD'.
*
*        ch_header-doc_type = lv_blartsd.
*
*      endif.
*
*      select single ktokk from lfa1 into @data(lv_ktokk)
*         where lifnr eq @is_out-lifnr.
*
*      if lv_ktokk eq 'ZPER'.
*
*        select single blart from t003 into @data(lv_blartpm)
*          where blart eq 'PM'.
*
*        ch_header-doc_type = lv_blartpm.
*
*      endif.
*
*    endif.

*    IF is_out-bankc EQ 'DNZ' AND is_out-bankc EQ 'HSB'.
*      IF lv_srtlen GT 13.
*        lv_srt_1 = lv_srtlen - 13.
*        lv_srt_2 = lv_srtlen - lv_srt_1.
*        ch_header-ref_doc_no  = 'EHO-' && is_out-refbk+lv_srt_2(lv_srt_1).
*      ELSE.
*        ch_header-ref_doc_no  = 'EHO-' && is_out-refbk.
*      ENDIF.
*    ELSEIF is_out-bankc EQ 'ISB' OR is_out-bankc EQ 'VKB' OR is_out-bankc EQ 'QNB'.
*      IF lv_srtlen GT 7.
*        lv_srt_1 = lv_srtlen - 7.
*        lv_srt_2 = lv_srtlen - lv_srt_1.
*        ch_header-ref_doc_no  = 'EHO-' && is_out-refbk+lv_srt_2(lv_srt_1).
*      ELSE.
*        ch_header-ref_doc_no  = 'EHO-' && is_out-refbk.
*      ENDIF.
*    ELSEIF is_out-bankc EQ 'TEB' OR is_out-bankc EQ 'ZRT' OR  is_out-bankc EQ 'TFB' OR  is_out-bankc EQ 'EMK'.
*      IF lv_srtlen GT 9.
*        lv_srt_1 = lv_srtlen - 9.
*        lv_srt_2 = lv_srtlen - lv_srt_1.
*        ch_header-ref_doc_no  = 'EHO-' && is_out-refbk+lv_srt_2(lv_srt_1).
*      ELSE.
*        ch_header-ref_doc_no  = 'EHO-' && is_out-refbk.
*      ENDIF.
*    ELSEIF is_out-bankc EQ 'YKB'.
*      data lv_reftemp like is_out-refbk.
*      lv_reftemp = is_out-refbk.
*      SHIFT lv_reftemp LEFT DELETING LEADING '0'.
*      ch_header-ref_doc_no   = lv_reftemp.
**      IF lv_srtlen GT 8.
**        lv_srt_1 = lv_srtlen - 8.
**        lv_srt_2 = lv_srtlen - lv_srt_1.
**        ch_header-ref_doc_no  = 'EHO-' && is_out-refbk+lv_srt_2(8).
**      ELSE.
**        ch_header-ref_doc_no  = 'EHO-' && is_out-refbk.
**      ENDIF.
*    ELSE.
    ch_header-ref_doc_no  = 'EHO-' && is_out-refbk.
*    ENDIF.

*-------------------------------------------------------------------*
* *- Bankanın tam referansı belge başlık metnine yazılıyor.
* *- XBLNR 16 karakter: 'EHO-' + refbk'nin ilk 12 karakteri sığıyor,
* *- uzun referanslarda (ör. ISB 18 karakter) farklı hareketler aynı
* *- XBLNR'ı alıyor. Başlık metni (25 karakter) hareketi tekil tanıtır.
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
    ch_header-header_txt  = is_out-refbk.
*-------------------------------------------------------------------*

    call function 'OWN_LOGICAL_SYSTEM_GET'
      importing
        own_logical_system = ch_header-obj_sys.
  endmethod.
