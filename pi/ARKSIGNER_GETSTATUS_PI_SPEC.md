# ArkSigner GetStatus – PI/PO arayüz tasarımı

E-Mutabakat e-imza takip job'ı için SAP → PI → ArkSigner senkron durum sorgusu.
Mevcut CreateWorkflow arayüzü (`SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_EIMZA_OUT_SYN`) örnek
alınmıştır; aynı SWC, namespace, sistemler ve ArkSigner bağlantısı kullanılır.
Mevcut arayüzde değişiklik yapılmaz.

## 1. Genel bilgiler

| Konu | Değer |
|---|---|
| Senaryo | SAP ECC → PI/PO → ArkSigner, senkron |
| Amaç | `ZEM_P022`'nin gönderdiği iş akışının durumunu (bekliyor / tamamlandı / iade / iptal) sorgulamak |
| Tetikleyen | SAP'de periyodik takip job'ı (ABAP proxy çağrısı) |
| ArkSigner metodu | `GetStatus` (KIP API 5.0, doküman bölüm 6.2.4) – ArkSigner'da mevcut, değişiklik yok |
| Örnek alınan arayüz | `SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_EIMZA_OUT_SYN` / `_INB_SYN` |

## 2. ArkSigner servis bilgileri

| Konu | Değer |
|---|---|
| URL | `https://api.acbakimzala.com/services/WorkflowIntegrationV2/GetStatus?workflowUuid={workflowUuid}` |
| HTTP method | **GET** – POST desteklenmiyor (`405 – The requested resource does not support http method 'POST'`) |
| Header | `Content-Type: application/json` |
| Body | `{ "Config": { "AppId": "...", "Pass": "..." } }` – **GET isteğinde body zorunlu** |
| URL parametresi | `workflowUuid` = CreateWorkflow yanıtındaki `workflowKey`; her çağrıda farklı |
| Kimlik doğrulama | HTTP seviyesinde yok; AppId / Pass body içinde |
| SSL | CreateWorkflow ile aynı host, mevcut sertifika yeterli |

## 3. ESR nesneleri

| Nesne | Ad |
|---|---|
| Software Component | `SC_TUBORG_EIMZA, 1.0 of turktuborg.com.tr` (mevcut) |
| Namespace | `http://www.turktuborg.com.tr/EIMZA/ARKSINGER` (mevcut) |
| Klasör | `MUTABAKAT` (mevcut) |
| Data Type – istek | `DT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_REQ` |
| Data Type – yanıt | `DT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_RES` |
| Message Type – istek | `MT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_REQ` |
| Message Type – yanıt | `MT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_RES` |
| Service Interface – SAP tarafı | `SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_GETSTATUS_OUT_SYN` (Outbound, Synchronous) |
| Service Interface – ArkSigner tarafı | `SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_GETSTATUS_INB_SYN` (Inbound, Synchronous) |
| Message Mapping – istek | `MM_SAP_TO_ARKSIGNER_MUTABAKAT_GETSTATUS_REQ` |
| Message Mapping – yanıt | `MM_ARKSIGNER_TO_SAP_MUTABAKAT_GETSTATUS_RES` |
| Operation Mapping | `OM_SAP_TO_ARKSIGNER_MUTABAKAT_GETSTATUS` |

### 3.1 `DT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_REQ`

| Alan | Tip | Occurrence | Gittiği yer |
|---|---|---|---|
| WorkflowUuid | xsd:string | 1..1 | URL parametresi (`?workflowUuid=`) |
| Config | (complex) | 1..1 | JSON body |
| Config / AppId | xsd:string | 1..1 | JSON body |
| Config / Pass | xsd:string | 1..1 | JSON body |

ArkSigner'a giden body yalnızca `{"Config":{"AppId":"...","Pass":"..."}}` olmalı.
`WorkflowUuid` body'de kalırsa ArkSigner'ın yok sayıp saymadığı testte kontrol edilmeli;
gerekirse istek mapping'inde body'den çıkarılır.

### 3.2 `DT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_RES`

| Alan | Tip | Occurrence | Not |
|---|---|---|---|
| ErrorCode | xsd:string | 0..1 | |
| Success | xsd:string | 0..1 | `true` / `false` |
| DataText | xsd:string | 0..1 | `Data` **metin** geldiğinde (iş akışı kapandı) |
| Data | (complex) | 0..unbounded | `Data` **liste** geldiğinde (iş akışı devam ediyor) |
| Data / Name | xsd:string | 0..1 | |
| Data / Surname | xsd:string | 0..1 | |
| Data / Email | xsd:string | 0..1 | |
| Data / Status | xsd:string | 0..1 | 0 = WaitingSign, 2 = WaitingApprove |
| Data / Description | xsd:string | 0..1 | |
| Data / OrderNo | xsd:string | 0..1 | |
| Data / GroupNo | xsd:string | 0..1 | null gelebilir |
| Data / GroupOrderNo | xsd:string | 0..1 | null gelebilir |
| Error | xsd:string | 0..1 | |

### 3.3 Yanıt mapping kuralı – `Data` iki farklı tipte dönüyor

| ArkSigner `Data` | SAP'ye gidecek |
|---|---|
| Liste (`[ {...}, {...} ]`) | Her eleman bir `Data` satırı, `DataText` boş |
| Metin (`"İş Akışı Tamamlandı"`) | `DataText` = metin, `Data` boş |
| `null` | İkisi de boş |

İki durumda da mesaj hatasız SAP'ye dönmeli.

## 4. Integration Directory

| Nesne | Değer |
|---|---|
| Sender | SAP ECC business system – CreateWorkflow ile aynı |
| Sender interface | `SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_GETSTATUS_OUT_SYN` |
| Sender channel | Mevcut ABAP proxy sender kanalı (SOAP / XI 3.0) |
| Receiver | ArkSigner business component – CreateWorkflow ile aynı |
| Receiver interface | `SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_GETSTATUS_INB_SYN` |
| Operation mapping | `OM_SAP_TO_ARKSIGNER_MUTABAKAT_GETSTATUS` |
| Konfigürasyon | Yeni Integrated Configuration (ICO) |

### 4.1 Receiver REST kanalı (yeni)

| Ayar | Değer |
|---|---|
| Adapter | REST, Receiver |
| Target URL | `https://api.acbakimzala.com/services/WorkflowIntegrationV2/GetStatus?workflowUuid={uuid}` |
| URL pattern değişkeni | `uuid` ← XPath: `//WorkflowUuid` |
| HTTP operation | **GET** (sabit) |
| İstek formatı | XML → JSON, root element hariç, **body GET isteğinde gönderilecek** |
| Header | `Content-Type: application/json` |
| Yanıt formatı | JSON → XML, root: `MT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_RES` (namespace ile) |
| Kimlik doğrulama | Yok |
| Hata | HTTP 4xx / 5xx SAP'ye hata olarak dönsün |
| Diğer ayarlar | CreateWorkflow receiver kanalıyla aynı |

## 5. SAP tarafı (SPROXY)

| Konu | Değer |
|---|---|
| Üretilecek proxy | `SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_GETSTATUS_OUT_SYN` için consumer proxy |
| Paket | `ZEMUTABAKAT` (mevcut consumer ile aynı) |
| Prefix | `ZEHO_ARKSINGE` (mevcut ile aynı) |
| Sınıf adı | **Elle verilmeli**, ör. `ZEHO_ARKSINGERCO_GETSTATUS` |
| Logical port | Gerekmiyor (PI üzerinden XI protokolü, mevcut proxy gibi) |

Sınıf adı elle verilmeli: otomatik üretilen ad SI adının ilk 30 karakterinden oluşur ve mevcut
`ZEHO_ARKSINGERCO_SI_SAP_TO_3RD` ile çakışır.

## 6. Test senaryoları

Postman'de oluşturulmuş gerçek iş akışları. PI testi bitene kadar iptal edilmemeli.

| workflowUuid | Beklenen yanıt |
|---|---|
| `b7b5e0ca-d55c-4b54-b4e4-429d46b6c8f5` | Bekliyor – `Data` liste, `Status: 2`, `Description: WaitingApprove` |
| `6a9f18a6-17e8-4388-ae30-6ff9bb27963d` | `DataText = "İş Akışı Tamamlandı"` |
| `25a77c1c-9004-47d6-98d9-08354ceaecbf` | `DataText = "İş Akışı İade Edildi"` |
| `7e7a3bad-0a48-4cb7-9cc1-df0dbcfdd2b5` | `DataText = "İş Akışı İptal Edildi"` |
| `00000000-0000-0000-0000-000000000000` | `Success = false`, `Error` dolu |

## 7. Gerçek yanıt örnekleri (Postman, 23.10.2026)

```json
{ "ErrorCode": 0, "Success": true,
  "Data": [ { "Name": "test", "Surname": "test", "Email": "...", "Status": 2,
              "Description": "WaitingApprove", "OrderNo": 1, "GroupNo": null, "GroupOrderNo": null } ],
  "Error": "" }

{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı Tamamlandı",   "Error": "" }
{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı İade Edildi",  "Error": "" }
{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı İptal Edildi", "Error": "" }
```

## 8. PI ekibine sorular

1. REST receiver kanalında **GET isteğinde JSON body** gönderilebiliyor mu?
2. `workflowUuid` URL parametresi mesajdaki alandan (XPath) dinamik doldurulabiliyor mu?
3. `Data`'nın liste / metin olarak değişen tipi yanıt mapping'inde karşılanabiliyor mu (3.3)?
