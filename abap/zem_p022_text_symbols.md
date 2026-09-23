# ZEM_P022 - Text Symbol / Text Element Listesi

SE38 > Goto > Text Elements altında aşağıdaki text symbol ve text elementlerin
bakımı yapılmalıdır (kod içinde `'...'` literal metin kullanılmamıştır - MDP ABAP standardı gereği).

## Selection Text (Block Title)
| Symbol | Metin |
|--------|-------|
| B01    | Form Bilgisi |
| B02    | İmzalayan / Workflow Bilgisi |
| B03    | Workflow'u Başlatan |

## Text Symbols (Hata Mesajları)
| Symbol | Metin |
|--------|-------|
| E01    | Form detayları okunamadı (ZEM_F002_02 subrc <> 0) |
| E02    | ZEM_T003 kaydı bulunamadı |
| E03    | ZEM_T008 kaydı bulunamadı |
| E04    | ZEM_T010 kaydı bulunamadı |
| E05    | Adobe job başlatılamadı |
| E06    | Adobe form çağrısında hata oluştu |
| E07    | Adobe job kapatılırken hata oluştu |
| E08    | PDF boş döndü |
| E09    | Base64 dönüşümü başarısız |
| E10    | ArkSigner uyarlama (config) kaydı bulunamadı |

## Selection Screen Parameter Text (SE38 > Text Elements > Selection Texts)

Ekranda parametrenin yanında görünen etiket buradan gelir. Bu bakım
yapılmadan ekranda teknik alan adı (P_FORMN, P_SNAME, ...) görünür.

| Parametre | Kimin Bilgisi          | Selection Text (etiket)                   |
|-----------|------------------------|--------------------------------------------|
| P_FORMN   | Mutabakat formu         | Mutabakat Form Numarası                     |
| P_SNAME   | İmzalayan (dış kullanıcı) | İmzalayan - Ad                            |
| P_SSURN   | İmzalayan (dış kullanıcı) | İmzalayan - Soyad                         |
| P_SIDNR   | İmzalayan (dış kullanıcı) | İmzalayan - T.C. Kimlik No                |
| P_SEMAIL  | İmzalayan (dış kullanıcı) | İmzalayan - E-posta Adresi                |
| P_STDBY   | Workflow'u başlatan (SAP tarafı, iç kullanıcı) | Workflow'u Başlatan Kullanıcı E-postası |

## İmzacı (dış kullanıcı) bilgisinin kaynağı

`P_SNAME`/`P_SSURN`/`P_SEMAIL` artık `ZEM_T010` değil, müşteri master'ı
üzerinden geliyor:

- **`KNVK`** (müşteri ilgili kişileri) - `PAFKT = '99'` olan satırlar
  "E Mutabakat Yetkilisi" partner fonksiyonunu taşıyor (bkz.
  `signer_partner_function` sabiti, `zem_p022_001.abap`). Bu, projenin en
  başında bahsedilen "sistemde açtığımız 99 numaralı kod"un karşılığı.
- **`ADR6`** (e-posta adresleri) - `KNVK-PRSNR = ADR6-PERSNUMBER` ile
  eşleştirilip e-posta (`SMTP_ADDR`) buradan okunuyor.
- Kullanılan alanlar: `KNVK-KUNNR` (cari, listede görünür), `KNVK-NAMEV`
  (Ad → `P_SNAME`), `KNVK-NAME1` (Soyad → `P_SSURN`), `ADR6-SMTP_ADDR`
  (→ `P_SEMAIL`).
- Bu arama yardımı **form numarasından bağımsız** - tüm müşterilerin
  PAFKT=99 ilgili kişilerini listeler, form numarası bir filtre/sütun
  olarak kullanılmıyor.
- Metod: `f4_help_for_signer` (`zem_p022_003.abap`), `P_SNAME`/`P_SSURN`/
  `P_SEMAIL`'in üçünden de tetiklenebiliyor, hangisinden açılırsa açılsın
  üç alanı birlikte dolduruyor.

`P_FORMN`'un kendi F4'ü (`f4_help_for_form`) hâlâ `ZEM_T010`'dan geliyor
ve sadece form numarasını dolduruyor - imzacı bilgisiyle artık bağlantısı yok.

**Açık nokta:** T.C. Kimlik No (ArkSigner'ın `IDNumber` alanı) için ne
`ZEM_T010`'da ne `KNVK`'da bir kaynak var - `P_SIDNR` hâlâ elle giriliyor,
F4'e dahil değil.
