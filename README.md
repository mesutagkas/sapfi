# Depar — stoksuz satış (dropshipping) platformu

Tedarikçi ile pazaryeri satıcısını tek panelde buluşturan abonelik tabanlı platform.
Tedarikçi ürünü yükler → satıcı tek tıkla Trendyol / Hepsiburada / N11 mağazasına aktarır →
sipariş geldiğinde iki tarafa bildirim gider → kargoyu tedarikçi alıcıya gönderir →
tahsilat satıcıda kalır, tedarikçi bedeli satıcının carisinden düşer.

Gelir modeli: **satıcıdan aylık abonelik**. Satıştan komisyon alınmaz, tedarikçi üyeliği ücretsizdir.

**Durum:** Faz 1 tamam — kayıt, giriş, oturum ve panel çalışıyor. ([yol haritası](docs/00-YOL-HARITASI.md))

---

## Hızlı başlangıç

```bash
npm install                 # bağımlılıklar (+ shared ve Prisma client derlenir)
cp .env.example .env        # sırları üret: openssl rand -hex 48
npm run infra:up            # PostgreSQL + Redis + Mailpit (Docker)
npm run db:migrate          # tabloları oluştur
npm run db:seed             # paketler, kategoriler, demo hesaplar

npm run dev:api             # http://localhost:3001
npm run dev:web             # http://localhost:3000
npm run dev:worker          # kuyruk işçileri
```

Demo hesaplar: `satici@depar.test` · `tedarikci@depar.test` — şifre `Depar1234!`

Ayrıntılı kurulum, API uçları ve teknik kararlar: **[docs/08-FAZ1-CALISTIRMA.md](docs/08-FAZ1-CALISTIRMA.md)**

---

## Depo yapısı

```
apps/api       NestJS REST API — kimlik doğrulama, çok kiracılılık, firma/panel uçları
apps/web       Next.js 15 — pazarlama sayfaları, giriş/kayıt, oturumlu panel
apps/worker    BullMQ işçileri — stok senkronu, sipariş çekme (Faz 3'te dolacak)
packages/db    Prisma şeması, migration'lar, başlangıç verisi
packages/shared ortak tipler, sabitler, şifre özetleme
docs/          ürün ve teknik dokümantasyon
```

### Komutlar

| Komut | İş |
|---|---|
| `npm run dev:api` / `dev:web` / `dev:worker` | Geliştirme sunucuları |
| `npm run build` | Tüm paketleri derler (sırayla) |
| `npm run test -w @depar/api` | Birim testler |
| `npm run test:e2e -w @depar/api` | Uçtan uca testler (Postgres gerekir) |
| `npm run db:migrate` / `db:seed` / `db:studio` | Veritabanı işlemleri |
| `npm run infra:up` / `infra:down` | Yerel Postgres + Redis + Mailpit |

---

## Dokümantasyon

| Doküman | İçerik |
|---|---|
| [00 — Yol haritası](docs/00-YOL-HARITASI.md) | Faz planı, ekip, takvim, bütçe |
| [01 — Mimari ve sunucu](docs/01-MIMARI-VE-SUNUCU.md) | Teknoloji seçimi, kuyruk mimarisi, sunucu kurulumu, CI/CD, izleme |
| [02 — Veritabanı](docs/02-VERITABANI.md) | Veri modeli ve kararlar · [`schema.sql`](docs/schema.sql) |
| [03 — Pazaryeri entegrasyonları](docs/03-PAZARYERI-ENTEGRASYONLARI.md) | Trendyol / Hepsiburada / N11 API anahtarları ve akışlar |
| [04 — Ödeme & abonelik](docs/04-ODEME-ABONELIK-FATURA.md) | iyzico abonelik, cari hesap, fatura |
| [05 — Güvenlik & KVKK](docs/05-GUVENLIK-KVKK.md) | Anahtar şifreleme, yetki, KVKK, sözleşmeler |
| [06 — Fiyatlandırma mantığı](docs/06-FIYATLANDIRMA-MANTIGI.md) | Paket fiyatları neye göre belirlendi |
| [07 — Marka kılavuzu](docs/07-MARKA-KILAVUZU.md) | İsim, logo, renk, tipografi, dil tonu |
| [08 — Faz 1 çalıştırma](docs/08-FAZ1-CALISTIRMA.md) | Kurulum, API uçları, teknik kararlar |

---

## Marka özeti

- **İsim:** Depar — "atağa kalkmak, hızlanmak".
- **Slogan:** *Stok tutma. Kargolama. Sadece sat.*
- **Renkler:** Lacivert `#0A1733` · Kobalt `#2F6BFF` · Nane `#0FBF95` · Amber `#FFB020`
- Tasarım sistemi tek dosyada: `apps/web/app/globals.css`

> Faz 1 öncesindeki statik HTML prototipi `apps/web` içine taşındı; eski dosyalar git geçmişinde
> (`515766e` işlemesinde) duruyor.

## Sıradaki adım

`docs/08-FAZ1-CALISTIRMA.md` → **§7 Faz 2**: tedarikçi onayı, Excel/XML ile ürün yükleme,
kategori eşleme, katalog ekranı.
