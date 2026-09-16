-- ============================================================
-- DEPAR — PostgreSQL 16 şeması
-- Çalıştırma:  psql "$DATABASE_URL" -f docs/schema.sql
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- ürün adı araması
CREATE EXTENSION IF NOT EXISTS "citext";     -- büyük-küçük harf duyarsız e-posta

-- ---------- ENUM tipleri ----------
CREATE TYPE user_role        AS ENUM ('seller','supplier','admin','support');
CREATE TYPE account_status   AS ENUM ('pending','active','suspended','closed');
CREATE TYPE marketplace      AS ENUM ('trendyol','hepsiburada','n11','ciceksepeti','pttavm','amazon_tr');
CREATE TYPE listing_status   AS ENUM ('draft','pushing','active','passive','rejected','error');
CREATE TYPE order_status     AS ENUM ('new','sent_to_supplier','preparing','shipped','delivered','cancelled','returned');
CREATE TYPE sub_status       AS ENUM ('trialing','active','past_due','cancelled','expired');
CREATE TYPE ledger_type      AS ENUM ('debit','credit');      -- satıcının tedarikçiye borcu / alacağı
CREATE TYPE source_type      AS ENUM ('manual','excel','xml','api','ecommerce_plugin');

-- ============================================================
-- 1. HESAPLAR
-- ============================================================

-- Her satıcı/tedarikçi firması bir tenant'tır. Tüm veriler tenant_id ile izole edilir.
CREATE TABLE tenants (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kind            user_role   NOT NULL CHECK (kind IN ('seller','supplier')),
  status          account_status NOT NULL DEFAULT 'pending',
  company_name    text        NOT NULL,
  tax_office      text,
  tax_number      text,
  mersis_no       text,
  iban            text,
  address         jsonb       NOT NULL DEFAULT '{}'::jsonb,
  phone           text,
  email           citext,
  -- tedarikçiye özel performans alanları
  avg_ship_days   numeric(4,2),
  cancel_rate     numeric(5,2),
  stock_accuracy  numeric(5,2),
  approved_at     timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON tenants (kind, status);

CREATE TABLE users (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid REFERENCES tenants(id) ON DELETE CASCADE,
  email         citext NOT NULL UNIQUE,
  password_hash text   NOT NULL,              -- argon2id
  full_name     text   NOT NULL,
  phone         text,
  role          user_role NOT NULL,
  is_owner      boolean NOT NULL DEFAULT false,
  two_fa_secret text,
  last_login_at timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON users (tenant_id);

CREATE TABLE tenant_documents (           -- vergi levhası, imza sirküleri vb.
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  doc_type   text NOT NULL,
  file_url   text NOT NULL,
  verified   boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 2. ABONELİK
-- ============================================================

CREATE TABLE plans (
  code                text PRIMARY KEY,          -- 'starter' | 'pro' | 'enterprise'
  name                text NOT NULL,
  monthly_price       numeric(10,2) NOT NULL,
  yearly_price        numeric(10,2) NOT NULL,
  max_products        integer,                   -- NULL = sınırsız
  max_channels        integer,
  max_orders_month    integer,
  max_users           integer,
  sync_interval_min   integer NOT NULL,          -- 240 / 15 / 5
  has_price_rules     boolean NOT NULL DEFAULT false,
  has_api             boolean NOT NULL DEFAULT false,
  is_active           boolean NOT NULL DEFAULT true
);

CREATE TABLE subscriptions (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  plan_code          text NOT NULL REFERENCES plans(code),
  status             sub_status NOT NULL DEFAULT 'trialing',
  billing_period     text NOT NULL DEFAULT 'monthly' CHECK (billing_period IN ('monthly','yearly')),
  trial_ends_at      timestamptz,
  current_start      timestamptz NOT NULL DEFAULT now(),
  current_end        timestamptz NOT NULL,
  cancel_at_period_end boolean NOT NULL DEFAULT false,
  provider           text,                       -- 'iyzico' | 'paytr'
  provider_ref       text,                       -- sağlayıcıdaki abonelik referansı
  card_token         text,                       -- sadece token, kart verisi ASLA tutulmaz
  created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON subscriptions (tenant_id, status);

CREATE TABLE invoices (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES tenants(id),
  subscription_id uuid REFERENCES subscriptions(id),
  amount        numeric(12,2) NOT NULL,
  vat_amount    numeric(12,2) NOT NULL DEFAULT 0,
  currency      char(3) NOT NULL DEFAULT 'TRY',
  status        text NOT NULL DEFAULT 'pending',   -- pending|paid|failed|refunded
  paid_at       timestamptz,
  provider_ref  text,
  einvoice_uuid text,                              -- e-Arşiv/e-Fatura numarası
  pdf_url       text,
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON invoices (tenant_id, created_at DESC);

CREATE TABLE usage_counters (             -- limit kontrolü için aylık sayaç
  tenant_id   uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  period      date NOT NULL,              -- ayın ilk günü
  orders      integer NOT NULL DEFAULT 0,
  api_calls   integer NOT NULL DEFAULT 0,
  pushes      integer NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, period)
);

-- ============================================================
-- 3. KATALOG (tedarikçi ürünleri)
-- ============================================================

CREATE TABLE categories (
  id          bigserial PRIMARY KEY,
  parent_id   bigint REFERENCES categories(id),
  name        text NOT NULL,
  path        text NOT NULL,              -- 'Elektronik > Ses > Kulaklık'
  vat_rate    numeric(4,2) NOT NULL DEFAULT 20
);

-- Depar kategorisi ↔ pazaryeri kategorisi eşlemesi (entegrasyonun kalbi)
CREATE TABLE category_mappings (
  id             bigserial PRIMARY KEY,
  category_id    bigint NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  channel        marketplace NOT NULL,
  remote_id      text NOT NULL,
  remote_path    text,
  required_attrs jsonb NOT NULL DEFAULT '[]'::jsonb,   -- pazaryerinin zorunlu öznitelikleri
  UNIQUE (category_id, channel)
);

CREATE TABLE products (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id   uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  category_id   bigint REFERENCES categories(id),
  sku           text NOT NULL,                       -- tedarikçinin kendi stok kodu
  title         text NOT NULL,
  description   text,
  brand         text,
  source        source_type NOT NULL DEFAULT 'manual',
  is_active     boolean NOT NULL DEFAULT true,
  attributes    jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (supplier_id, sku)
);
CREATE INDEX ON products (category_id) WHERE is_active;
CREATE INDEX products_title_trgm ON products USING gin (title gin_trgm_ops);

CREATE TABLE product_variants (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id    uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  variant_sku   text NOT NULL,
  barcode       text,                                 -- GTIN/EAN — pazaryerleri zorunlu tutar
  options       jsonb NOT NULL DEFAULT '{}'::jsonb,   -- {"renk":"Siyah","beden":"L"}
  supply_price  numeric(12,2) NOT NULL,               -- tedarikçi alış fiyatı (KDV hariç)
  vat_rate      numeric(4,2)  NOT NULL DEFAULT 20,
  msrp          numeric(12,2),                        -- tavsiye edilen satış fiyatı
  stock         integer NOT NULL DEFAULT 0,
  desi          numeric(6,2),
  ship_days     smallint NOT NULL DEFAULT 1,
  is_active     boolean NOT NULL DEFAULT true,
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (product_id, variant_sku)
);
CREATE INDEX ON product_variants (barcode);
CREATE INDEX ON product_variants (stock) WHERE is_active;

CREATE TABLE product_images (
  id         bigserial PRIMARY KEY,
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  url        text NOT NULL,
  position   smallint NOT NULL DEFAULT 0
);

-- Tedarikçinin otomatik veri kaynağı (XML/API)
CREATE TABLE supplier_feeds (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id   uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  kind          source_type NOT NULL,
  url           text,
  auth          jsonb,                       -- şifreli saklanır
  field_map     jsonb NOT NULL DEFAULT '{}'::jsonb,
  interval_min  integer NOT NULL DEFAULT 60,
  last_run_at   timestamptz,
  last_status   text,
  last_error    text
);

-- ============================================================
-- 4. PAZARYERİ BAĞLANTILARI VE İLANLAR
-- ============================================================

CREATE TABLE channel_accounts (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  channel        marketplace NOT NULL,
  store_name     text,
  merchant_id    text,                       -- supplierId / merchantId / satıcı no
  credentials    bytea NOT NULL,             -- AES-256-GCM ile şifreli JSON (bkz. 05)
  status         account_status NOT NULL DEFAULT 'pending',
  last_check_at  timestamptz,
  last_error     text,
  commission_overrides jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, channel, merchant_id)
);

-- Satıcının kataloğa eklediği ürün = ilan
CREATE TABLE listings (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id        uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  channel_account_id uuid NOT NULL REFERENCES channel_accounts(id) ON DELETE CASCADE,
  variant_id       uuid NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  remote_id        text,                     -- pazaryerindeki ürün/ilan kimliği
  remote_sku       text,                     -- satıcının pazaryerindeki stok kodu
  sale_price       numeric(12,2) NOT NULL,
  price_rule       jsonb,                    -- {"type":"margin","value":35,"min_profit":50}
  status           listing_status NOT NULL DEFAULT 'draft',
  last_synced_at   timestamptz,
  last_error       text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  UNIQUE (channel_account_id, variant_id)
);
CREATE INDEX ON listings (seller_id, status);
CREATE INDEX ON listings (variant_id);
CREATE INDEX ON listings (last_synced_at) WHERE status = 'active';

-- Pazaryerine gönderilen toplu işlerin takibi (Trendyol batchRequestId gibi)
CREATE TABLE channel_batches (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  channel_account_id uuid NOT NULL REFERENCES channel_accounts(id) ON DELETE CASCADE,
  batch_ref     text NOT NULL,
  kind          text NOT NULL,              -- 'create' | 'price_stock' | 'update'
  item_count    integer NOT NULL DEFAULT 0,
  status        text NOT NULL DEFAULT 'pending',
  result        jsonb,
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON channel_batches (status, created_at);

-- ============================================================
-- 5. SİPARİŞLER
-- ============================================================

CREATE TABLE orders (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id         uuid NOT NULL REFERENCES tenants(id),
  channel_account_id uuid NOT NULL REFERENCES channel_accounts(id),
  channel           marketplace NOT NULL,
  remote_order_id   text NOT NULL,
  order_number      text,
  status            order_status NOT NULL DEFAULT 'new',
  customer_name     text,
  customer_phone    text,                     -- KVKK: maskeli gösterilir, 90 gün sonra silinir
  shipping_address  jsonb NOT NULL,
  total_amount      numeric(12,2) NOT NULL,
  commission_amount numeric(12,2) NOT NULL DEFAULT 0,
  shipping_cost     numeric(12,2) NOT NULL DEFAULT 0,
  supply_total      numeric(12,2) NOT NULL DEFAULT 0,
  net_profit        numeric(12,2) GENERATED ALWAYS AS
                    (total_amount - commission_amount - shipping_cost - supply_total) STORED,
  ordered_at        timestamptz NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (channel_account_id, remote_order_id)
);
CREATE INDEX ON orders (seller_id, ordered_at DESC);
CREATE INDEX ON orders (status) WHERE status IN ('new','sent_to_supplier','preparing');

CREATE TABLE order_items (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id      uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  listing_id    uuid REFERENCES listings(id),
  variant_id    uuid REFERENCES product_variants(id),
  supplier_id   uuid NOT NULL REFERENCES tenants(id),
  title         text NOT NULL,
  quantity      integer NOT NULL,
  unit_price    numeric(12,2) NOT NULL,       -- alıcının ödediği
  supply_price  numeric(12,2) NOT NULL,       -- tedarikçiye ödenecek
  status        order_status NOT NULL DEFAULT 'new',
  supplier_note text
);
CREATE INDEX ON order_items (supplier_id, status);
CREATE INDEX ON order_items (order_id);

CREATE TABLE shipments (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id       uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  supplier_id    uuid NOT NULL REFERENCES tenants(id),
  carrier        text,                       -- 'yurtici' | 'aras' | 'mng' | 'ptt' ...
  tracking_no    text,
  label_url      text,
  shipped_at     timestamptz,
  delivered_at   timestamptz,
  pushed_to_channel boolean NOT NULL DEFAULT false
);
CREATE INDEX ON shipments (order_id);

CREATE TABLE returns (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id      uuid NOT NULL REFERENCES orders(id),
  order_item_id uuid REFERENCES order_items(id),
  supplier_id   uuid NOT NULL REFERENCES tenants(id),
  reason        text,
  status        text NOT NULL DEFAULT 'requested',  -- requested|approved|received|rejected|refunded
  refund_amount numeric(12,2),
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 6. CARİ HESAP (satıcı ↔ tedarikçi)
-- ============================================================

CREATE TABLE ledger_entries (
  id            bigserial PRIMARY KEY,
  seller_id     uuid NOT NULL REFERENCES tenants(id),
  supplier_id   uuid NOT NULL REFERENCES tenants(id),
  order_id      uuid REFERENCES orders(id),
  type          ledger_type NOT NULL,
  amount        numeric(12,2) NOT NULL CHECK (amount > 0),
  description   text,
  document_no   text,                    -- tedarikçi fatura no
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON ledger_entries (seller_id, supplier_id, created_at DESC);

-- Güncel bakiye görünümü: pozitif = satıcının tedarikçiye borcu
CREATE VIEW ledger_balances AS
SELECT seller_id, supplier_id,
       SUM(CASE WHEN type = 'debit' THEN amount ELSE -amount END) AS balance
FROM ledger_entries GROUP BY seller_id, supplier_id;

CREATE TABLE credit_limits (
  seller_id    uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  supplier_id  uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  limit_amount numeric(12,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (seller_id, supplier_id)
);

-- ============================================================
-- 7. BİLDİRİM, İŞ KAYITLARI, DENETİM
-- ============================================================

CREATE TABLE notifications (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id    uuid REFERENCES users(id) ON DELETE CASCADE,
  kind       text NOT NULL,            -- 'order.new' | 'stock.out' | 'payment.failed' ...
  title      text NOT NULL,
  body       text,
  link       text,
  channels   text[] NOT NULL DEFAULT '{inapp}',   -- inapp|email|sms|push|webhook
  read_at    timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON notifications (tenant_id, created_at DESC) WHERE read_at IS NULL;

CREATE TABLE sync_logs (
  id            bigserial PRIMARY KEY,
  tenant_id     uuid REFERENCES tenants(id) ON DELETE CASCADE,
  channel       marketplace,
  job           text NOT NULL,
  status        text NOT NULL,          -- success|partial|failed
  items_ok      integer NOT NULL DEFAULT 0,
  items_failed  integer NOT NULL DEFAULT 0,
  duration_ms   integer,
  error         text,
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON sync_logs (tenant_id, created_at DESC);

CREATE TABLE audit_logs (
  id         bigserial PRIMARY KEY,
  tenant_id  uuid,
  user_id    uuid,
  action     text NOT NULL,             -- 'listing.price.update' ...
  entity     text,
  entity_id  text,
  before     jsonb,
  after      jsonb,
  ip         inet,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON audit_logs (tenant_id, created_at DESC);

-- ---------- Başlangıç verisi ----------
INSERT INTO plans (code,name,monthly_price,yearly_price,max_products,max_channels,
                   max_orders_month,max_users,sync_interval_min,has_price_rules,has_api) VALUES
 ('starter','Başlangıç',   499.00,  4980.00,  250,   1,   500, 1, 240, false, false),
 ('pro','Profesyonel',    1499.00, 14988.00, 5000,   3,  5000, 3,  15, true,  false),
 ('enterprise','Kurumsal',4999.00, 49980.00, NULL, NULL, 50000,10,   5, true,  true);
