# ArkSigner – GetStatus metodu

Kaynak: ArkSigner KIP API dokümanı, sürüm 5.0, bölüm 6.2.4 + Postman testleri (23.10.2026).
Mevcut CreateWorkflow entegrasyonuyla aynı servis (`WorkflowIntegrationV2`), aynı host ve
aynı kimlik bilgileri kullanılır.

## Amaç

CreateWorkflow ile açılan iş akışının güncel durumunu sorgular (bekliyor / tamamlandı /
iade edildi / iptal edildi).

## İstek

| Konu | Değer |
|---|---|
| URL | `https://api.acbakimzala.com/services/WorkflowIntegrationV2/GetStatus` |
| HTTP method | **GET** |
| Query parametresi | `workflowUuid` |
| Header | `Content-Type: application/json` |
| Body | JSON (aşağıda) – GET olmasına rağmen body zorunlu |

```
GET https://api.acbakimzala.com/services/WorkflowIntegrationV2/GetStatus?workflowUuid=6a9f18a6-17e8-4388-ae30-6ff9bb27963d
Content-Type: application/json

{
  "Config": {
    "AppId": "string",
    "Pass": "string"
  }
}
```

| Alan | Yer | Tip | Zorunlu | Açıklama |
|---|---|---|---|---|
| workflowUuid | URL | string | Evet | Sorgulanacak iş akışı. CreateWorkflow yanıtındaki `Data.workflowKey` değeridir; her çağrıda farklı. |
| Config.AppId | Body | string | Evet | Uygulama kimliği (CreateWorkflow'daki ile aynı) |
| Config.Pass | Body | string | Evet | Uygulama şifresi (CreateWorkflow'daki ile aynı) |

## Yanıt

| Alan | Tip | Açıklama |
|---|---|---|
| ErrorCode | int | Hata kodu. Başarısız yanıtta da `0` gelebilir; tek başına başarı göstergesi değildir. |
| Success | bool | İşlemin sonucu. Esas kontrol bu alanla yapılmalı. |
| Data | **liste veya metin** | İş akışı devam ediyorsa imzacı listesi, kapandıysa durum metni, hatada `null` |
| Error | string | Hata mesajı |

### `Data` liste geldiğinde (iş akışı devam ediyor)

| Alan | Tip | Örnek |
|---|---|---|
| Name | string | `test` |
| Surname | string | `test` |
| Email | string | `ornek@firma.com` |
| Status | int | `0` (imza bekleniyor), `2` (onay bekleniyor) |
| Description | string | `WaitingSign`, `WaitingApprove` |
| OrderNo | int | `1` |
| GroupNo | int / null | `null` |
| GroupOrderNo | int / null | `null` |

### Gerçek yanıt örnekleri

Devam ediyor:
```json
{ "ErrorCode": 0, "Success": true,
  "Data": [ { "Name": "test", "Surname": "test", "Email": "ornek@firma.com", "Status": 2,
              "Description": "WaitingApprove", "OrderNo": 1, "GroupNo": null, "GroupOrderNo": null } ],
  "Error": "" }
```

Tamamlandı (imzalandı / onaylandı):
```json
{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı Tamamlandı", "Error": "" }
```

İade edildi (imzacı reddetti):
```json
{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı İade Edildi", "Error": "" }
```

İptal edildi:
```json
{ "ErrorCode": 0, "Success": true, "Data": "İş Akışı İptal Edildi", "Error": "" }
```

Hata (dokümandaki format):
```json
{ "ErrorCode": 0, "Success": false, "Data": null, "Error": "İlgili hata mesajı" }
```

## Dikkat edilmesi gerekenler

1. **POST desteklenmiyor.** POST ile çağrıldığında `405 – "The requested resource does not
   support http method 'POST'."` dönüyor. Method GET olmalı ve body GET isteğiyle gönderilmeli.
2. **`workflowUuid` dinamik.** Her çağrıda SAP'den gelen değerle URL'e eklenmeli.
3. **`Data` iki farklı tipte dönüyor.** İş akışı devam ederken liste, kapandığında metin.
   SAP tarafı iki durumu da almalı; metin geldiğinde kaybolmamalı.

## Test için iş akışları

PI testi bitene kadar iptal edilmemeli.

| workflowUuid | Beklenen `Data` |
|---|---|
| `b7b5e0ca-d55c-4b54-b4e4-429d46b6c8f5` | Liste – `Status: 2`, `WaitingApprove` |
| `6a9f18a6-17e8-4388-ae30-6ff9bb27963d` | `"İş Akışı Tamamlandı"` |
| `25a77c1c-9004-47d6-98d9-08354ceaecbf` | `"İş Akışı İade Edildi"` |
| `7e7a3bad-0a48-4cb7-9cc1-df0dbcfdd2b5` | `"İş Akışı İptal Edildi"` |
