# 00 — Yol Haritası (adım adım ne yapacağız?)

> Bu doküman "sıfırdan canlıya" giden ana plandır. Her fazın sonunda **çıktı** ve **kontrol listesi** var.
> Teknik detaylar 01–07 numaralı dokümanlarda.

---

## 0. Özet: sistem ne yapıyor?

```
TEDARİKÇİ                      DEPAR                          SATICI                 PAZARYERİ
---------                      -----                          ------                 ---------
ürün + stok + fiyat  ──►  merkezi katalog  ──►  seçtiği ürünü aktarır  ──►  Trendyol/HB/N11 ilanı
                          stok senkronu (cron)                              (satıcının kendi mağazası)
        ◄── sipariş ───   sipariş dağıtıcı   ◄── sipariş ──────────────────  alıcı satın alır
   kargoyu alıcıya atar   bildirim + cari      net kâr satıcıda
```

Para akışı: **alıcı → pazaryeri → satıcı**, ayrıca **satıcı → tedarikçi** (cari hesap üzerinden).
Depar hiçbir zaman mal bedeline dokunmaz; sadece abonelik tahsil eder. (Bu, ödeme kuruluşu lisansı
gerektirmemesi açısından kritik bir tercihtir — bkz. `05-GUVENLIK-KVKK.md`.)

---

## Faz 0 — Kuruluş ve hesaplar (1. hafta)

Kod yazmadan önce bitmesi gerekenler:

1. **Şirket**: Limited şirket kur (stopaj/e-fatura ve pazaryeri sözleşmeleri için şart).
2. **Alan adı**: `depar.com.tr` + `depar.app` (yedek). DNS'i Cloudflare'e taşı.
3. **Kurumsal e-posta**: Google Workspace ya da Microsoft 365 (`destek@`, `tedarikci@`, `no-reply@`).
4. **Pazaryeri satıcı hesapları**: Test edebilmek için kendi adına Trendyol, Hepsiburada ve N11
   satıcı hesabı aç. Entegrasyonu ancak gerçek bir satıcı hesabı ile test edebilirsin.
5. **Ödeme sağlayıcı başvurusu**: iyzico (abonelik ürünü) ve/veya PayTR — onay 3–10 iş günü sürer,
   en erken başlat.
6. **e-Fatura/e-Arşiv entegratörü**: Paraşüt, Logo İşbaşı, Nes Bilgi veya Uyumsoft.
7. **Bulut hesabı**: Hetzner (ucuz, Almanya) veya AWS/Google Cloud. KVKK açısından veri yeri tercihini
   şimdiden karara bağla (bkz. `05`).
8. **GitHub organizasyonu** + bu repo.

**Çıktı:** Tüm hesaplar açık, API anahtarları alınabilir durumda.

---

## Faz 1 — Temel iskelet (2.–3. hafta)

| İş | Detay |
|---|---|
| Monorepo kurulumu | `apps/api` (NestJS), `apps/web` (Next.js), `apps/worker`, `packages/shared` |
| Veritabanı | PostgreSQL + Prisma; `docs/schema.sql` şemasını uygula |
| Kimlik doğrulama | E-posta + şifre, JWT (access 15 dk / refresh 30 gün), rol: `seller`, `supplier`, `admin` |
| Çok kiracılı yapı | Her kayıt `tenant_id` taşır; sorgular tenant filtresiyle çalışır |
| Frontend taşıma | Bu depodaki statik sayfalar Next.js bileşenlerine dönüştürülür (CSS aynen kullanılabilir) |
| Ortamlar | `dev` (lokal Docker), `staging`, `prod` |

**Çıktı:** Kullanıcı kayıt olabiliyor, giriş yapabiliyor, boş panel görüyor.

---

## Faz 2 — Tedarikçi ve katalog (4.–5. hafta)

1. Tedarikçi başvuru formu + admin onay ekranı (vergi levhası, imza sirküleri yüklemesi).
2. Ürün yükleme yolları:
   - **Excel/CSV** şablonu (indir → doldur → yükle → satır satır doğrulama raporu)
   - **XML feed** (URL ver, saatlik çekilsin)
   - **API** (tedarikçiye özel token ile `POST /v1/supplier/products`)
   - **Hazır altyapılar**: Ticimax, İkas, Ideasoft, WooCommerce eklentileri (Faz 6)
3. Kategori ağacı + pazaryeri kategori eşleme tablosu (en kritik ve en çok zaman alan iş).
4. Varyant (renk/beden), görsel, barkod (GTIN), desi/kg, KDV oranı alanları.
5. Görsel depolama: S3 uyumlu obje deposu + CDN.

**Çıktı:** Tedarikçi ürün yükleyebiliyor, katalogda listeleniyor.

---

## Faz 3 — Satıcı ve pazaryeri entegrasyonu (6.–9. hafta) ⭐ en kritik faz

1. Satıcı pazaryeri hesabını bağlar (API anahtarları — `03-PAZARYERI-ENTEGRASYONLARI.md`).
2. **Ürün aktarma**: katalogdan seçilen ürün, satıcının mağazasına ilan olarak açılır
   (kategori eşleme + zorunlu öznitelikler + fiyat kuralı).
3. **Stok/fiyat senkronu**: kuyruk üzerinden periyodik (paket seviyesine göre 4 sa / 15 dk / 5 dk).
4. **Sipariş çekme**: periyodik çekme + destekleniyorsa webhook.
5. **Sipariş dağıtımı**: sipariş satırı hangi tedarikçiye aitse ona düşer; iki tarafa bildirim.
6. **Kargo/takip**: tedarikçi kargo numarasını girer → pazaryerine "kargolandı" bilgisi yazılır.
7. **İade/iptal**: pazaryerinden gelen iade tedarikçiye yönlenir, cariye alacak işlenir.

**Çıktı:** Uçtan uca bir sipariş, elle müdahale olmadan tamamlanıyor.

---

## Faz 4 — Abonelik ve para (10.–11. hafta)

1. Paket tanımları ve limit kontrolü (ürün, mağaza, sipariş, kullanıcı, senkron sıklığı).
2. 14 gün ücretsiz deneme (kartsız), deneme bitiminde otomatik kilit.
3. iyzico/PayTR ile tekrarlayan tahsilat + 3D Secure + başarısız ödeme yeniden deneme akışı.
4. Satıcı–tedarikçi **cari hesap**: her sipariş tedarikçiye borç yazar, haftalık mutabakat.
5. e-Fatura: abonelik faturası Depar'dan satıcıya; mal faturası tedarikçiden satıcıya.

**Çıktı:** Gelir tahsil edilebiliyor, borç/alacak takip ediliyor.

---

## Faz 5 — Yayına alma (12. hafta)

- Yük testi (100 satıcı × 5.000 ürün senaryosu), rate limit ayarı.
- Sentry + uptime izleme + alarm kanalları.
- KVKK metinleri, mesafeli satış, kullanıcı sözleşmeleri, çerez politikası.
- 10–20 tedarikçi ve 30–50 satıcı ile kapalı beta.
- Destek kanalı (WhatsApp Business + yardım merkezi).

---

## Faz 6 — Büyüme (3.–6. ay)

Çiçeksepeti / PttAVM / Amazon TR / Pazarama entegrasyonları · kargo firması API'leri ·
otomatik fiyatlandırma ve rakip takibi (buybox) · tedarikçi performans puanı ·
mobil uygulama · Depar public API · bayilik/affiliate programı.

---

## Ekip ve bütçe (gerçekçi tahmin)

| Rol | Kişi | Not |
|---|---|---|
| Backend (Node/NestJS) | 2 | Entegrasyonlar zaman alır, 1 kişi yetmez |
| Frontend (Next.js) | 1 | Bu depodaki tasarım hazır |
| DevOps | 0,5 | Yarı zamanlı yeter |
| Ürün/destek | 1 | Tedarikçi ilişkileri + satıcı onboarding |

**Aylık altyapı maliyeti (başlangıç, ~100 satıcı):**

| Kalem | Yaklaşık aylık |
|---|---|
| Uygulama + worker sunucusu (2×4 vCPU/8GB) | 40–60 € |
| Yönetilen PostgreSQL (+yedek) | 30–60 € |
| Redis | 10–20 € |
| Obje deposu + CDN (görseller) | 10–30 € |
| E-posta/SMS/push | 20–50 € |
| İzleme (Sentry vb.) | 0–30 € |
| **Toplam** | **~110–250 € / ay** |

> Rakamlar 2026 3. çeyrek için kabaca alınmıştır; sözleşme öncesi sağlayıcıdan teyit et.
> Maliyet, satıcı sayısından çok **aktif ürün adedi × senkron sıklığı** ile büyür — fiyatlandırmanın
> bu iki eksene bağlanmasının sebebi budur (`06-FIYATLANDIRMA-MANTIGI.md`).

---

## MVP'de olmayacaklar (bilerek)

Depar'ın mal bedeline aracılık etmesi (ödeme kuruluşu lisansı gerekir), kendi kargo anlaşması,
yurt dışı pazaryerleri, çoklu para birimi, kendi e-ticaret sitesi kurma özelliği.
Bunlar 6. aydan sonra tartışılır.
