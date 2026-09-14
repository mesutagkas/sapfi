# sapfi

## WBRS odeme turu -> ZEHO_T003 kayit kurali eslestirmesi

`ZEHO_T_WBRS002-PAYMENT_TYPE_EXPLANTION` alani ile `ZEHO_T003-VGITX` alani ayni
metni **farkli granulerlikte** tutar:

| Kaynak | Ornek deger |
|--------|-------------|
| WBRS (web servis) | `Einnahmen - Sonstiges` |
| ZEHO_T003 (kural) | `Einnahmen / Transfer / Geschaeftseinnahmen` |

Bu yuzden birebir (`=`) karsilastirma calismaz. Cozum: her iki metin de
token'lara ayrilip normalize edilerek karsilastirilir, eslesen kuralin
`VGINT` degeri dondurulur.

| Dosya | Icerik |
|-------|--------|
| `src/mdpes_bank_c01.clas.abap` | Eslestirme sinifi `/MDPES/BANK_C01` |
| `src/mdpes_bank_c01_usage.abap` | LOOP icinde kullanim ornegi |
