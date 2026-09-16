# 01 — Mimari, Sunucular ve Kurulum

---

## 1. Teknoloji seçimi (ve neden)

| Katman | Seçim | Neden |
|---|---|---|
| API | **Node.js 22 + NestJS (TypeScript)** | Entegrasyon ağırlıklı, I/O yoğun bir iş; NestJS modüler yapısı çok entegrasyonlu projede dağılmayı önler |
| Web | **Next.js 15 (App Router)** | SEO gerektiren pazarlama sayfaları + panel aynı çatıda |
| Kuyruk | **BullMQ + Redis** | Senkron/sipariş işleri kuyruğa girmeli; tekrar deneme ve hız sınırı yönetimi hazır gelir |
| Veritabanı | **PostgreSQL 16** | İlişkisel veri (sipariş, cari, stok) + JSONB ile pazaryerine özel alanlar |
| Önbellek | **Redis 7** | Oturum, rate limit sayaçları, kısa ömürlü kilitler |
| Dosya | **S3 uyumlu obje deposu + CDN** | Ürün görselleri; sunucu diskinde tutma |
| Arama | Faz 1'de Postgres `tsvector`, katalog 500 bin ürünü geçince **Meilisearch/OpenSearch** | Erken optimizasyon yapma |
| Altyapı | **Docker Compose** (başlangıç) → yük artınca Kubernetes | 100 satıcıya kadar Compose fazlasıyla yeter |

> Ekibin PHP/Laravel veya Python/Django'da güçlüyse o da çalışır. Değişmeyecek olan şu:
> **kuyruk + worker mimarisi**. Pazaryeri çağrılarını HTTP isteği içinde senkron yapmak
> ilk 50 satıcıda sistemi kilitler.

---

## 2. Servis şeması

```
                   ┌───────────────┐
  Kullanıcı  ───►  │  Cloudflare   │  (DNS, WAF, CDN, bot koruması)
                   └──────┬────────┘
                          │
                   ┌──────▼────────┐
                   │  Nginx / Caddy│  (TLS sonlandırma, reverse proxy)
                   └──┬─────────┬──┘
            ┌─────────▼──┐   ┌──▼─────────┐
            │  web       │   │  api       │   (Next.js / NestJS)
            └────────────┘   └──┬─────────┘
                                │ enqueue
                        ┌───────▼────────┐
                        │  Redis (BullMQ)│
                        └───────┬────────┘
             ┌──────────────────┼──────────────────┐
     ┌───────▼──────┐  ┌────────▼────────┐  ┌──────▼────────┐
     │ worker:sync  │  │ worker:orders   │  │ worker:notify │
     │ stok/fiyat   │  │ sipariş çek/it  │  │ mail/sms/push │
     └───────┬──────┘  └────────┬────────┘  └──────┬────────┘
             └────────────┬─────┴──────────────────┘
                   ┌──────▼──────┐     ┌─────────────┐
                   │ PostgreSQL  │     │ S3 + CDN    │
                   └─────────────┘     └─────────────┘
```

**Kuyruk isimleri (öneri):**

| Kuyruk | İş | Sıklık |
|---|---|---|
| `product.push` | Ürünü pazaryerine ilan olarak aç | olay bazlı |
| `stock.sync` | Tedarikçi stok/fiyat → Depar → pazaryeri | pakete göre 5 dk / 15 dk / 4 sa |
| `order.pull` | Pazaryerinden yeni sipariş çek | 2–5 dk |
| `order.dispatch` | Siparişi tedarikçiye ata + bildir | olay bazlı |
| `shipment.push` | Kargo numarasını pazaryerine yaz | olay bazlı |
| `batch.check` | Pazaryeri toplu işlem sonucu sorgula | 1 dk |
| `invoice.issue` | e-Fatura/e-Arşiv oluştur | olay bazlı |
| `notify.send` | E-posta / SMS / push / webhook | olay bazlı |

Her kuyruk için: **üstel geri çekilme (backoff)**, en fazla 5 deneme, sonrasında `dead-letter`
tablosuna düşür ve admin panelinde göster. Aynı ürün için eşzamanlı iki senkron çalışmasın —
Redis'te `lock:product:{id}` kilidi kullan.

---

## 3. Sunucu kurulumu — adım adım

### 3.1 Sunucuları aç

Başlangıç için 3 makine yeterli (Hetzner CPX31 sınıfı, Almanya/Finlandiya):

| Makine | Rol | Boyut |
|---|---|---|
| `depar-app-1` | nginx + api + web | 4 vCPU / 8 GB / 80 GB |
| `depar-worker-1` | worker süreçleri | 4 vCPU / 8 GB |
| `depar-db-1` | PostgreSQL + Redis (ya da yönetilen servis) | 4 vCPU / 16 GB / 160 GB SSD |

> Mümkünse veritabanını **yönetilen servis** olarak al (Hetzner yönetilen PG yok; DigitalOcean,
> Neon, Supabase veya AWS RDS). Yedek, yük devretme ve nokta-zaman kurtarma (PITR) hazır gelir.

### 3.2 Temel güvenlik (her sunucuda)

```bash
# 1) Kullanıcı ve SSH
adduser depar && usermod -aG sudo depar
# yerel makinende: ssh-copy-id depar@SUNUCU_IP
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/;s/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# 2) Güvenlik duvarı
sudo ufw default deny incoming && sudo ufw default allow outgoing
sudo ufw allow OpenSSH && sudo ufw allow 80,443/tcp && sudo ufw enable

# 3) Otomatik güvenlik yamaları + brute force koruması
sudo apt update && sudo apt install -y unattended-upgrades fail2ban
sudo systemctl enable --now fail2ban

# 4) Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker depar
```

> Veritabanı sunucusunun 5432 portunu **internete açma**. Sadece özel ağ (private network)
> üzerinden app/worker IP'lerine izin ver.

### 3.3 Domain, DNS ve SSL

1. Alan adının nameserver'larını Cloudflare'e yönlendir.
2. Kayıtlar:
   | Ad | Tip | Değer |
   |---|---|---|
   | `@` , `www` | A | app sunucusunun IP'si |
   | `api` | A | app sunucusunun IP'si |
   | `cdn` | CNAME | obje deposu/CDN adresi |
   | `@` | MX / TXT | e-posta sağlayıcısı + **SPF, DKIM, DMARC** (bildirim e-postalarının spam'e düşmemesi için zorunlu) |
3. TLS: Caddy kullanırsan sertifika otomatik; nginx kullanacaksan `certbot --nginx` ile Let's Encrypt.
4. Cloudflare'de: "Full (strict)" SSL, HSTS açık, `/api/*` için rate limit kuralı.

### 3.4 Ortam değişkenleri (`.env` — asla repoya girmez)

```bash
NODE_ENV=production
APP_URL=https://depar.com.tr
API_URL=https://api.depar.com.tr

DATABASE_URL=postgresql://depar:PAROLA@10.0.0.3:5432/depar?sslmode=require
REDIS_URL=redis://:PAROLA@10.0.0.3:6379

JWT_SECRET=...              # openssl rand -hex 48
JWT_REFRESH_SECRET=...
ENCRYPTION_KEY=...          # 32 bayt, pazaryeri anahtarlarını şifrelemek için (bkz. 05)

S3_ENDPOINT=...
S3_BUCKET=depar-media
S3_ACCESS_KEY=...
S3_SECRET_KEY=...

# Pazaryerleri satıcı bazında DB'de şifreli tutulur; buradakiler yalnızca Depar'ın kendi test hesabı
TRENDYOL_TEST_SUPPLIER_ID=...
TRENDYOL_TEST_API_KEY=...
TRENDYOL_TEST_API_SECRET=...

IYZICO_API_KEY=...
IYZICO_SECRET=...
IYZICO_BASE_URL=https://api.iyzipay.com

MAIL_PROVIDER_KEY=...
SMS_PROVIDER_KEY=...
SENTRY_DSN=...
```

Sır yönetimi: küçük ekipte **Doppler / 1Password Secrets**, bulutta **AWS Secrets Manager**.
`.env` dosyasını sunucuda `chmod 600` yap.

### 3.5 docker-compose (üretim iskeleti)

```yaml
services:
  api:
    image: ghcr.io/ORG/depar-api:${TAG}
    env_file: .env
    restart: always
    depends_on: [redis]
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3000/health"]
      interval: 30s

  web:
    image: ghcr.io/ORG/depar-web:${TAG}
    env_file: .env
    restart: always

  worker-sync:
    image: ghcr.io/ORG/depar-api:${TAG}
    command: ["node", "dist/worker.js", "--queues=stock.sync,product.push"]
    env_file: .env
    restart: always
    deploy: { replicas: 2 }

  worker-orders:
    image: ghcr.io/ORG/depar-api:${TAG}
    command: ["node", "dist/worker.js", "--queues=order.pull,order.dispatch,shipment.push"]
    env_file: .env
    restart: always

  redis:
    image: redis:7-alpine
    command: ["redis-server", "--requirepass", "${REDIS_PASSWORD}", "--appendonly", "yes"]
    volumes: [redis-data:/data]
    restart: always

  caddy:
    image: caddy:2-alpine
    ports: ["80:80", "443:443"]
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
    restart: always

volumes: { redis-data: {}, caddy-data: {} }
```

`Caddyfile`:

```
depar.com.tr, www.depar.com.tr {
  encode gzip zstd
  reverse_proxy web:3000
}
api.depar.com.tr {
  encode gzip
  reverse_proxy api:3000
}
```

### 3.6 CI/CD (GitHub Actions)

```yaml
name: deploy
on:
  push: { branches: [main] }
jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: npm }
      - run: npm ci && npm run lint && npm run test && npm run build
      - uses: docker/build-push-action@v6
        with: { push: true, tags: "ghcr.io/ORG/depar-api:${{ github.sha }}" }
      - name: Sunucuda güncelle
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: depar
          key: ${{ secrets.DEPLOY_KEY }}
          script: |
            cd /srv/depar
            export TAG=${{ github.sha }}
            docker compose pull && docker compose up -d
            docker compose exec -T api npx prisma migrate deploy
```

Kural: **`main`'e giden her şey önce `staging`'e gider.** Pazaryeri entegrasyonunda hatalı bir
deploy, gerçek satıcıların ilanlarını bozabilir.

---

## 4. İzleme, günlük ve yedekleme

| Konu | Araç | Ayar |
|---|---|---|
| Hata takibi | Sentry | API + web + worker; sürüm etiketiyle |
| Metrik | Prometheus + Grafana (veya Better Stack) | Kuyruk uzunluğu, iş süresi, hata oranı, pazaryeri yanıt süresi |
| Log | Docker → Loki / Better Stack | JSON log, `request_id` ile uçtan uca izleme |
| Uptime | UptimeRobot / Better Stack | `/health` her 1 dk |
| Yedek | `pg_dump` günlük + PITR | **Ayda bir geri yükleme tatbikatı yap** — test edilmemiş yedek yedek değildir |

Kritik alarmlar (Slack/WhatsApp'a düşsün):
- `order.pull` kuyruğu 15 dakikadır boşalmıyor
- Bir pazaryerinden art arda 5 kez 401/403 (satıcı anahtarı bozulmuş olabilir)
- Stok senkronu bir satıcı için 2 döngüdür başarısız
- Ödeme sağlayıcısı webhook'u 10 dakikadır gelmiyor

---

## 5. Ölçekleme sırası (erken yapma, sırası gelince yap)

1. Worker sayısını artır (en ucuz ve en etkili adım).
2. Postgres'e okuma kopyası ekle; raporlar kopyadan okusun.
3. Katalog aramasını Meilisearch'e taşı.
4. Görselleri tamamen CDN'e taşı, sunucudan hiç geçirme.
5. Sipariş ve senkron kayıtlarını aylık bölümle (partition).
6. Trafik gerçekten büyüdüyse Kubernetes'e geç.
