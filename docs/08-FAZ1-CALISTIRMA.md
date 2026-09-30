# 08 — Faz 1: Ne kuruldu, nasıl çalıştırılır?

Faz 1 tamamlandı. Bu doküman **ne yapıldığını madde madde** ve **projeyi sıfırdan nasıl
ayağa kaldıracağını** anlatır.

---

## 1. Faz 1'de yapılanlar

| # | İş | Durum | Nerede |
|---|---|---|---|
| 1 | Monorepo kurulumu (npm workspaces) | ✅ | `apps/*`, `packages/*` |
| 2 | Veritabanı şeması + migration + başlangıç verisi | ✅ | `packages/db` |
| 3 | NestJS API iskeleti (config, hata yönetimi, hız sınırı, health) | ✅ | `apps/api` |
| 4 | Kimlik doğrulama: kayıt, giriş, refresh rotasyonu, çıkış, `/me` | ✅ | `apps/api/src/auth` |
| 5 | Çok kiracılı yapı (`tenant_id` + rol tabanlı yetki) | ✅ | `apps/api/src/common`, `tenants` |
| 6 | Statik tasarımın Next.js'e taşınması | ✅ | `apps/web` |
| 7 | Oturumlu panel (satıcı + tedarikçi görünümü, boş durum) | ✅ | `apps/web/app/panel` |
| 8 | Kuyruk altyapısı iskeleti (BullMQ, 8 kuyruk) | ✅ | `apps/worker` |
| 9 | Testler: 4 birim + 7 uçtan uca | ✅ | `apps/api/src/**.spec.ts`, `apps/api/test` |
| 10 | Yerel altyapı (Postgres + Redis + Mailpit) | ✅ | `docker-compose.dev.yml` |

**Faz 1 çıktısı hedefi:** *"Kullanıcı kayıt olabiliyor, giriş yapabiliyor, boş panel görüyor."* → sağlandı.

---

## 2. Klasör yapısı

```
depar/
├── apps/
│   ├── api/          NestJS — REST API (port 3001)
│   │   ├── src/auth/         kayıt, giriş, token, oturum
│   │   ├── src/tenants/      firma bilgisi + panel özeti
│   │   ├── src/common/       guard, decorator, hata filtresi
│   │   └── test/             uçtan uca testler
│   ├── web/          Next.js 15 — pazarlama sayfaları + panel (port 3000)
│   │   ├── app/(site)/       ana sayfa, nasıl çalışır, tedarikçi, fiyatlandırma
│   │   ├── app/giris/        giriş & kayıt
│   │   ├── app/panel/        oturumlu panel
│   │   ├── app/api/auth/     tarayıcı ↔ API arası çerez köprüsü (BFF)
│   │   └── components/       başlık, altbilgi, formlar
│   └── worker/       BullMQ işçileri (Faz 3'te dolacak)
├── packages/
│   ├── db/           Prisma şeması, migration'lar, seed
│   └── shared/       ortak tipler, sabitler, şifre özetleme
└── docs/             bu dokümanlar
```

---

## 3. Sıfırdan çalıştırma

### 3.1 Gereksinimler
Node.js 22+, Docker (Postgres/Redis için), Git.

### 3.2 Adımlar

```bash
# 1) Bağımlılıklar (shared + Prisma client otomatik derlenir)
npm install

# 2) Ortam değişkenleri
cp .env.example .env
# JWT_SECRET, JWT_REFRESH_SECRET, ENCRYPTION_KEY üret:
#   openssl rand -hex 48

# 3) Altyapı: PostgreSQL + Redis + Mailpit
npm run infra:up

# 4) Veritabanı şeması ve başlangıç verisi
npm run db:migrate      # tabloları oluşturur
npm run db:seed         # paketler, kategoriler, demo hesaplar

# 5) Servisler (üç ayrı terminal)
npm run dev:api         # http://localhost:3001
npm run dev:web         # http://localhost:3000
npm run dev:worker      # kuyrukları dinler
```

### 3.3 Demo hesaplar (seed ile gelir)

| Rol | E-posta | Şifre |
|---|---|---|
| Satıcı | `satici@depar.test` | `Depar1234!` |
| Tedarikçi | `tedarikci@depar.test` | `Depar1234!` |

### 3.4 Doğrulama

```bash
curl localhost:3001/health
# {"status":"ok","db":"up",...}

npm run test -w @depar/api        # birim testler
npm run test:e2e -w @depar/api    # uçtan uca (Postgres ayakta olmalı)
```

Tarayıcıda: <http://localhost:3000> → **Ücretsiz başla** → kayıt → panel.

---

## 4. API uçları (Faz 1)

| Yöntem | Uç | Açıklama | Yetki |
|---|---|---|---|
| GET | `/health` | Servis + veritabanı durumu | açık |
| POST | `/v1/auth/register` | Satıcı/tedarikçi kaydı | açık (5 istek/dk) |
| POST | `/v1/auth/login` | Giriş | açık (5 istek/dk) |
| POST | `/v1/auth/refresh` | Access token yenileme (rotasyonlu) | açık |
| POST | `/v1/auth/logout` | Refresh token iptali | açık |
| GET | `/v1/auth/me` | Oturum bilgisi | Bearer |
| GET | `/v1/tenant` | Firma bilgisi + paket | Bearer |
| GET | `/v1/tenant/summary` | Panel özeti | Bearer |

### Örnek

```bash
curl -X POST localhost:3001/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"role":"seller","fullName":"Ad Soyad","companyName":"Firma Ltd",
       "email":"ornek@firma.com","password":"Depar1234!"}'
```

---

## 5. Faz 1'de verilen teknik kararlar

**Şifre özetleme: Node'un yerleşik `scrypt`'i.**
`argon2` native derleme ister (node-gyp), CI ve sunucu kurulumunda kırılgandır.
scrypt OWASP parametreleriyle (N=2¹⁵, r=8, p=1) güvenlidir ve sıfır bağımlılık gerektirir.
Format sürümlü (`scrypt$N$r$p$salt$hash`) olduğu için ileride argon2id'ye geçiş, giriş anında
`needsRehash` ile kesintisiz yapılır.

**Refresh token JWT değil.**
Rastgele üretilir, **sha256 özeti** saklanır, tek kullanımlıktır (rotasyon). Böylece çalınan
token tekrar kullanılamaz ve oturum sunucudan anında iptal edilebilir — JWT'de bu mümkün değil.

**Token'lar httpOnly çerezde.**
Tarayıcı tarafında `localStorage` kullanılmaz; XSS ile token çalınamaz. Next.js route handler'ları
(`app/api/auth/*`) tarayıcı ile API arasında ince bir köprü (BFF) görevi görür.

**Secure çerez bayrağı `APP_URL`'e bağlı.**
`https://` ile başlıyorsa açılır. `NODE_ENV`'e bağlamak, http'li yerel kurulumda çerezlerin hiç
saklanmamasına yol açıyordu.

**Kullanıcı sayımı sızdırmayan giriş.**
E-posta bulunamasa bile şifre doğrulaması sahte bir özet üzerinde çalıştırılır; yanıt süresinden
"bu e-posta kayıtlı mı" bilgisi çıkarılamaz.

**Tedarikçi `pending`, satıcı `active` başlar.**
Tedarikçi belge onayından geçer (Faz 2); satıcı hemen 14 günlük kartsız denemeye başlar.

**Pazarlama sayfaları taşınırken işaretleme korundu.**
Tasarım birebir aktarıldı; animasyon/akordiyon gibi davranışlar tek bir istemci bileşeninde
(`SiteInteractions`) toplandı. Durum taşıyan gerçek ekranlar (giriş, panel) normal React bileşenidir.

---

## 6. Bilerek ertelenenler

| Konu | Ne zaman | Not |
|---|---|---|
| PostgreSQL Row Level Security | Faz 2 | Şu an izolasyon uygulama katmanında; RLS ikinci savunma hattı olacak (`docs/05`) |
| E-posta doğrulama + şifre sıfırlama | Faz 2 | Mailpit yerelde hazır |
| 2FA (TOTP) | Faz 4 | Yönetici ve Kurumsal pakette zorunlu olacak |
| Kullanıcı davet / ekip yönetimi | Faz 2 | `max_users` limiti şemada hazır |
| Kuyruk işlerinin gövdesi | Faz 3 | Şu an iskelet; kuyruklar ayakta ve iş alıyor |
| Pazaryeri adaptörleri | Faz 3 | `docs/03` |

---

## 7. Sıradaki adım — Faz 2

1. Tedarikçi belge yükleme + admin onay ekranı
2. Excel/CSV şablonu ile toplu ürün yükleme (satır bazlı doğrulama raporu)
3. XML feed çekme işi (`supplier_feeds` tablosu hazır)
4. Kategori ağacı yönetimi + pazaryeri kategori eşleme ekranı
5. Görsel yükleme (S3 uyumlu depo + CDN)
6. Katalog listeleme/filtreleme ekranı (satıcı tarafı)
