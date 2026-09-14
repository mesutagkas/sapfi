*&---------------------------------------------------------------------*
*&**********************************************************************
*&                         MDP Group                                   *
*&**********************************************************************
*&  Include : /MDPES/BANK_C01 kullanim ornegi                          *
*&  Version : 1.0                          Creation Date: 14.09.2026   *
*&  Author  : MDPGROUP                                                 *
*&**********************************************************************
*&  Description:                                                       *
*&  WBRS kayitlari uzerinde donulurken her satir icin ZEHO_T003        *
*&  kayit kurali (VGINT) belirlenmesi.                                 *
*&**********************************************************************
*&  Email : info@mdpgroup.com                                          *
*&**********************************************************************

*&---------------------------------------------------------------------*
*& Mapper bir kez yaratilir - ZEHO_T003 sadece burada okunur,
*& LOOP icinde tekrar tekrar SELECT yapilmaz.
*&---------------------------------------------------------------------*
  DATA(payment_type_mapper) = NEW /mdpes/bank_c01( ).

  LOOP AT wbrs_data INTO DATA(ls_wbrs).

*   ---Isaret ile birlikte eslestirme (onerilen)-------------------------
*   Ayni aciklama hem '+' hem '-' satirinda olabildigi icin (MSC, MSR)
*   tutarin isareti dogru kurali secmeyi saglar.
    DATA(posting_rule) = payment_type_mapper->get_posting_rule(
        payment_type_explanation = CONV #( ls_wbrs-payment_type_explantion )
        sign                     = /mdpes/bank_c01=>sign_from_amount( ls_wbrs-amount ) ).

*   ---Isaret bilgisi yoksa------------------------------------------------
*   sign parametresi gecilmezse isaret filtresi uygulanmaz, ilk eslesen
*   kural dondurulur.
*   DATA(posting_rule) = payment_type_mapper->get_posting_rule(
*       payment_type_explanation = CONV #( ls_wbrs-payment_type_explantion ) ).

    IF posting_rule IS INITIAL.
*     ---Eslesme bulunamadi: ZEHO_T003 bakimi eksik----------------------
*     Mesaj Message Class uzerinden verilmeli
      CONTINUE.
    ENDIF.

*   ---Bulunan kayit kurali hedef alana atanir---------------------------
    ls_wbrs-vgint = posting_rule.

  ENDLOOP.

*&---------------------------------------------------------------------*
*& Beklenen eslesme tablosu (mevcut ZEHO_T003 bakimi ile)
*&
*&  WBRS payment_type_explantion | Isaret | Eslesen T003-VGITX                             | VGINT
*&  ----------------------------- | ------ | ---------------------------------------------- | -----
*&  Einnahmen - Sonstiges         |   +    | Einnahmen / Transfer / Geschaeftseinnahmen     | TRF
*&  Einnahmen - Sonstiges         |   -    | Sonstiges  (TRF sadece '+' bakimli)            | MSC
*&  Transfer - Sonstiges          |   +    | Einnahmen / Transfer / Geschaeftseinnahmen     | TRF
*&  Sonstiges                     |  + -   | Sonstiges                                      | MSC
*&  Ausgehen und Essen            |  + -   | Ausgehen und Essen / Porto- und Versandkosten  | MSR
*&  KFZ-Steuer                    |   -    | KFZ-Steuer / Umsatzsteuer                      | VRG
*&---------------------------------------------------------------------*
