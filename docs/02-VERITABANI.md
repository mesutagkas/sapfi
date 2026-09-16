# 02 — Veritabanı

Çalıştırılabilir şema: [`schema.sql`](schema.sql) — **PostgreSQL 16 üzerinde test edildi**
(25 tablo + 1 görünüm + paket başlangıç verisi, hatasız kuruluyor).

```bash
createdb depar
psql "$DATABASE_URL" -f docs/schema.sql
```

---

## 1. Veri modeli haritası

```
tenants (satıcı VEYA tedarikçi firması)
  ├── users                 (firma çalışanları, rolleri)
  ├── tenant_documents      (vergi levhası, imza sirküleri)
  ├── subscriptions ──► plans        (yalnız satıcıda dolu)
  │     └── invoices, usage_counters
  ├── products ──► product_variants ──► product_images     (tedarikçi tarafı)
  │     └── supplier_feeds (XML/API kaynağı)
  ├── channel_accounts      (satıcının Trendyol/HB/N11 bağlantısı, şifreli anahtarlar)
  │     ├── listings        (katalog ürünü ↔ pazaryeri ilanı)
  │     ├── channel_batches (toplu işlem takibi)
  │     └── orders ──► order_items ──► shipments / returns
  └── ledger_entries + credit_limits  (satıcı ↔ tedarikçi cari)
notifications · sync_logs · audit_logs
```

---

## 2. Neden bu şekilde?

**Tek `tenants` tablosu, iki rol.** Satıcı ve tedarikçi aynı yapıda firmalar; `kind` alanı ayırıyor.
Böylece cari hesap, belge yönetimi ve kullanıcı yönetimi tek yerde. Bir firma ileride hem tedarikçi
hem satıcı olabilir — bu durumda iki tenant kaydı açılır, kullanıcı ikisine de bağlanabilir.

**`products` ≠ `listings`.** Katalogdaki ürün tedarikçiye aittir ve tektir. Aynı ürünü 50 satıcı
kendi mağazasına aktarabilir; her biri ayrı bir `listings` satırıdır (kendi fiyatı, kendi
`remote_id`'si, kendi durumu). Stok tek kaynaktan (`product_variants.stock`) gelir.

**Varyant seviyesinde stok.** Pazaryerleri barkod (GTIN) üzerinden çalışır; stok ve fiyat varyantın
özelliğidir, ürünün değil.

**`orders.net_profit` üretilmiş (generated) sütun.** Kâr = satış − komisyon − kargo − tedarikçi bedeli.
Uygulamada hesaplamak yerine veritabanında tutulur; rapor sorguları basitleşir ve tutarsızlık olmaz.

**Cari hesap = değiştirilemez defter.** Bakiyeyi bir sütunda güncellemek yerine `ledger_entries`'e
borç/alacak satırı yazılır; bakiye `ledger_balances` görünümünden okunur. Mali kayıtta izlenebilirlik
şarttır, satır asla güncellenmez/silinmez.

**Şifreli `channel_accounts.credentials`.** Pazaryeri API anahtarları `bytea` olarak AES-256-GCM ile
şifreli durur (bkz. `05-GUVENLIK-KVKK.md`). Veritabanı dökümü sızsa bile anahtarlar okunamaz.

**`category_mappings` entegrasyonun kalbi.** Her pazaryerinin kendi kategori ağacı ve zorunlu
öznitelikleri var. Bu eşleme tablosu olmadan ürün aktarımı çalışmaz; projenin en çok elle veri
girişi isteyen kısmıdır, erken başla.

---

## 3. Çok kiracılılık (multi-tenancy)

Tek veritabanı, `tenant_id` sütunuyla ayrım. Uygulamada **her sorgu** tenant filtresiyle çalışmalı.
Ek güvenlik katmanı olarak PostgreSQL Row Level Security önerilir:

```sql
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON orders
  USING (seller_id = current_setting('app.tenant_id')::uuid);
-- her istek başında:  SET LOCAL app.tenant_id = '...';
```

Bir ORM hatası yüzünden bir satıcının başka satıcının siparişlerini görmesi, bu projede
kapatılamayacak bir itibar kaybıdır. RLS bu riski veritabanı seviyesinde kapatır.

---

## 4. Performans notları

| Konu | Karar |
|---|---|
| En sık sorgu | "şu satıcının aktif ilanları, senkron zamanı geçmiş olanlar" → `listings (last_synced_at) WHERE status='active'` kısmi indeksi |
| Katalog araması | `pg_trgm` GIN indeksi; 500 bin ürünü aşınca Meilisearch |
| Sipariş büyümesi | `orders` ve `sync_logs` aylık bölümleme (partition) için hazırdır; 5 milyon satırı geçince uygula |
| Stok güncelleme | Toplu `UPDATE ... FROM (VALUES ...)` ile; satır satır güncelleme worker'ı boğar |
| Silme | Tenant silinince ürün/ilan cascade; **sipariş ve cari kayıtları asla silinmez** (10 yıl saklama yükümlülüğü) |
| Arşiv | 90 günden eski `sync_logs` ve `audit_logs` soğuk depoya taşınır |

---

## 5. Migration disiplini

- Şema değişiklikleri **Prisma Migrate** (veya Flyway) ile sürümlenir; elle `ALTER TABLE` yasak.
- Üretimde `prisma migrate deploy` CI adımında çalışır.
- Geriye dönük uyumsuz değişiklik iki aşamada yapılır: önce yeni sütun eklenir ve çift yazım
  yapılır, sonraki sürümde eski sütun düşürülür. Senkron worker'ları deploy sırasında durmaz.
- Her migration öncesi otomatik yedek alınır.
