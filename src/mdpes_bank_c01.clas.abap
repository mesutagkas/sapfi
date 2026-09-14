*&---------------------------------------------------------------------*
*&**********************************************************************
*&                         MDP Group                                   *
*&**********************************************************************
*&  Class   : /MDPES/BANK_C01                                          *
*&  Version : 1.0                          Creation Date: 14.09.2026   *
*&  Author  : MDPGROUP                                                 *
*&**********************************************************************
*&  Class Description:                                                 *
*&  WBRS web servisinden gelen odeme turu aciklamasini (orn.           *
*&  "Einnahmen - Sonstiges") ZEHO_T003 banka kayit kurali koduna       *
*&  (VGINT) cevirir.                                                   *
*&                                                                     *
*&  Problem: Iki taraf ayni metni farkli granulerlikte tutar.          *
*&    WBRS   : "Einnahmen - Sonstiges"                                 *
*&    T003   : "Einnahmen / Transfer / Geschaeftseinnahmen"            *
*&  Bu yuzden birebir (=) karsilastirma calismaz. Her iki metin de     *
*&  token'lara ayrilip normalize edilerek karsilastirilir.             *
*&**********************************************************************
*&  Program - Changes                                                  *
*&  +---------------------------------------------------------------+  *
*&  | Code           | Programmer    | Title / Change               |  *
*&  +---------------------------------------------------------------+  *
*&  |                | MDPGROUP      | NEW                          |  *
*&  +---------------------------------------------------------------+  *
*&  Email : info@mdpgroup.com                                          *
*&**********************************************************************

CLASS /mdpes/bank_c01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

* ---Constants-------------------------
    CONSTANTS:
      "! ZEHO_T003-VGITX icindeki kategori ayraci
      "! "Einnahmen / Transfer / Geschaeftseinnahmen"
      category_separator TYPE string VALUE `/`,
      "! WBRS aciklamasindaki ayrac. BILEREK bosluklu ( - ) tanimlandi:
      "! duz '-' ile bolunseydi "KFZ-Steuer" -> "KFZ" + "Steuer" olur ve
      "! hicbir kural ile eslesmezdi.
      detail_separator   TYPE string VALUE ` - `,
      "! ZEHO_T003 +/- alani (VOZEI) degerleri
      sign_incoming      TYPE char1 VALUE '+',
      sign_outgoing      TYPE char1 VALUE '-'.

* ---Methods---------------------------
    METHODS constructor.

    "! WBRS odeme turu aciklamasindan ZEHO_T003 kayit kuralini bulur.
    "! Aciklama soldan saga token'lara ayrilir, ilk eslesen token kazanir
    "! (ilk token ana kategoridir).
    "! @parameter payment_type_explanation | WBRS aciklamasi ("Einnahmen - Sonstiges")
    "! @parameter sign                     | Hareket isareti '+' / '-' (bos ise isaret filtresi uygulanmaz)
    "! @parameter result                   | ZEHO_T003-VGINT, eslesme yoksa initial
    METHODS get_posting_rule
      IMPORTING payment_type_explanation TYPE string
                sign                     TYPE char1 OPTIONAL
      RETURNING VALUE(result)            TYPE zeho_t003-vgint.

    "! Tutarin isaretinden ZEHO_T003-VOZEI degerini uretir
    CLASS-METHODS sign_from_amount
      IMPORTING amount        TYPE numeric
      RETURNING VALUE(result) TYPE char1.

  PRIVATE SECTION.

* ---Type Definitions------------------
    TYPES: BEGIN OF ty_rule_index,
             token TYPE string,           "normalize edilmis tekil kategori
             sign  TYPE char1,            "ZEHO_T003-VOZEI
             vgint TYPE zeho_t003-vgint,  "hedef kayit kurali
           END OF ty_rule_index.

    TYPES ty_t_rule_index TYPE SORTED TABLE OF ty_rule_index
                          WITH NON-UNIQUE KEY token.

    TYPES ty_t_token TYPE STANDARD TABLE OF string WITH EMPTY KEY.

* ---Constants-------------------------
    "! Kismi eslesmede yanlis pozitifleri onlemek icin asgari token uzunlugu
    CONSTANTS minimum_token_length TYPE i VALUE 4.

* ---Data------------------------------
    DATA m_rule_index TYPE ty_t_rule_index.

* ---Methods---------------------------
    METHODS build_rule_index.

    METHODS split_into_tokens
      IMPORTING text          TYPE string
      RETURNING VALUE(result) TYPE ty_t_token.

    METHODS normalize
      IMPORTING text          TYPE string
      RETURNING VALUE(result) TYPE string.

    METHODS find_exact
      IMPORTING search_token  TYPE string
                sign          TYPE char1
      RETURNING VALUE(result) TYPE zeho_t003-vgint.

    METHODS find_by_contains
      IMPORTING search_token  TYPE string
                sign          TYPE char1
      RETURNING VALUE(result) TYPE zeho_t003-vgint.

ENDCLASS.


CLASS /mdpes/bank_c01 IMPLEMENTATION.

*&---------------------------------------------------------------------*
*& Constructor - kural indeksi bir kez kurulur
*&---------------------------------------------------------------------*
  METHOD constructor.

    build_rule_index( ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& ZEHO_T003 okunur ve "token -> VGINT" indeksi kurulur.
*& Tablo LOOP basina degil, tek seferde okunur.
*&---------------------------------------------------------------------*
  METHOD build_rule_index.

    SELECT vgint, vozei, vgitx
      FROM zeho_t003
      INTO TABLE @DATA(rules)
      ORDER BY vgint, vozei.

    LOOP AT rules INTO DATA(rule).

*     "Einnahmen / Transfer / Geschaeftseinnahmen" -> 3 ayri token
      DATA(tokens) = split_into_tokens( CONV #( rule-vgitx ) ).

      LOOP AT tokens INTO DATA(token).
        INSERT VALUE #( token = token
                        sign  = rule-vozei
                        vgint = rule-vgint ) INTO TABLE m_rule_index.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Ana eslestirme. Once tam token eslesmesi, bulunamazsa kismi eslesme.
*&---------------------------------------------------------------------*
  METHOD get_posting_rule.

    DATA(tokens) = split_into_tokens( payment_type_explanation ).

*   ---1. adim: tam eslesme. Soldan saga oncelik - ilk token ana kategoridir
    LOOP AT tokens INTO DATA(token).
      result = find_exact( search_token = token
                           sign         = sign ).
      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDLOOP.

*   ---2. adim: kismi eslesme (yazim farkliliklari icin emniyet subabi)
    LOOP AT tokens INTO token.
      result = find_by_contains( search_token = token
                                 sign         = sign ).
      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Metni once "/" sonra " - " ile bolerek normalize token listesi uretir.
*& Her iki tablo tarafinda da ayni mantik kullanilir.
*&---------------------------------------------------------------------*
  METHOD split_into_tokens.

    DATA categories TYPE ty_t_token.
    DATA details    TYPE ty_t_token.

    SPLIT text AT category_separator INTO TABLE categories.

    LOOP AT categories INTO DATA(category).

      SPLIT category AT detail_separator INTO TABLE details.

      LOOP AT details INTO DATA(detail).
        DATA(token) = normalize( detail ).
        IF token IS NOT INITIAL.
          APPEND token TO result.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Bas/son ve coklu bosluklari temizler, buyuk harfe cevirir
*&---------------------------------------------------------------------*
  METHOD normalize.

    result = text.
    CONDENSE result.
    result = to_upper( result ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Token'in birebir esitligi. Isaret verildiyse VOZEI de kontrol edilir.
*&---------------------------------------------------------------------*
  METHOD find_exact.

    LOOP AT m_rule_index INTO DATA(rule) WHERE token = search_token.
      IF sign IS INITIAL OR rule-sign = sign.
        result = rule-vgint.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Token'in icerik bazli eslesmesi. Kisa token'lar yanlis pozitif
*& uretecegi icin minimum uzunluk altinda denenmez.
*&---------------------------------------------------------------------*
  METHOD find_by_contains.

    IF strlen( search_token ) < minimum_token_length.
      RETURN.
    ENDIF.

    LOOP AT m_rule_index INTO DATA(rule).

      IF sign IS NOT INITIAL AND rule-sign <> sign.
        CONTINUE.
      ENDIF.

      IF rule-token CS search_token OR search_token CS rule-token.
        result = rule-vgint.
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Tutar negatifse '-', degilse '+'
*&---------------------------------------------------------------------*
  METHOD sign_from_amount.

    result = COND #( WHEN amount < 0 THEN sign_outgoing
                     ELSE sign_incoming ).

  ENDMETHOD.

ENDCLASS.
