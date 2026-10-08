METHOD bapi_hgs_ogs_1.
  DATA: lt_t023           TYPE STANDARD TABLE OF zeho_t023,
        ls_t023           TYPE zeho_t023,
*-------------------------------------------------------------------*
* *- Sabit KDV oranı kaldırıldı, matrah vergi kodundan hesaplanıyor
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
*        lv_matrah_rate(4) VALUE '1.18',
*-------------------------------------------------------------------*
        lv_item_no        TYPE posnr_acc,
        lv_matrah_        TYPE p DECIMALS 2,
        lv_matrah         TYPE zeho_s004-amount,
        lv_rate1_         TYPE zeho_s004-amount,
        lv_rate2_         TYPE zeho_s004-amount,
        lv_main70_        TYPE p DECIMALS 2,
        lv_main70         TYPE zeho_s004-amount,
        lv_main70_tax_    TYPE zeho_s004-amount,
        lv_main30_        TYPE zeho_s004-amount,
        lv_main30_tax_    TYPE zeho_s004-amount,
        lv_sign           TYPE c LENGTH 2 VALUE '+1',
        lt_accountgl      TYPE STANDARD TABLE OF bapiacgl09,
        lt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
        ls_currencyamount TYPE bapiaccr09,
        lt_accounttax     TYPE STANDARD TABLE OF bapiactx09,
        lt_mwdat          TYPE STANDARD TABLE OF rtax1u15,
        lt_extension2     TYPE STANDARD TABLE OF bapiparex,
        ls_extension2     TYPE bapiparex,
        ls_mwdat          TYPE rtax1u15.

*-------------------------------------------------------------------*
* *- Plaka bazlı Binek/Ticari ayrımı (ZEHO_T022-HTYP2)
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
  CONSTANTS: lc_htyp2_binek  TYPE zeho_de068 VALUE '01',
             lc_htyp2_ticari TYPE zeho_de068 VALUE '02'.

  DATA: lv_gross_b TYPE zeho_s004-amount,   " Binek: brüt tutar (mutlak)
        lv_gross_t TYPE p DECIMALS 2,       " Ticari: brüt tutar (işaretli)
        lv_abs_t   TYPE zeho_s004-amount,   " Ticari: brüt tutar (mutlak)
        lv_tax_t   TYPE p DECIMALS 2,       " Ticari: KDV
        lv_net_t   TYPE p DECIMALS 2.       " Ticari: net gider
*-------------------------------------------------------------------*

  FIELD-SYMBOLS:
    <fs_currencyamount> TYPE  bapiaccr09,
    <fs_accountgl>      TYPE  bapiacgl09,
    <fs_mwdat>          TYPE  rtax1u15,
    <fs_accounttax>     TYPE  bapiactx09,
    <fs_extension2>     TYPE  bapiparex.

  CLEAR lv_sign.
  CLEAR lv_sign.
  lv_sign = '-1'.

*-------------------------------------------------------------------*
* *- Ticari araç: gider kısıtlaması yok, %100 gider + %100 KDV indirimi
* *- Binek (veya HTYP2 boş - eski kayıtlar): aşağıdaki %70/%30 akışı
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
  IF is_out-htyp2 EQ lc_htyp2_ticari.

    " Belgede bankanın karşılığı olacak brüt tutar (çıkışta pozitif)
    lv_gross_t = is_out-amount * lv_sign.
    lv_abs_t   = abs( lv_gross_t ).

    " KDV brütten, vergi kodunun (FTXP) oranıyla hesaplanır
    FREE lt_mwdat.
    CALL FUNCTION 'CALCULATE_TAX_FROM_GROSSAMOUNT'
      EXPORTING
        i_bukrs = is_out-bukrs
        i_mwskz = is_out-mwskz
        i_waers = is_out-waers
        i_wrbtr = lv_abs_t
      TABLES
        t_mwdat = lt_mwdat.
    CLEAR ls_mwdat.
    READ TABLE lt_mwdat INTO ls_mwdat INDEX 1.

    lv_tax_t = ls_mwdat-wmwst.
    IF lv_gross_t LT 0.
      lv_tax_t = lv_tax_t * -1.
    ENDIF.
    " Net = brüt - KDV -> dip toplam kuruş farksız sıfırlanır
    lv_net_t = lv_gross_t - lv_tax_t.

    " %100 gider kalemi (T022 hesabı / masraf yeri)
    lv_item_no = iv_item_no + 1.
    APPEND INITIAL LINE TO lt_accountgl ASSIGNING <fs_accountgl>.
    <fs_accountgl>-itemno_acc  = lv_item_no.
    <fs_accountgl>-gl_account  = is_out-saknr.
    <fs_accountgl>-item_text   = is_out-butxt.
    <fs_accountgl>-comp_code   = is_out-bukrs.
    <fs_accountgl>-bus_area    = is_out-gsber.
    <fs_accountgl>-costcenter  = is_out-kostl.
    <fs_accountgl>-tax_code    = is_out-mwskz.

    APPEND INITIAL LINE TO lt_currencyamount ASSIGNING <fs_currencyamount>.
    <fs_currencyamount>-itemno_acc = lv_item_no.
    <fs_currencyamount>-curr_type  = '00'.
    <fs_currencyamount>-currency   = is_out-waers.
    <fs_currencyamount>-exch_rate  = is_out-kursf.
    <fs_currencyamount>-amt_doccur = lv_net_t.

    " %100 indirilecek KDV kalemi
    lv_item_no = lv_item_no + 1.
    APPEND INITIAL LINE TO lt_accounttax ASSIGNING <fs_accounttax>.
    <fs_accounttax>-itemno_acc = lv_item_no.
    <fs_accounttax>-gl_account = ls_mwdat-hkont.
    <fs_accounttax>-tax_code   = is_out-mwskz.
    <fs_accounttax>-tax_rate   = ls_mwdat-msatz.

    APPEND INITIAL LINE TO lt_currencyamount ASSIGNING <fs_currencyamount>.
    <fs_currencyamount>-itemno_acc = lv_item_no.
    <fs_currencyamount>-curr_type  = '00'.
    <fs_currencyamount>-currency   = is_out-waers.
    <fs_currencyamount>-amt_doccur = lv_tax_t.
    <fs_currencyamount>-amt_base   = lv_net_t.
    <fs_currencyamount>-tax_amt    = lv_tax_t.

    APPEND INITIAL LINE TO lt_extension2 ASSIGNING <fs_extension2>.
    <fs_extension2>-structure  = 'HGS_TAX'.
    <fs_extension2>-valuepart1 = ls_mwdat-hkont.
    <fs_extension2>-valuepart3 = lv_item_no.

    ch_gl_account[]      = lt_accountgl[].
    ch_currency_amount[] = lt_currencyamount[].
    ch_accounttax[]      = lt_accounttax[].
    ch_extension[]       = lt_extension2[].
    RETURN.
  ENDIF.
*-------------------------------------------------------------------*

  FREE lt_t023.
  SELECT * FROM zeho_t023
  INTO TABLE lt_t023.                                   "#EC CI_NOWHERE
  CLEAR ls_t023.
  READ TABLE lt_t023 INTO ls_t023 WITH KEY htyp = '02'.

*-------------------------------------------------------------------*
* *- Matrah sabit 1.18 yerine vergi kodundan (FTXP) hesaplanır
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
*  lv_matrah  = is_out-amount / lv_matrah_rate.
*  lv_matrah_ = is_out-amount / lv_matrah_rate.
  lv_gross_b = abs( is_out-amount ).
  FREE lt_mwdat.
  CALL FUNCTION 'CALCULATE_TAX_FROM_GROSSAMOUNT'
    EXPORTING
      i_bukrs = is_out-bukrs
      i_mwskz = is_out-mwskz
      i_waers = is_out-waers
      i_wrbtr = lv_gross_b
    TABLES
      t_mwdat = lt_mwdat.
  CLEAR ls_mwdat.
  READ TABLE lt_mwdat INTO ls_mwdat INDEX 1.

  " Net matrah = brüt - KDV (işaret eski hesapla aynı kalsın)
  lv_matrah_ = lv_gross_b - ls_mwdat-wmwst.
  IF is_out-amount LT 0.
    lv_matrah_ = lv_matrah_ * -1.
  ENDIF.
  lv_matrah = lv_matrah_.
*-------------------------------------------------------------------*

  lv_item_no = iv_item_no + 1.
  APPEND INITIAL LINE TO lt_accountgl ASSIGNING <fs_accountgl>.
  <fs_accountgl>-itemno_acc  = lv_item_no.
  <fs_accountgl>-gl_account  = is_out-saknr.
  <fs_accountgl>-item_text   = is_out-butxt .
  <fs_accountgl>-comp_code   = is_out-bukrs.
  <fs_accountgl>-bus_area    = is_out-gsber.
  <fs_accountgl>-costcenter  = is_out-kostl.
  <fs_accountgl>-tax_code    = is_out-mwskz.

  lv_main70_ = lv_matrah_ * '0.7' * lv_sign.
  lv_main70  = lv_matrah * '0.7' * lv_sign.

  APPEND INITIAL LINE TO lt_currencyamount ASSIGNING <fs_currencyamount>.
  <fs_currencyamount>-itemno_acc = lv_item_no.
  <fs_currencyamount>-curr_type  = '00'.
  <fs_currencyamount>-currency   = is_out-waers .
  <fs_currencyamount>-exch_rate  = is_out-kursf.
  <fs_currencyamount>-amt_doccur = lv_main70_.

  IF lv_main70 LT 0 .
    lv_main70 = lv_main70 * -1.
  ENDIF.
*-------------------------------------------------------------------*
* *- lt_mwdat yukarıda da dolduruluyor, eski kayıt okunmasın
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
  FREE lt_mwdat.
  CLEAR ls_mwdat.
*-------------------------------------------------------------------*
  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      i_bukrs = is_out-bukrs
      i_mwskz = is_out-mwskz
      i_waers = is_out-waers
      i_wrbtr = lv_main70
    TABLES
      t_mwdat = lt_mwdat.

  READ TABLE lt_mwdat INTO ls_mwdat INDEX 1.
  lv_item_no = lv_item_no + 1.
  APPEND INITIAL LINE TO lt_accounttax ASSIGNING <fs_accounttax>.
  <fs_accounttax>-itemno_acc = lv_item_no .
  <fs_accounttax>-gl_account = ls_mwdat-hkont.
  <fs_accounttax>-tax_code = is_out-mwskz.
  <fs_accounttax>-tax_rate = ls_mwdat-msatz.

  DATA lv_amt_tax TYPE p DECIMALS 2.
  APPEND INITIAL LINE TO lt_currencyamount ASSIGNING <fs_currencyamount>.
  <fs_currencyamount>-itemno_acc = lv_item_no .
  <fs_currencyamount>-curr_type  = '00'.
  <fs_currencyamount>-currency   = is_out-waers .
  lv_amt_tax                     = ls_mwdat-wmwst.
  <fs_currencyamount>-amt_doccur = lv_amt_tax.
  <fs_currencyamount>-amt_base   = ls_mwdat-kawrt.
  <fs_currencyamount>-tax_amt    = ls_mwdat-wmwst.

  APPEND INITIAL LINE TO lt_extension2 ASSIGNING <fs_extension2>.
  <fs_extension2>-structure  = 'HGS_TAX'.
  <fs_extension2>-valuepart1 = ls_mwdat-hkont.
  <fs_extension2>-valuepart3 = lv_item_no.


** %30 hesaplama
  CLEAR ls_t023.
  READ TABLE lt_t023 INTO ls_t023 WITH KEY htyp = '02'.

  lv_main30_ = lv_matrah_ * '0.3' * lv_sign.
  lv_item_no = lv_item_no + 1.
  APPEND INITIAL LINE TO lt_accountgl ASSIGNING <fs_accountgl>.
  <fs_accountgl>-itemno_acc  = lv_item_no.
  <fs_accountgl>-gl_account  = ls_t023-hkont."'7600600013'.
  <fs_accountgl>-item_text   = is_out-butxt .
  <fs_accountgl>-comp_code   = is_out-bukrs.
  <fs_accountgl>-bus_area    = is_out-gsber.
*-------------------------------------------------------------------*
* *- KKEG satırı da plakanın masraf yerine (ZEHO_T022) yazılır
* *- changed by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
*  <fs_accountgl>-costcenter  = ls_t023-kostl.
  <fs_accountgl>-costcenter  = is_out-kostl.
*-------------------------------------------------------------------*
  <fs_accountgl>-tax_code   =  is_out-mwskz.

  APPEND INITIAL LINE TO lt_currencyamount ASSIGNING <fs_currencyamount>.
  <fs_currencyamount>-itemno_acc = lv_item_no.
  <fs_currencyamount>-curr_type  = '00'.
  <fs_currencyamount>-currency   = is_out-waers .
  <fs_currencyamount>-exch_rate  = is_out-kursf.
  <fs_currencyamount>-amt_doccur = lv_main30_.

**********************************************************************
* %30 'Luk kısmın KDV'si hesaplanadığında kuruş farkları ortaya çıktığından
* KDV Hesaplama kısmı iptal edildi. Dip toplam sıfır olacak şekilde
* hesaplama yapıldı.
**********************************************************************
*  IF lv_main70 LT 0 .
*    lv_main70 = lv_main70 * -1.
*  ENDIF.
*  FREE : lt_mwdat.
*  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
*    EXPORTING
*      i_bukrs = is_out-bukrs
*      i_mwskz = is_out-mwskz
*      i_waers = is_out-waers
*      i_wrbtr = lv_main30_
*    TABLES
*      t_mwdat = lt_mwdat.

*  READ TABLE lt_mwdat INTO ls_mwdat INDEX 1.

  lv_main30_tax_ = is_out-amount.
  LOOP AT lt_currencyamount INTO ls_currencyamount.
    lv_main30_tax_ = lv_main30_tax_ + ls_currencyamount-amt_doccur.
  ENDLOOP.
  lv_main30_tax_ = - lv_main30_tax_.

  lv_item_no = lv_item_no + 1.

  APPEND INITIAL LINE TO lt_accountgl ASSIGNING <fs_accountgl>.
  <fs_accountgl>-itemno_acc  = lv_item_no.
  <fs_accountgl>-gl_account  = ls_t023-hkont.
  <fs_accountgl>-item_text   = is_out-butxt .
  <fs_accountgl>-comp_code   = is_out-bukrs.
  <fs_accountgl>-bus_area    = is_out-gsber.
*-------------------------------------------------------------------*
* *- KKEG satırı da plakanın masraf yerine (ZEHO_T022) yazılır
* *- changed by <kullanıcı> 08.10.2026
*-------------------------------------------------------------------*
*  <fs_accountgl>-costcenter  = ls_t023-kostl.
  <fs_accountgl>-costcenter  = is_out-kostl.
*-------------------------------------------------------------------*
  <fs_accountgl>-tax_code   =  is_out-mwskz.

  APPEND INITIAL LINE TO lt_currencyamount ASSIGNING <fs_currencyamount>.
  <fs_currencyamount>-itemno_acc = lv_item_no.
  <fs_currencyamount>-curr_type  = '00'.
  <fs_currencyamount>-currency   = is_out-waers .
  <fs_currencyamount>-exch_rate  = is_out-kursf.
  <fs_currencyamount>-amt_doccur = lv_main30_tax_.

**********************************************************************
* Eski HTYP 03/04/05/06 blokları (yorum satırı) değişmeden aynen kalır.
**********************************************************************

  ch_gl_account[]      = lt_accountgl[].
  ch_currency_amount[] = lt_currencyamount[].
  ch_accounttax[]      = lt_accounttax[].
  ch_extension[]       = lt_extension2[].
ENDMETHOD.
