form mapt012 .

  data: lt_t002 type table of zeho_t002,
        ls_t012 type zeho_t012.
  data lv_trnid type char255.
  data lv_prdat_txt type char20.
  data lv_dats type d.
  data lv_tims type t.
  data: lv_t002_found  type abap_bool,
        lv_t012_found  type abap_bool,
        lv_t012_update type abap_bool.
  data lv_guid type sysuuid_c.
  data lv_exist type zeho_t012-seqnr.
*  data lv_payment_date type string value '2025-12-16T13:20:00Z'.
  data lv_datum type d.
  data lv_uzeit type t.
  data: ls_t002 type zeho_t002,
        lv_iban type zeho_t002-iban.

  data: lv_payment_date type string,
        lv_date_txt     type string,
        lv_time_txt     type string,
        lv_prdat        type d,
        lv_prtim        type t.



  loop at gt_table into gs_table2.

    clear: gs_t012, ls_t002, lv_iban, gs_t012-saknr.

    write gs_table2-payment_id to lv_trnid.
    condense lv_trnid no-gaps.
    lv_trnid = |{ gs_table2-payment_id number = raw }|.

    lv_iban = gs_table2-firm_bank_iban.
    condense lv_iban no-gaps.

    select single
         bankc,
         bukrs,
         hbkid,
         hktid,
         bankn,
         hkont
*         waers
    from zeho_t002
     into corresponding fields of @ls_t002
    where iban = @lv_iban.
    lv_t002_found = xsdbool( sy-subrc = 0 ).

    gs_t012-seqnr = gs_table2-uniqueid.
    condense gs_t012-seqnr no-gaps.


    lv_payment_date = gs_table2-payment_date.  "2026-02-04T13:30:24

    " Tarih kısmı (YYYY-MM-DD)
    lv_date_txt = lv_payment_date+0(10).      "2026-02-04
    replace all occurrences of '-' in lv_date_txt with ''.
    lv_prdat = lv_date_txt.                                 "20260204

    " Saat kısmı (HH:MM:SS)
    lv_time_txt = lv_payment_date+11(8).      "13:30:24
    replace all occurrences of ':' in lv_time_txt with ''.
    lv_prtim = lv_time_txt.                                 "133024


    select single seqnr
  into lv_exist
  from zeho_t012
  where seqnr = gs_t012-seqnr.
    lv_t012_update = xsdbool( sy-subrc = 0 ).

*    select uniqueid,
*       payment_id
*  from zeho_t_wbrs002
*  into table @data(lt_wbrs).
*
*    loop at lt_wbrs into data(ls_wbrs).
*
*      update zeho_t012
*         set trnid = ls_wbrs-payment_id
*       where seqnr = ls_wbrs-uniqueid.
*
*    endloop.
*

    if lv_t002_found eq abap_true.

      gs_t012-statu = '1'.
      gs_t012-bankc = ls_t002-bankc.
      gs_t012-bukrs = ls_t002-bukrs.
      gs_t012-hbkid = ls_t002-hbkid.
      gs_t012-hktid = ls_t002-hktid.
      gs_t012-bankn = ls_t002-bankn.
      gs_t012-hkont = ls_t002-hkont.
      gs_t012-awaers = gs_table2-account_currency_code.
      gs_t012-trnid = lv_trnid.
*      read table s_date into data(ls_date) index 1.
*      gs_t012-prdat = ls_date-low."lv_datum.
*      gs_t012-prtim = lv_uzeit.
      gs_t012-prdat = lv_prdat.
      gs_t012-prtim = lv_prtim.
      gs_t012-rcdat = sy-datum.
      gs_t012-rctim = sy-uzeit.
*      gs_t012-bankc = gs_table2-firm_bank_code.
      gs_t012-refbk = gs_table2-reference_number.
*      gs_t012-seqnr = gs_table2-uniqueid.
      gs_t012-vgext = gs_table2-function_code1.
      gs_t012-vgint = gs_table2-payment_type_explantion.
      gs_t012-butxt = gs_table2-explanation.
      gs_t012-stcd2 = gs_table2-tax_number.
      gs_t012-stcd2_1 = gs_table2-tcnumber.
      gs_t012-iban = gs_table2-sender_firm_bank_iban."lv_iban.
      gs_t012-timestamp = gs_table2-payment_date.
      gs_t012-waers = gs_table2-account_currency_code.
      gs_t012-amount = gs_table2-amount.
      gs_t012-balance = gs_table2-balance_after_transaction.



      if gs_t012-amount < 0.
        gs_t012-prtyp = '-'.
      else.
        gs_t012-prtyp = '+'.
      endif.

      append gs_t012 to gt_t012.

      if lv_t012_update = abap_true.

*-------------------------------------------------------------------*
* *- Aynı hareket yeniden yüklendiğinde STATU ve SAKNR artık
* *- sıfırlanmıyor. Önceden her yüklemede statü '1'e, DK boşa
* *- çekiliyordu: statü 7 satırlar sonraki açılışta 5 oluyor (BELNR
* *- dolu olduğu için), hariç tutulan (6) satırlar açılıyor, elle
* *- girilen DK siliniyordu. Sadece bankadan gelen alanlar güncelleniyor.
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
        update zeho_t012
*           set statu     = gs_t012-statu
*               bankc     = gs_t012-bankc
*               saknr     = gs_t012-saknr
           set bankc     = gs_t012-bankc
               bukrs     = gs_t012-bukrs
               hbkid     = gs_t012-hbkid
               hktid     = gs_t012-hktid
               bankn     = gs_t012-bankn
               trnid     = gs_t012-trnid
               prdat     = gs_t012-prdat
               prtim     = gs_t012-prtim
               rcdat     = gs_t012-rcdat
               rctim     = gs_t012-rctim
               refbk     = gs_t012-refbk
               vgext     = gs_t012-vgext
               vgint     = gs_t012-vgint
               butxt     = gs_t012-butxt
               stcd2     = gs_t012-stcd2
               stcd2_1   = gs_t012-stcd2_1
               iban      = gs_t012-iban
               timestamp = gs_t012-timestamp
               waers     = gs_t012-waers
               amount    = gs_t012-amount
               balance   = gs_t012-balance
               prtyp     = gs_t012-prtyp
               awaers    = gs_t012-awaers
               hkont     = gs_t012-hkont
         where seqnr     = gs_t012-seqnr.
*-------------------------------------------------------------------*
        append gs_t012 to gt_t012.
      else.

        insert zeho_t012 from gs_t012.
      endif.


*      append gs_t012 to gt_t012.
*      modify zeho_t012 from gs_t012.

    else.
      move-corresponding  gs_t012c to ls_t002.
      gs_t012c-trnid = lv_trnid.
      gs_t012c-prdat = lv_datum.
      gs_t012c-prtim = lv_uzeit.
      gs_t012c-rcdat = sy-datum.
      gs_t012c-rctim = sy-uzeit.
      gs_t012c-bankc = gs_table2-firm_bank_code.
      gs_t012c-refbk = gs_table2-reference_number.
      gs_t012c-seqnr = gs_table2-uniqueid.
      gs_t012c-vgext = gs_table2-function_code1.
      gs_t012c-vgint = gs_table2-payment_type_explantion.
      gs_t012c-butxt = gs_table2-explanation.
      gs_t012c-stcd2 = gs_table2-tax_number.
      gs_t012c-stcd2_1 = gs_table2-tcnumber.
      gs_t012c-iban = gs_table2-sender_firm_bank_iban."lv_iban.
      gs_t012c-timestamp = gs_table2-payment_date.
      gs_t012c-waers = gs_table2-account_currency_code.
      gs_t012c-amount = gs_table2-amount.
      gs_t012c-balance = gs_table2-balance_after_transaction.

      modify zeho_t012c from gs_t012c.
    endif.


  endloop.
  commit work.



endform.                    "mapt012
