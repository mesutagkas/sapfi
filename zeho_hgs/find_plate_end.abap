*  FIND_PLATE - sadece metodun sonundaki T022 okuma bloğu değişti.
*  Plaka arama (DO ... ENDDO) kısmı aynen kalır.

    IF lt_plate[] IS NOT INITIAL.
      DATA ls_t022 TYPE zeho_t022.
      LOOP AT lt_plate INTO ls_plate.
        SELECT SINGLE * FROM zeho_t022
        INTO ls_t022
        WHERE plate = ls_plate.
        IF sy-subrc EQ 0.
          cs_out-saknr  = ls_t022-hkont.
          cs_out-info2  = 'HGS'.
          cs_t007-kostl = ls_t022-kostl.
          cs_t007-kostl = ls_t022-kostl.
          cs_out-kostl = ls_t022-kostl.
          cs_out-mwskz = ls_t022-mwskz.
*-------------------------------------------------------------------*
* *- Plaka bazlı Binek/Ticari ayrımı (ZEHO_T022-HTYP2)
* *- BAPI_HGS_OGS_1 akış seçimi için is_out-htyp2'ye taşınır
* *- added by <kullanıcı> 07.10.2026
*-------------------------------------------------------------------*
          cs_out-htyp2 = ls_t022-htyp2.
*-------------------------------------------------------------------*
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
