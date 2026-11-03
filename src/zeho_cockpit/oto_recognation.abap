method oto_recognation. "burası otomatik muhasebeleştirme adımının olduğu yer.

    data: lv_ftr03 type xfeld,
          lv_check type xfeld,
          lv_begda type zeho_t016-begda,
          ls_bseg  type bseg,
          ls_t012  type zeho_t012,
          lv_subrc type sy-subrc.


    data: lo_proxy   type ref to zeho_bltco_wsbank_payment_serv,
          inputtest  type zeho_bltupdate_payment_status5,
          outputtest type zeho_bltupdate_payment_status4.

    data : lc_sys_exception     type ref to cx_ai_system_fault,
           lc_sys_app_fault     type ref to cx_ai_application_fault,
           lv_error_description type string.


    data: lt_param type table of zeho_t010,
          ls_param type zeho_t010.

    clear lv_begda.
    select single begda from zeho_t016
      into lv_begda
      where uname = sy-uname.

    clear lv_ftr03.
    select single parvl from zeho_t017
    into lv_ftr03
    where parid = '13'.

    clear ms_row.
    loop at it_rows into ms_row.
      unassign <fs_out>.
      read table mt_out assigning <fs_out> index ms_row-index.
      if <fs_out>-prdat gt lv_begda.
        if <fs_out>-statu eq '4' or <fs_out>-statu eq '1'. "or <fs_out>-statu eq '7'.
          if <fs_out>-belnr is initial.
            clear lv_check.
            me->check_dublicate_document(
              exporting
                is_rows  = <fs_out>
              importing
                ev_check = lv_check
            ).
            if lv_check eq abap_false.
              clear: ls_bseg, lv_subrc.
              me->check_referance(
                exporting
                  is_out   = <fs_out>
                importing
                  es_bseg  = ls_bseg
                  ev_subrc = lv_subrc
              ).

              if lv_subrc eq 0.
                move-corresponding <fs_out> to ls_t012.
                ls_t012-belnr = ls_bseg-belnr.
*                ls_t012-statu = '5'.
*                <fs_out>-statu = '5'.

                data lv_tcode_ref type bkpf-tcode.
                clear lv_tcode_ref.
                select single tcode from bkpf
                  into lv_tcode_ref
                  where bukrs = ls_bseg-bukrs
                    and belnr = ls_bseg-belnr
                    and gjahr = ls_bseg-gjahr.
                if sy-subrc = 0 and lv_tcode_ref <> 'ZEHO003'.
                  ls_t012-statu = '7'.
                else.
                  ls_t012-statu = '5'.
                endif.
                <fs_out>-statu = ls_t012-statu.

                <fs_out>-icon     = '@08@'.
                <fs_out>-belnr = ls_bseg-belnr.
                modify zeho_t012 from ls_t012.
*-------------------------------------------------------------------*
* *- Bağ hemen kalıcılaştırılıyor: sonraki satırın muhasebeleştirmesi
* *- hata verirse recognation BAPI_TRANSACTION_ROLLBACK çağırıyor ve
* *- commit edilmemiş bu MODIFY de geri alınıyordu; ekranda belge
* *- numarası görünürken DB'de bağ kalmıyor, aynı belge başka satıra
* *- da veriliyordu. Diğer oturumlar da bağı hemen görür.
* *- added by <kullanıcı> 03.11.2026
*-------------------------------------------------------------------*
                commit work and wait.
*-------------------------------------------------------------------*
                message s038(zeho) display like 'S'.
* İlgili Kayıt Daha Önce Muhasebeleştirilmiştir. Kayıt Güncellenmiştir.

              else.

                data: lv_recording type char1,
                      lv_grntl     type char1.

                clear: lv_recording, lv_grntl.

                select single recording grntl
                  from zeho_t016
                  into (lv_recording, lv_grntl)
                  where uname eq sy-uname
                    and ( bukrs eq <fs_out>-bukrs or bukrs eq '*' )
                    and ( hbkid eq <fs_out>-hbkid or hbkid eq '*' )
                    and ( hktid eq <fs_out>-hktid or hktid eq '*' )
                    and begda le sy-datum
                    and endda ge sy-datum.

                if lv_recording eq 'X'.
                  "Muhasebeleştirme yetkisi var, kayıt işlenebilir
                  call method io_object->zeho_if020~recognation(
                    exporting
                      iv_fname = iv_fname
                      iv_ftr03 = lv_ftr03
                    changing
                      cs_out   = <fs_out> ).

                elseif lv_grntl eq 'X' or lv_grntl eq ' ' .
                  "Sadece görüntüleme yetkisi var, muhasebeleştirme yapılamaz
                  message s046(zeho) display like 'E'.
                  exit.
                endif.
                if <fs_out>-statu = '5'.


                  data(disabled_fields) = value string_table(
                    ( `XREF3` ) ( `KUNNR` ) ( `LIFNR` ) ( `SAKNR` ) ( `AKONT` ) ( `BSCHL` )
                    ( `PSPEL` ) ( `PRCTR` ) ( `BLART` ) ( `KOSTL` ) ( `AUFNR` ) ( `UMSKZ` ) ).

                  loop at disabled_fields into data(disabled_field).
                    delete <fs_out>-celltab where fieldname = disabled_field.
                    insert value lvc_s_styl( fieldname = disabled_field
                                             style     = cl_gui_alv_grid=>mc_style_disabled )
                           into table <fs_out>-celltab.
                  endloop.

                  " ALV hücre stillerini FIELDNAME sırasına göre okur
*                  sort <fs_out>-celltab by fieldname.
*-------------------------------------------------------------------*
                endif.
              endif.


              read table mt_out assigning <fs_out> index ms_row-index.
              select parid,
         parvl
    from zeho_t010
    into corresponding fields of table @lt_param
   where parid in ( '1', '2', '4', '6' ) and bankc eq @<fs_out>-bankc .


              loop at lt_param into ls_param.
                case ls_param-parid.
                  when '1'.
                    inputtest-user_name = ls_param-parvl.

                  when '2'.
                    inputtest-password = ls_param-parvl.

                  when '4'.
                    inputtest-firm_apicode = ls_param-parvl.

                endcase.

              endloop.

              inputtest-payment_status_type_id = '532'."ls_param-parvl.
              inputtest-payment_id = <fs_out>-trnid.
              inputtest-e_rpref_no = <fs_out>-belnr.

              try.
                  create object lo_proxy
                    exporting
                      logical_port_name = 'ZEHO_BLTUPDATE_LP'.

                  lo_proxy->update_payment_status_info_wi2(
                    exporting
                      input  = inputtest
                    importing
                      output = outputtest
                  ).

                catch cx_ai_system_fault into lc_sys_exception.
                  lv_error_description = lc_sys_exception->errortext.

                catch cx_ai_application_fault into lc_sys_app_fault.
                  lv_error_description = lc_sys_app_fault->get_text( ).

              endtry.



            else.
              message w035(zeho) display like 'S'.
* Seçilen İşlem için daha önceden muhasebe kaydı oluşturulmuştur.
            endif.
          else.
            message w035(zeho) display like 'S'.
* Seçilen İşlem için daha önceden muhasebe kaydı oluşturulmuştur.
            exit.
          endif.
        elseif <fs_out>-statu eq '6'.
          message w036(zeho) display like 'S'.
* Seçilen Satır Hariç Tutulmuştur.
        endif.
      else.
        message w039(zeho).
* Canlı geçiş tarihi öncesine kayıt atılamaz.
      endif.
    endloop.



    call function 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      importing
        e_grid = go_alv_grid.

    if go_alv_grid is bound.
      call method go_alv_grid->refresh_table_display
        exporting
          is_stable = value lvc_s_stbl( row = abap_true col = abap_true )
        exceptions
          finished  = 1
          others    = 2.
    endif.

  endmethod.
