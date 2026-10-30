# ZEM_P022 – E Mutabakat Gönderim ve E İmza Takip Programı

Portalda müşteri tarafından onaylanan mutabakat formlarını ArkSigner'a (KIP API 5.0,
`WorkflowIntegrationV2/CreateWorkflow`) e-imza iş akışı olarak gönderen job programı.

## Statü akışı (`ZEM_T010-EIMZA`, domain `ZEM_DE_210`)

| Değer | Anlam | Set eden |
|---|---|---|
| boş | İşlem yapılmıyor | – |
| 1 | E-imza işlemi için işlem bekliyor | Portal – gönderim ekranı (cari `ZEM_T015_EIMZA`'da ise) |
| 2 | E-imza gönderildi | Portal (`ZEM_F002_03`, `confirm` / `eimza` istekleri) – yanıtta 1 → 2, aynı FORMN+SEQNO satırında; **ZEM_P022** – ArkSigner'a başarılı gönderimde |
| 3 | E-imza gönderiminde hata alındı | **ZEM_P022** |
| 4 | E-imza reddedildi | **ZEM_P022** (P_CHECK) – ArkSigner "İade Edildi" / "İptal Edildi" |
| 5 | E-imza onaylandı | **ZEM_P022** (P_CHECK) – ArkSigner "Tamamlandı" |

Portal onayda doğrudan 2 yazdığı için "onaylandı ama henüz gönderilmedi" ile "gönderildi"
ayrımı `ZEM_T016_EIMZA-WFKEY` üzerinden yapılır: EIMZA = 2 olup workflowKey'i olmayan
form gönderilir, workflowKey'i olan form bir daha gönderilmez.

## Çalışma mantığı

1. `ZEM_T017_EIMZA`'dan AppId / Pass / WorkflowStartedBy okunur (yoksa job durur).
2. `ZEM_T010`'da `EIMZA = 2` (P_RETRY işaretliyse 3 de) olan satırlar seçilir; form başına
   en yüksek SEQNO'lu satır alınır. `ZEM_T016_EIMZA`'da workflowKey'i olan formlar elenir.
3. Her form için: form detayı → Adobe Form PDF → base64 → imzacı (KNVK işlev 99 + ADR6)
   → proxy ile CreateWorkflow.
4. Yanıt kontrolü: `SUCCESS = true` ve `ERROR_CODE = 0` değilse veya `DATA` içinde
   workflowKey yoksa hata kabul edilir.
5. Sonuç `ZEM_T016_EIMZA`'ya yazılır, `ZEM_T010-EIMZA` 2 veya 3 yapılır, form bazında
   `COMMIT WORK`. Bir formdaki hata diğer formları etkilemez.
6. **P_CHECK:** `ZEM_T016_EIMZA`'da EIMZA = 2 ve workflowKey'i olan formlar için ArkSigner
   GetStatus çağrılır (PI proxy `ZCO_SI_SAP_TO_3RD_ARKSIGNER_GE`):
   - İmzacı listesi dönerse iş akışı sürüyor → statü değişmez, sonraki çalışmada tekrar sorulur.
   - Durum metni dönerse `ZEM_T018_EIMZA`'daki karşılığı (4 / 5) `ZEM_T010` ve
     `ZEM_T016_EIMZA`'ya yazılır.
   - Tanımsız metin veya teknik hata → statü değişmez, mesaj log'a yazılır.
7. Sonuç listesi ALV olarak gösterilir (job'da spool). Tek job iki adımı da çalıştırır.

## Oluşturulacak dictionary nesneleri

Tablo numaraları öneridir; sistemde boş olan numaralarla değiştirin (kodda da güncelleyin).

### `ZEM_T016_EIMZA` – E-imza gönderim logu (Delivery class A)

| Alan | Key | Data element | Tip | Açıklama |
|---|---|---|---|---|
| MANDT | X | MANDT | CLNT 3 | Üst birim |
| FORMN | X | ZEM_DE_001 | CHAR 18 | Mutabakat form numarası |
| SEQNO | | SEQNO | CHAR 3 | EIMZA'nın güncellendiği ZEM_T010 satırı |
| WFKEY | | SYSUUID_C36 | CHAR 36 | ArkSigner workflowKey |
| EIMZA | | ZEM_DE_210 | CHAR 1 | Son e-imza statüsü |
| ERRCD | | CHAR10 | CHAR 10 | ArkSigner ErrorCode |
| ERMSG | | BAPI_MSG | CHAR 220 | Hata metni |
| SNDDT | | DATUM | DATS | Gönderim tarihi |
| SNDTM | | UZEIT | TIMS | Gönderim saati |
| SNDUS | | UNAME | CHAR 12 | Gönderen (job) kullanıcı |
| CHKDT | | DATUM | DATS | Son durum sorgusu tarihi (takip job'ı) |
| CHKTM | | UZEIT | TIMS | Son durum sorgusu saati (takip job'ı) |

### `ZEM_T017_EIMZA` – ArkSigner ayarları (Delivery class C, tek satır)

| Alan | Key | Data element | Tip | Açıklama |
|---|---|---|---|---|
| MANDT | X | MANDT | CLNT 3 | Üst birim |
| APPID | | TEXT40 | CHAR 40 | KIP Uygulama Kimliği (AppId) |
| APASS | | TEXT40 | CHAR 40 | KIP Uygulama Şifresi (Pass) |
| STRBY | | AD_SMTPADR | CHAR 241 | WorkflowStartedBy – KIP kullanıcı adı |

- Bakım: SM30 bakım görünümü, tabloya kısıtlı bir **yetki grubu** atanmalı (şifre içerir).
- Kimlik bilgileri artık kaynak kodda **yok**; her sistemde (DT3 / QA / canlı) ayrı girilir.
- Eski programdaki AppId/Pass bilgileri paylaşıldığı için canlıda farklı/yenilenmiş
  bilgi kullanılması önerilir.

### `ZEM_T018_EIMZA` – ArkSigner durum metni → EIMZA (Delivery class C)

| Alan | Key | Data element | Tip | Açıklama |
|---|---|---|---|---|
| MANDT | X | MANDT | CLNT 3 | Üst birim |
| DTEXT | X | TEXT100 | CHAR 100 | GetStatus yanıtındaki `Data` metni |
| EIMZA | | ZEM_DE_210 | CHAR 1 | Yazılacak e-imza statüsü |

Başlangıç kayıtları (metinler Postman testlerinde görülen yanıtlarla birebir aynı olmalı):

| DTEXT | EIMZA |
|---|---|
| İş Akışı Tamamlandı | 5 |
| İş Akışı İade Edildi | 4 |
| İş Akışı İptal Edildi | 4 |

## Text symbols (SE38 → Goto → Text Elements)

| Sembol | Metin |
|---|---|
| B01 | Seçim Kriterleri |
| B02 | İşlem Adımları |
| D01 | Mutabakat Formu |
| D02 | E-Mutabakat formu e-imza talebi |
| E01 | Form detayları okunamadı (ZEM_F002_02) |
| E02 | ZEM_T003'te form kaydı bulunamadı |
| E03 | ZEM_T008'de login bilgisi bulunamadı |
| E04 | ZEM_T010'da partner bilgisi bulunamadı |
| E05 | Adobe Form işi açılamadı (FP_JOB_OPEN) |
| E06 | Adobe Form çalıştırılamadı |
| E07 | Adobe Form işi kapatılamadı (FP_JOB_CLOSE) |
| E08 | PDF oluşturulamadı |
| E09 | PDF base64'e çevrilemedi |
| E10 | ArkSigner ayarları bulunamadı (ZEM_T017_EIMZA) |
| E11 | Cari için imzacı (KNVK işlev 99) bulunamadı |
| E12 | Cari için birden fazla imzacı (KNVK işlev 99) tanımlı |
| E13 | İmzacının varsayılan e-posta adresi bulunamadı |
| E14 | Tahsilat tutarı sayıya çevrilemedi |
| E15 | ArkSigner hata kodu: |
| E16 | ArkSigner workflowKey döndürmedi |
| E17 | ArkSigner durum sorgusu henüz bağlanmadı |
| E18 | ArkSigner durum eşlemesi bulunamadı (ZEM_T018_EIMZA) |
| I01 | Gönderilecek form bulunamadı |
| I02 | Durumu sorgulanacak form bulunamadı |
| I03 | İş akışı devam ediyor |
| W02 | Tanımsız ArkSigner durumu: |

Selection texts: `S_FORMN` → Form Numarası, `P_RETRY` → Hatalıları yeniden gönder,
`P_SEND` → ArkSigner'a gönder, `P_CHECK` → E-imza durumlarını sorgula.

Eski programdaki `S01`, `W01` sembolleri ve `P_FORMN / P_SNAME / P_SSURN / P_SEMAIL / P_STDBY`
parametreleri artık kullanılmıyor.

## Aktivasyonda kontrol edilecekler

- `response-mt_sap_arksigner_mutabakat_eim` ve `response_data-workflow_key` adları, yanıt
  proxy yapısından (`ZEHO_ARKSINGERMT_SAP_ARKSIGNER` → `ZEHO_ARKSINGERDT_SAP_ARKSIGNE7` →
  `DATA` satır tipi) tahmin edildi. Syntax check farklı ad gösterirse SE11'deki adla değiştirin.
- `CompletionRule` (API'de zorunlu, doğrudan imzacı için 0) proxy request yapısında yoksa
  ESR veri tipine eklenmeli.
- `notification_sms = 2` kodunun KIP panelinde gerçekten SMS olduğu teyit edilmeli.

## Test adımları (DT3)

1. `ZEM_T017_EIMZA`'ya test AppId / Pass / WorkflowStartedBy girin.
2. Bir test formunda `ZEM_T010-EIMZA = 2` olsun (portaldan onay veya SE16N).
3. `ZEM_P022`'yi `S_FORMN` ile önde çalıştırın → ALV'de EIMZA = 2 ve WFKEY dolu olmalı.
4. Aynı formla tekrar çalıştırın → "Gönderilecek form bulunamadı" (mükerrer gönderim yok).
5. Hatalı senaryo: `ZEM_T017_EIMZA`'da şifreyi bozun → EIMZA = 3, ERMSG'de ArkSigner hatası.
   Şifreyi düzeltip `P_RETRY` ile çalıştırın → EIMZA = 2.
6. SM36 ile periyodik job tanımlayın (S_FORMN boş, varyantla).

## Açık kalan – GetStatus proxy bağlantısı

`call_get_status` metodu şimdilik "henüz bağlanmadı" (E17) döner; P_CHECK çalışır ama hiçbir
statüyü değiştirmez. PI proxy'sinin (`ZCO_SI_SAP_TO_3RD_ARKSIGNER_GE`) istek / yanıt yapıları
netleşince yalnızca bu metot doldurulacak.
