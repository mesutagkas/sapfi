# 04 — Ödeme, Abonelik, Cari Hesap ve Fatura

---

## 1. Önce ilke: Depar mal bedeline dokunmaz

| Para | Kimden | Kime | Depar'ın rolü |
|---|---|---|---|
| Ürün bedeli | Alıcı | Pazaryeri → **Satıcı** | yok |
| Tedarikçi bedeli | Satıcı | **Tedarikçi** | kayıt tutar (cari), tahsil etmez |
| Abonelik | Satıcı | **Depar** | tahsil eder |

Depar araya girip mal bedelini toplarsa (pazar yeri/aracı ödeme modeli) 6493 sayılı kanun
kapsamında **ödeme kuruluşu lisansı** gerekir. MVP'de bu yola girme. İleride "Depar Cüzdan"
istenirse, lisanslı bir ödeme kuruluşu ile emanet (escrow) ortaklığı kurulur.

---

## 2. Abonelik altyapısı

### 2.1 Sağlayıcı seçimi

| Sağlayıcı | Artı | Eksi |
|---|---|---|
| **iyzico** | Hazır abonelik (subscription) ürünü, tekrarlayan tahsilat, kart saklama | Komisyon oranı |
| **PayTR** | Yaygın, hızlı onay, tekrarlayan ödeme desteği | Abonelik yönetimi daha çok sende |
| **Param / Sipay** | Alternatif oranlar | Entegrasyon dokümanı daha zayıf |

Öneri: **iyzico abonelik** ile başla, ikinci sağlayıcıyı yedek olarak bırak (tek sağlayıcıya
bağlı kalma, ödeme kesintisi tüm geliri durdurur).

### 2.2 Abonelik durum makinesi

```
kayıt ──► trialing (14 gün, kartsız)
            │
            ├─ kart girildi + tahsilat ok ──► active ──► (her dönem yenilenir)
            │                                   │
            │                                   ├─ tahsilat başarısız ──► past_due
            │                                   │        └─ 1., 3., 5., 7. gün yeniden dene
            │                                   │             └─ hâlâ yoksa ──► suspended (veri durur, erişim kilitlenir)
            │                                   └─ iptal ──► cancelled (dönem sonunda expired)
            └─ kart girilmedi ──► trial bitti ──► suspended
```

**Kilitlendiğinde ne olur?** İlanlar pazaryerinden silinmez; senkron durur, panel salt okunur olur.
Satıcının mağazasını bozmak en kötü müşteri deneyimi olurdu — 30 gün sonra veri arşive alınır.

### 2.3 Ödeme akışı (kart ekleme)

```
1. Satıcı kart bilgisini iyzico'nun barındırdığı forma girer  (kart verisi Depar sunucusuna HİÇ uğramaz → PCI kapsamı dışı kalırsın)
2. 3D Secure doğrulaması
3. iyzico kart token'ı döner → subscriptions.card_token alanına yazılır
4. Her dönem başında tahsilat, token ile otomatik yapılır
5. Sonuç webhook ile gelir → invoices güncellenir → e-fatura tetiklenir
```

### 2.4 Webhook dayanıklılığı

- Webhook uçları **imza doğrulamalı** olmalı (sağlayıcının imza başlığı).
- Aynı olay birden çok kez gelebilir → `provider_ref` ile **idempotent** işle.
- Webhook gelmezse diye günlük **mutabakat işi**: sağlayıcıdaki işlemleri çek, `invoices` ile karşılaştır.

### 2.5 Limit kontrolü

`usage_counters` tablosu aylık sayaç tutar. Kontrol noktaları:

| Limit | Nerede kontrol edilir | Aşınca |
|---|---|---|
| Aktif ürün | ürün aktarma anında | aktarım engellenir, yükseltme önerilir |
| Mağaza sayısı | mağaza ekleme anında | engellenir |
| Aylık sipariş | sipariş kaydında | **engellenmez** — sistem çalışmaya devam eder, her 100 sipariş için ₺79 ek fatura |
| Kullanıcı | davet anında | engellenir |
| Senkron sıklığı | worker planlayıcıda | paket aralığı uygulanır |

Sipariş limitini sert kesmemek bilinçli bir karar: satıcının satışını durdurmak, aboneliği iptal
ettirmenin en hızlı yoludur.

---

## 3. Satıcı ↔ tedarikçi cari hesabı

Her sipariş satırı, satıcının o tedarikçiye borcunu doğurur:

```sql
INSERT INTO ledger_entries (seller_id, supplier_id, order_id, type, amount, description)
VALUES ($1, $2, $3, 'debit', $4, 'Sipariş #10482 tedarikçi bedeli');
```

İade/iptalde `credit` satırı yazılır. Bakiye `ledger_balances` görünümünden okunur.

**Kredi limiti (`credit_limits`).** Yeni satıcının ödemeden sipariş yığması riskine karşı:
tedarikçi bazlı limit tanımlanır. Limit aşılırsa yeni siparişler tedarikçiye "ön onaylı" düşer ve
satıcıya ödeme hatırlatması gider. Tedarikçinin en büyük korkusu budur; bu özellik olmadan
tedarikçi kazanmak zordur.

**Mutabakat.** Haftalık olarak her satıcı–tedarikçi çifti için ekstre üretilir (PDF + e-posta).
Ödeme banka havalesiyle iki taraf arasında yapılır; satıcı dekontu panele yükler, tedarikçi onaylar,
`credit` satırı yazılır.

---

## 4. Faturalar — kim kime keser?

| Fatura | Kesen | Alan | Ne zaman |
|---|---|---|---|
| Abonelik faturası | Depar | Satıcı | Her tahsilatta, otomatik e-Arşiv/e-Fatura |
| Mal faturası | Tedarikçi | Satıcı | Sipariş/dönem bazlı |
| Satış faturası | Satıcı | Alıcı | Pazaryeri kuralına göre, kargo paketine girer |

**Kritik nokta:** Alıcıya giden paketin içindeki fatura **satıcının** faturasıdır; tedarikçinin
firma bilgisi pakette görünmez (nötr paketleme). Tedarikçi sözleşmesine bu madde mutlaka konur.
Uygulama: satıcı fatura şablonunu (logo, unvan) panele yükler, tedarikçi siparişle birlikte
bu şablonu indirir; ya da e-arşiv PDF'i Depar üretir ve tedarikçiye gönderir.

---

## 5. Uygulama kontrol listesi

- [ ] Kart verisi hiçbir zaman Depar sunucusuna gelmiyor (hosted form / token)
- [ ] 3D Secure zorunlu
- [ ] Webhook imza doğrulaması + idempotency
- [ ] Başarısız tahsilat için 4 kademeli yeniden deneme + e-posta/SMS
- [ ] Deneme süresi bitişinden 3 gün önce hatırlatma
- [ ] Paket yükseltmede orantılı (pro-rata) fark hesabı
- [ ] İptal tek tıkla, kalan gün iadesi kuralı yazılı
- [ ] Her fatura için e-Arşiv/e-Fatura otomatik oluşuyor, PDF panelde
- [ ] Günlük ödeme mutabakat işi çalışıyor
- [ ] Cari ekstre PDF'i haftalık gidiyor
- [ ] Kredi limiti aşımında uyarı akışı test edildi
