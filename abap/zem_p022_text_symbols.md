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

## ZEM_T010'a eklenmesi gereken alanlar (kod bunları bekliyor)

`P_FORMN` alanına bağladığımız F4 arama yardımı (`f4_help_for_form` metodu,
`AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_formn`), ZEM_T010'dan seçilen
kaydın ad/soyad/e-posta bilgisini ekrana otomatik dolduruyor. Bunun için
tabloda şu iki alanın SE11'de oluşturulup aktive edilmesi gerekiyor -
kod bu alanların var olduğu varsayımıyla yazıldı, alanlar eklenmeden
`get_form_key`'in derlemesi/çalışması etkilenmez ama F4 arama yardımı
DATA DICTIONARY hatası verir:

| Alan adı | Data Element   | Tip/Uzunluk | Açıklama         |
|----------|----------------|-------------|------------------|
| SNAME    | AD_NAMEFIRS    | CHAR 40     | İmzalayan Ad     |
| SSURN    | AD_NAMELAST    | CHAR 40     | İmzalayan Soyad  |

**Açık nokta:** ZEM_T010'da T.C. Kimlik No (ArkSigner'ın `IDNumber` alanı)
için de bir kolon yok - `P_SIDNR` şimdilik elle giriliyor, F4'e dahil değil.
İstenirse aynı mantıkla bir `SIDNR` (CHAR 11) alanı daha eklenip F4'e
dahil edilebilir.
