# 03 — Pazaryeri Entegrasyonları ve API Anahtarları

> ⚠️ **Önce bunu oku.** Pazaryerleri panel menülerini, uç nokta adreslerini ve sürümlerini
> haber vermeden değiştirir. Aşağıdakiler yapının ve akışın doğru anlatımıdır; **her uç noktayı
> kodlamadan önce resmî geliştirici dokümanından teyit et**:
> - Trendyol: <https://developers.trendyol.com>
> - Hepsiburada: <https://developers.hepsiburada.com>
> - N11: <https://www.n11.com> satıcı paneli → Entegrasyon/API bölümü
>
> Entegrasyonu **satıcı adına** yapıyorsun: anahtarlar Depar'a değil, satıcının kendi mağazasına
> aittir. Depar bu anahtarları saklar ve satıcı adına çağrı yapar (bkz. `05-GUVENLIK-KVKK.md`).

---

## 1. Ortak akış (her pazaryeri için aynı)

```
1. Satıcı panelde "Mağaza ekle" der, pazaryerini seçer
2. Ekranda o pazaryerine özel anahtar alma adımları gösterilir (ekran görüntülü)
3. Satıcı anahtarları yapıştırır
4. Depar DOĞRULAMA çağrısı yapar (ör. mağaza bilgisi / ilk sayfa ürün çekme)
   ├── başarılı → channel_accounts.status = 'active'
   └── hatalı   → anlaşılır Türkçe hata ("API Secret yanlış görünüyor")
5. İlk senkron kuyruğa atılır: mevcut ilanlar çekilir, katalogla eşleştirilir
```

Kod tarafında her pazaryeri aynı arayüzü uygular — yeni pazaryeri eklemek bir sınıf yazmak olur:

```ts
interface ChannelAdapter {
  verify(creds): Promise<{ ok: boolean; storeName?: string; error?: string }>;
  fetchCategories(): Promise<RemoteCategory[]>;
  createListing(listing): Promise<{ batchRef: string }>;
  updatePriceStock(items): Promise<{ batchRef: string }>;
  checkBatch(batchRef): Promise<BatchResult>;
  fetchOrders(since: Date): Promise<RemoteOrder[]>;
  pushShipment(orderRef, carrier, trackingNo): Promise<void>;
  fetchReturns(since: Date): Promise<RemoteReturn[]>;
}
```

---

## 2. Trendyol

### 2.1 Anahtarı nasıl alınır (satıcıya anlatacağın adımlar)

1. <https://partner.trendyol.com> adresinden satıcı hesabına giriş yap.
2. Sağ üstteki hesap menüsünden **Hesap Bilgilerim → Entegrasyon Bilgileri** bölümüne gir.
3. Ekranda üç değer vardır:
   - **Satıcı ID (Supplier/Seller ID)** — sayısal
   - **API Key**
   - **API Secret**
4. Daha önce oluşturulmamışsa "Entegrasyon bilgisi oluştur" ile üret.
5. Üçünü Depar'daki forma yapıştır.

> Trendyol tarafında entegrasyon yetkisi için mağazanın aktif ve sözleşmesinin tamam olması gerekir.
> Bazı hesaplarda entegrasyon ekranı satıcı temsilcisi tarafından açılır.

### 2.2 Teknik notlar

| Konu | Not |
|---|---|
| Kimlik doğrulama | HTTP **Basic Auth**: `base64(apiKey:apiSecret)` |
| Zorunlu başlık | `User-Agent: {satıcıID} - SelfIntegration` — bunu göndermeyen istekler engellenebilir |
| Temel adres | Entegrasyon API'si satıcı bazlı yollar kullanır (`.../suppliers/{supplierId}/...`). Güncel taban adresi ve sürümü resmî dokümandan al |
| Ürün açma | Toplu (batch) çalışır: istek `batchRequestId` döner, sonucu ayrı uçtan sorgularsın → `channel_batches` tablosu bunun için var |
| Fiyat/stok | Ayrı ve hızlı bir uç vardır; **tam ürün güncellemesi yerine daima bunu kullan** |
| Sipariş | Paket (shipment package) bazlı gelir; tarih aralığı + sayfalama ile çekilir |
| Kargo | Trendyol anlaşmalı kargo çalışır; "kargolandı" durumunu ve takip numarasını API ile bildirirsin |
| Hız sınırı | Uç bazında sınır var; 429 alırsan `Retry-After` başlığına uy, üstel geri çekilme uygula |
| Sık hata | Barkod tekrarı, zorunlu öznitelik eksikliği, kategori-marka uyuşmazlığı, görsel çözünürlüğü |

### 2.3 Doğrulama çağrısı örneği

```ts
const auth = Buffer.from(`${apiKey}:${apiSecret}`).toString("base64");
const res = await fetch(`${TRENDYOL_BASE}/suppliers/${supplierId}/products?page=0&size=1`, {
  headers: {
    Authorization: `Basic ${auth}`,
    "User-Agent": `${supplierId} - SelfIntegration`,
  },
});
// 200 → anahtar geçerli | 401 → anahtar/secret hatalı | 403 → yetki yok
```

---

## 3. Hepsiburada

### 3.1 Anahtar alma adımları

1. <https://merchant.hepsiburada.com> satıcı paneline gir.
2. **Entegrasyon / API Yönetimi** bölümünden API kullanıcısı oluştur.
3. Alacağın değerler:
   - **Merchant ID** (GUID biçiminde)
   - **Kullanıcı adı (username)** ve **şifre (password)** — servis bazlı olabilir
4. Hepsiburada'da ürün (listing), sipariş (OMS) ve iade servisleri **ayrı uç adresleri** kullanır;
   bazı hesaplarda her servis için ayrı kullanıcı üretilir. Hepsini Depar'a girdir.

### 3.2 Teknik notlar

| Konu | Not |
|---|---|
| Kimlik doğrulama | Basic Auth (`username:password`), bazı servislerde token alışverişi |
| Ortamlar | Gerçek ortamın yanında **test (SIT) ortamı** vardır — entegrasyonu önce orada yaz |
| Ürün akışı | Ürün gönderimi asenkron: gönderirsin, `trackingId` ile durumunu sorarsın |
| Listing ≠ ürün | Ürün (katalog) ile listing (senin satış kaydın) ayrıdır: önce ürün eşleşir/oluşur, sonra listing açılır |
| Fiyat/stok | Listing servisinden toplu güncellenir |
| Sipariş | OMS servisinden paket bazlı çekilir; kargo bilgisini aynı servise yazarsın |
| Sık hata | Kategori özniteliklerinin eksikliği, `merchantSku` tekrarı, KDV oranı uyuşmazlığı |

---

## 4. N11

### 4.1 Anahtar alma adımları

1. <https://www.n11.com> satıcı (magaza) paneline gir.
2. **Entegrasyon / API Bilgileri** bölümüne git.
3. **appKey** ve **appSecret** değerlerini oluştur/kopyala.
4. Depar'daki forma yapıştır.

### 4.2 Teknik notlar

| Konu | Not |
|---|---|
| İki nesil API | N11'in eski **SOAP** servisleri (ProductService, OrderService…) ve daha yeni **REST** uçları vardır. Yeni geliştirmede REST'i tercih et; hesabında hangisi açık, satıcı panelinden teyit et |
| Kimlik doğrulama | `appKey` / `appSecret` başlıkları (REST) ya da SOAP gövdesindeki `auth` bloğu |
| Kategori | Kategori ve zorunlu öznitelikler ayrı servisten çekilir, önbelleğe alınmalı |
| Sipariş | Sayfalama + tarih aralığı; sipariş "onaylama" adımı ayrı bir çağrıdır |
| Sık hata | Sayfa boyutu sınırı, XML alanlarının sırası (SOAP), kategori zorunlu alanları |

---

## 5. Aktarma ve senkron kuralları (tüm kanallar)

### 5.1 Ürün aktarma (`product.push`)

```
1. Satıcı katalogdan varyantı seçer
2. Kategori eşlemesi var mı? yoksa → satıcıdan/admin'den eşleme iste, iş beklet
3. Zorunlu öznitelikler dolu mu? eksikse net hata göster
4. Fiyat kuralı uygula:
   sale_price = supply_price × (1 + kâr%) + komisyon payı + kargo payı
   min_profit altına düşerse AKTARMA, satıcıyı uyar
5. İsteği gönder → batchRef'i channel_batches'e yaz
6. batch.check kuyruğu sonucu sorgular → listings.status = active | error
```

### 5.2 Stok/fiyat senkronu (`stock.sync`)

- Paket seviyesine göre aralık: Başlangıç 4 saat, Profesyonel 15 dakika, Kurumsal 5 dakika.
- **Sadece değişenleri gönder.** Son gönderilen (stok, fiyat) ikilisini `listings` üzerinde tut,
  fark yoksa istek atma — hız sınırına takılmanın 1 numaralı sebebi gereksiz gönderimdir.
- Tedarikçide stok 0 → ilan pasife çekilir ve satıcıya bildirim gider.
- Tedarikçi alış fiyatı arttı → kâr eşiğin altına düştüyse ilan pasife çekilir veya fiyat kuralına
  göre otomatik güncellenir (satıcının tercihi).
- Toplu gönderimde parti boyutu: 100–1.000 kalem arası, pazaryerinin sınırına göre.

### 5.3 Sipariş çekme (`order.pull`)

- Her 2–5 dakikada bir, son çekim zamanından itibaren.
- **Tekrarlı sipariş koruması**: `orders (channel_account_id, remote_order_id)` benzersiz kısıtı.
- Sipariş satırları `listings` üzerinden tedarikçiye bağlanır → `order_items.supplier_id`.
- Sipariş oluşur oluşmaz: satıcıya + tedarikçiye bildirim, cariye borç kaydı (`ledger_entries`).
- Tedarikçi kargo numarasını girer → `shipment.push` ile pazaryerine yazılır.

### 5.4 Hata yönetimi

| Durum | Davranış |
|---|---|
| 401 / 403 | Anahtar bozulmuş: hesabı `suspended` yap, satıcıya "mağazanı yeniden bağla" bildirimi |
| 429 | `Retry-After`'a uy, kuyruğu o hesap için yavaşlat (token bucket) |
| 5xx | Üstel geri çekilme ile 5 deneme, sonra dead-letter + admin alarmı |
| Doğrulama hatası | Kalemi atla, diğerlerini gönder; hatayı `listings.last_error` alanına Türkçe yaz |
| Zaman aşımı | İstek 30 sn'yi geçmesin; idempotency anahtarı ile tekrar gönder |

**Altın kural:** Hiçbir pazaryeri çağrısı kullanıcının HTTP isteği içinde senkron yapılmaz.
Panelde "aktarılıyor" durumu gösterilir, iş kuyrukta yürür.

---

## 6. Yardımcı entegrasyonlar (Faz 4–6)

| Alan | Sağlayıcılar | Ne için |
|---|---|---|
| Kargo | Yurtiçi, Aras, MNG, Sürat, PTT | Tedarikçinin kendi anlaşması; barkod/etiket üretimi ve takip |
| e-Fatura / e-Arşiv | Paraşüt, Logo, Nes, Uyumsoft | Abonelik faturası + tedarikçi→satıcı mal faturası |
| Tedarikçi altyapıları | Ticimax, İkas, Ideasoft, WooCommerce, Shopify | Tedarikçinin mevcut sitesinden ürün/stok çekme |
| Bildirim | E-posta (Postmark/Resend), SMS (İleti Merkezi/Netgsm), WhatsApp Business API, Web Push | Sipariş ve stok uyarıları |

---

## 7. Entegrasyon geliştirme kontrol listesi

- [ ] Her pazaryeri için **kendi test satıcı hesabın** var
- [ ] Anahtarlar şifreli saklanıyor, log'a asla yazılmıyor
- [ ] Her çağrı `request_id` ile loglanıyor (gövde maskeli)
- [ ] Hesap bazlı hız sınırı (token bucket) uygulandı
- [ ] Toplu işlem sonucu takibi (`channel_batches`) çalışıyor
- [ ] Tekrarlı sipariş koruması test edildi
- [ ] Kategori eşleme yönetim ekranı admin panelinde var
- [ ] Anahtar geçersizleştiğinde satıcı bilgilendiriliyor
- [ ] Pazaryeri bakımdayken sistem kuyrukta bekliyor, veri kaybetmiyor
- [ ] Sandbox/test ortamı ile canlı ortam ayrımı `.env` üzerinden
