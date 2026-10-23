# ArkSigner GetStatus – PI/PO arayüz talebi

E-Mutabakat e-imza takip job'ı (EIMZA 4 / 5) için SAP → ArkSigner senkron durum sorgusu.
Mevcut CreateWorkflow arayüzüyle (`SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_EIMZA_OUT_SYN`) aynı
namespace ve aynı yapıda kurulması öneriliyor.

## ArkSigner servisi

| | |
|---|---|
| URL | `https://api.acbakimzala.com/services/WorkflowIntegrationV2/GetStatus?workflowUuid={workflowUuid}` |
| Method | **GET** (POST desteklenmiyor: `405 – The requested resource does not support http method 'POST'`) |
| Header | `Content-Type: application/json` |
| Body | `{ "Config": { "AppId": "...", "Pass": "..." } }` – **GET isteğinde body gönderilmesi zorunlu** |

`workflowUuid` URL query parametresidir ve mesajdaki alandan dinamik doldurulmalıdır.

## Önerilen ESR nesneleri

- `SI_SAP_TO_3RD_ARKSINGER_MUTABAKAT_GETSTATUS_OUT_SYN` / `..._INB_SYN`
- `MT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_REQ` / `..._RES`
- `DT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_REQ`:

  | Alan | Tip | Not |
  |---|---|---|
  | WorkflowUuid | string | URL parametresine gider, body'ye girmez |
  | Config/AppId | string | body |
  | Config/Pass | string | body |

- `DT_SAP_ARKSIGNER_MUTABAKAT_GETSTATUS_RES`:

  | Alan | Tip | Not |
  |---|---|---|
  | ErrorCode | string | |
  | Success | string | `true` / `false` |
  | DataText | string | `Data` **metin** geldiğinde buraya |
  | Data (0..unbounded) | Name, Surname, Email, Status, Description, OrderNo, GroupNo, GroupOrderNo | `Data` **liste** geldiğinde buraya |
  | Error | string | |

## ⚠️ `Data` alanı iki farklı tipte dönüyor

Gerçek yanıtlar (Postman, 23.10.2026):

İş akışı devam ediyor – `Data` liste:
```json
{ "ErrorCode": 0, "Success": true,
  "Data": [ { "Name": "test", "Surname": "test", "Email": "...", "Status": 2,
              "Description": "WaitingApprove", "OrderNo": 1, "GroupNo": null, "GroupOrderNo": null } ],
  "Error": "" }
```

İş akışı kapandı – `Data` metin:
```json
{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı Tamamlandı",  "Error": "" }
{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı İade Edildi", "Error": "" }
{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı İptal Edildi", "Error": "" }
```

Hata:
```json
{ "ErrorCode": 0, "Success": false, "Data": null, "Error": "..." }
```

Response mapping'de `Data` metinse `DataText`'e, listeyse `Data` tablosuna yazılmalı;
iki durumda da mesaj hatasız SAP'ye dönmeli.

## Sorular

1. REST receiver channel GET isteğinde JSON body gönderebiliyor mu?
2. `workflowUuid` URL parametresi mesajdaki alandan dinamik doldurulabiliyor mu?
3. `Data`'nın liste / metin olarak değişen tipi mapping'de karşılanabiliyor mu?
