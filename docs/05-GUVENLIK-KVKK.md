# 05 — Güvenlik, KVKK ve Hukuki Çerçeve

> Bu doküman teknik önlemleri ve hukuki başlıkları listeler. Sözleşme metinlerini
> **mutlaka bir avukata** hazırlat; buradaki maddeler brifing niteliğindedir.

---

## 1. En kritik varlık: satıcının pazaryeri API anahtarları

Bu anahtarlarla bir saldırgan satıcının mağazasını yönetebilir — fiyat değiştirebilir, ilan
kapatabilir, sipariş bilgisi okuyabilir. Sızması, projenin sonu olur.

**Şifreleme (zarf yöntemi):**

```ts
// Anahtar KMS/Secrets Manager'da tutulur, kodda ve .env'de ham hâliyle bulunmaz.
import { createCipheriv, createDecipheriv, randomBytes } from "crypto";

export function encrypt(plain: string, key: Buffer) {
  const iv = randomBytes(12);
  const c = createCipheriv("aes-256-gcm", key, iv);
  const enc = Buffer.concat([c.update(plain, "utf8"), c.final()]);
  return Buffer.concat([iv, c.getAuthTag(), enc]);   // channel_accounts.credentials (bytea)
}

export function decrypt(buf: Buffer, key: Buffer) {
  const iv = buf.subarray(0, 12), tag = buf.subarray(12, 28), data = buf.subarray(28);
  const d = createDecipheriv("aes-256-gcm", key, iv);
  d.setAuthTag(tag);
  return Buffer.concat([d.update(data), d.final()]).toString("utf8");
}
```

Kurallar:
- Anahtar yalnızca **çağrı anında** çözülür, bellekte tutulmaz, log'a yazılmaz.
- Panelde asla tam gösterilmez: `TY-****-4821`.
- Anahtar rotasyonu desteklenir (`key_version` alanı ile çift anahtar dönemi).
- Anahtarı çözen servis sayısı minimumda (yalnız worker ve entegrasyon servisi).
- Hata mesajlarında istek gövdesi maskelenerek loglanır.

---

## 2. Uygulama güvenliği kontrol listesi

| Konu | Uygulama |
|---|---|
| Şifreler | argon2id (bcrypt değil), minimum 8 karakter + sızmış parola kontrolü |
| Oturum | JWT access 15 dk + refresh 30 gün, refresh rotasyonu ve iptal listesi |
| 2FA | Yönetici ve kurumsal pakette TOTP zorunlu |
| Yetki | Rol + kaynak sahipliği kontrolü; **her sorguda `tenant_id`**, ayrıca PostgreSQL RLS |
| Rate limit | IP + kullanıcı bazlı; giriş denemesi 5/dk, API 60/dk |
| Girdi doğrulama | Tüm uçlarda şema doğrulaması (zod/class-validator) |
| Dosya yükleme | Tip ve boyut kontrolü, görselleri yeniden işle (EXIF temizle), ayrı alan adından servis et |
| SQL | Yalnız parametreli sorgu / ORM; dinamik SQL yasak |
| Bağımlılık | `npm audit` + Dependabot CI'da |
| Sırlar | Repoda sır yok; `gitleaks` pre-commit |
| Denetim izi | Fiyat değişikliği, anahtar güncelleme, rol değişikliği `audit_logs`'a |
| Yedek | Günlük + PITR, şifreli, ayda bir geri yükleme tatbikatı |
| Admin paneli | Ayrı alt alan adı, IP kısıtı, 2FA zorunlu, "kullanıcı adına giriş" özelliği loglanır |

---

## 3. KVKK

**Veri sorumlusu:** Depar (kendi kullanıcı verisi için). Satıcının alıcı verisini işlerken Depar
**veri işleyen** konumundadır — satıcı ile aranızda yazılı bir *veri işleme sözleşmesi* olmalı.

| Yükümlülük | Yapılacak |
|---|---|
| VERBİS kaydı | Şirket eşiği aşıyorsa kayıt zorunlu |
| Aydınlatma metni | Kayıt ekranında, ayrı onay kutusu ile |
| Açık rıza | Pazarlama e-postaları için ayrı rıza (ticari elektronik ileti → **İYS** kaydı) |
| Veri minimizasyonu | Alıcının adı/adresi yalnız kargo için; telefon maskeli gösterilir |
| Saklama süreleri | Alıcı iletişim verisi teslimden 90 gün sonra maskelenir; mali kayıtlar 10 yıl saklanır |
| Silme hakkı | Hesap kapatma akışı: kişisel veri silinir, mali kayıt anonimleştirilerek korunur |
| Yurt dışı aktarım | Sunucu AB'de ise açık rıza/uygun teminat gerekir. **En temizi: veriyi Türkiye'de tutmak.** Hetzner/AWS Frankfurt seçeceksen hukuki görüş al |
| İhlal bildirimi | 72 saat içinde Kurul'a bildirim prosedürü yazılı olsun |
| Alt işleyenler | Kullandığın tüm sağlayıcılar (e-posta, SMS, izleme) listelenip sözleşmede belirtilir |

---

## 4. Gerekli sözleşme ve metinler

1. **Satıcı Abonelik Sözleşmesi** — paket, limit, ücret, iptal, sorumluluk sınırı.
2. **Tedarikçi Sözleşmesi** — stok doğruluğu, kargo süresi, nötr paketleme, iade, ceza şartları.
3. **Platform Kullanım Koşulları** ve **Gizlilik Politikası**.
4. **Mesafeli Satış / Ön Bilgilendirme** (abonelik satışı için).
5. **Çerez Politikası** + çerez onayı bileşeni.
6. **Veri İşleme Sözleşmesi** (satıcı ile, alıcı verisi için).
7. **İYS** (İleti Yönetim Sistemi) kaydı — pazarlama iletisi göndereceksen zorunlu.

---

## 5. Ticari riskler ve önlemleri

| Risk | Önlem |
|---|---|
| Tedarikçi stoğu yanlış bildirir → satıcı ceza yer | Stok doğruluk puanı, üst üste hatada otomatik askıya alma, ilan kapatma otomasyonu |
| Satıcı tedarikçiye ödemez | Kredi limiti, teminat, gecikmede otomatik durdurma |
| Pazaryeri API'sini değiştirir | Adaptör deseni, sürüm izleme, entegrasyon testleri, "bozuldu" alarmı |
| Tedarikçi satıcının müşterisine kendi reklamını koyar | Sözleşmede nötr paket maddesi + ihlalde askıya alma |
| Aynı ürünü 50 satıcı satıyor → fiyat savaşı | Minimum satış fiyatı (MAP) tanımı, kâr eşiği koruması |
| Sahte/taklit ürün | Tedarikçi onay süreci, marka belgesi kontrolü, şikâyet mekanizması |
