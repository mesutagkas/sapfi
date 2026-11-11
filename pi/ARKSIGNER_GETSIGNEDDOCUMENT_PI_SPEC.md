# ArkSigner – GetSignedDocument metodu

Kaynak: ArkSigner KIP API dokümanı, sürüm 4.28.3, bölüm 6.1.6 + Postman testi (11.11.2026).
GetStatus ile aynı servis (`WorkflowIntegration`), aynı yöntem (POST) ve aynı kimlik bilgileri kullanılır.

## Amaç

E-imzayla tamamlanmış bir iş akışının imzalı PDF'ini almak. SAP bu PDF'i saklayacak, portal
müşteriye gösterecek.

## İstek

| Konu | Değer |
|---|---|
| URL | `https://api.acbakimzala.com/services/WorkflowIntegration/GetSignedDocument` |
| HTTP method | **POST** |
| Header | `Content-Type: application/json` |

```json
{
  "Config": {
    "AppId": "string",
    "Pass": "string"
  },
  "workflowKey": "string"
}
```

| Alan | Açıklama |
|---|---|
| Config.AppId / Config.Pass | GetStatus'takiyle aynı |
| workflowKey | CreateWorkflow'un döndüğü iş akışı numarası; her çağrıda farklı |

## Yanıt

Başarılı (Postman'de görülen):
```json
{
  "Success": true,
  "Data": {
    "dataBase64": "JVBERi0xLjcKJeLjz9MK..."
  },
  "Error": "",
  "ErrorCode": 0
}
```

Hata (Postman'de görülen – iş akışı e-imzayla imzalanmamışsa):
```json
{
  "Success": false,
  "Data": null,
  "Error": "İmzalanmış adım bulunamadı",
  "ErrorCode": 23
}
```

| Alan | Tip | Açıklama |
|---|---|---|
| Success | bool | Esas başarı kontrolü |
| Data.dataBase64 | string | İmzalı PDF, base64 kodlu. SAP'ye **eksiksiz** taşınmalı |
| Error | string | Hata mesajı |
| ErrorCode | int | Hata kodu |

## Dikkat edilmesi gerekenler

1. **Mesaj boyutu büyük.** Test edilen tek sayfalık belgede yanıt yaklaşık 540 KB; çok sayfalı
   formlarda birkaç MB olabilir. PI'daki mesaj boyutu sınırı ve zaman aşımı buna göre
   ayarlanmalı.
2. **`dataBase64` kesilmemeli.** Alan string olarak, uzunluk sınırı olmadan taşınmalı. SAP tarafı
   base64'ü kendisi çözecek.
3. **Hata durumunda `Data` null gelir.** Mesaj hatasız SAP'ye ulaşmalı; SAP `Success` ve `Error`'a
   bakarak karar verir.

## Test için iş akışı

| workflowKey | Beklenen |
|---|---|
| `18b5180b-bdba-4181-b2fd-672720e430ec` | `Success: true`, `dataBase64` dolu (e-imzalı) |
| `021e2546-ac9c-4d3b-9a1c-8c0a9ebc3133` | `Success: false`, ErrorCode 23 (onay tipi, imzalı dosya yok) |
