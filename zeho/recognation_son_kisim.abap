*&---------------------------------------------------------------------*
*& zeho_if020~recognation - metodun son kısmı
*& BAPI çağrısından (call function iv_fname ...) sonraki bölüm.
*& Metodun üst kısmı değişmedi.
*&---------------------------------------------------------------------*

  loop at lt_return transporting no fields
  where type ca 'EAX'.
    exit.
  endloop.
  if sy-subrc = 0 .
    call function 'BAPI_TRANSACTION_ROLLBACK'.

    cs_out-icon     = '@0A@'.
    cs_out-log_icon = '@DR@'.
    cs_out-statu    = '3'.
  else.
    read table lt_return assigning <fs_return>
    with key id     = 'RW'
    number = '605'.
    if sy-subrc = 0.

      call function 'BAPI_TRANSACTION_COMMIT'
        exporting
          wait = 'X'.

      cs_out-icon     = '@08@'.
      cs_out-log_icon = '@96@'.
      cs_out-statu    = '5'.
      cs_out-belnr    = <fs_return>-message_v2(10).
*-------------------------------------------------------------------*
* *- Hata yok ama başarı mesajı (RW 605) da yok: sondaki COMMIT WORK
* *- belgeyi statüsüz kaydetmesin
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
    else.
      call function 'BAPI_TRANSACTION_ROLLBACK'.

      cs_out-icon     = '@0A@'.
      cs_out-log_icon = '@DR@'.
      cs_out-statu    = '3'.
*-------------------------------------------------------------------*
    endif.
  endif.

*-------------------------------------------------------------------*
* *- BLART WHERE'den SET'e taşındı. ALV'de değişen belge türü WHERE'de
* *- olunca satır bulunamıyor, statü 5 yazılmıyordu.
* *- added by <kullanıcı> 06.10.2026
*-------------------------------------------------------------------*
  update zeho_t012 set belnr = cs_out-belnr
  statu = cs_out-statu
  blart = cs_out-blart
  xref3 = cs_out-xref3
  lifnr = cs_out-lifnr
  saknr = cs_out-saknr
  kunnr = cs_out-kunnr
  where bankc = cs_out-bankc
  and bukrs = cs_out-bukrs
  and hbkid = cs_out-hbkid
  and hktid = cs_out-hktid
  and bankn = cs_out-bankn
  and trnid = cs_out-trnid
  and refbk = cs_out-refbk
  and prdat = cs_out-prdat
  and prtim = cs_out-prtim
  and seqnr = cs_out-seqnr
  and waers = cs_out-waers
  and amount = cs_out-amount
*  and blart = cs_out-blart
  and prtyp = cs_out-prtyp.

  if sy-dbcnt = 0.
*-- Satır bulunamadı: sessiz geçme, logla
    clear ls_message.
    ls_message-msgid = 'ZEHO'.
    ls_message-msgno = '052'.           " EHO kalemi güncellenemedi (belge &1)
    ls_message-msgty = 'E'.
    ls_message-msgv1 = cs_out-belnr.
    zeho_cl020=>collect_message( is_message = ls_message is_out = cs_out ).
  endif.
*-------------------------------------------------------------------*

  loop at lt_return assigning <fs_return> .
    free : ls_message.
    ls_message-msgid     = <fs_return>-id.
    ls_message-msgno     = <fs_return>-number.
    ls_message-msgty     = <fs_return>-type.
    ls_message-msgv1     = <fs_return>-message_v1.
    ls_message-msgv2     = <fs_return>-message_v2.
    ls_message-msgv3     = <fs_return>-message_v3.
    ls_message-msgv4     = <fs_return>-message_v4.

    call method zeho_cl020=>collect_message(
        is_message = ls_message
        is_out     = cs_out ).
  endloop.
  commit work and wait.
endmethod.
