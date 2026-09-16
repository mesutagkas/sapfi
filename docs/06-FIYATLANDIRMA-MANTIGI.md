# 06 — Abonelik Fiyatları Neye Göre Belirlendi?

| Paket | Aylık | Yıllık (aylık karşılığı) | Kime |
|---|---|---|---|
| **Başlangıç** | ₺499 | ₺415 | İlk satışını yapacak, tek kanal, düşük hacim |
| **Profesyonel** | ₺1.499 | ₺1.249 | Ayda 500–5.000 sipariş, 2–3 kanal |
| **Kurumsal** | ₺4.999 | ₺4.165 | Çok kanal, yüksek hacim, API/ERP ihtiyacı |

Tedarikçi üyeliği **ücretsiz**, satıştan **komisyon yok**.
Yıllık ödemede 12 ay yerine 10 ay ücreti alınır (≈ %17 indirim).

---

## 1. Fiyat neyin üzerine kuruldu?

Fiyatı üç eksen belirler — üçü de doğrudan Depar'ın maliyetini büyüten kalemlerdir:

| Eksen | Neden maliyet? |
|---|---|
| **Aktif ürün sayısı** | Her ürün, her senkron turunda okunup karşılaştırılır. 5.000 ürün × günde 96 tur = günde yarım milyon kontrol |
| **Senkron sıklığı** | 4 saat → 15 dakika geçişi worker yükünü 16 katına çıkarır |
| **Mağaza (kanal) sayısı** | Her kanal ayrı API kotası, ayrı eşleme, ayrı hata yönetimi |
| **Sipariş adedi** | Her sipariş: çekme + bildirim + cari kaydı + kargo yazma + fatura |

Bu yüzden paketler "özellik kısıtlama" üzerine değil, **tüketilen kaynak** üzerine kuruldu.
Satıcı ne kadar büyürse o kadar öder; küçük satıcı büyük satıcının maliyetini sübvanse etmez.

---

## 2. Birim maliyet hesabı

100 aktif satıcıda altyapı gideri ≈ **150–250 €/ay** (bkz. `00-YOL-HARITASI.md`).
Buna değişken kalemleri ekle:

| Kalem | Satıcı başına aylık |
|---|---|
| Sunucu + veritabanı + Redis payı | ~1,5–2,5 € |
| E-posta / SMS / push | ~0,3–1 € |
| Ödeme sağlayıcı komisyonu (abonelik tutarının ~%2,5'i) | Başlangıç ₺12 · Profesyonel ₺37 · Kurumsal ₺125 |
| Destek (ortalama dağıtılmış insan maliyeti) | Başlangıç ~₺40 · Profesyonel ~₺120 · Kurumsal ~₺600 |

Kaba brüt marj:

| Paket | Gelir | Doğrudan maliyet (yaklaşık) | Brüt marj |
|---|---|---|---|
| Başlangıç | ₺499 | ~₺150 | **~%70** |
| Profesyonel | ₺1.499 | ~₺330 | **~%78** |
| Kurumsal | ₺4.999 | ~₺1.400 | **~%72** |

SaaS'ta sağlıklı brüt marj %70–80 aralığıdır; paketler bu bandı tutacak şekilde konumlandı.

> Kur ve sağlayıcı fiyatları değişkendir. Tabloları yılda iki kez gözden geçir; €/₺ değişimi
> doğrudan Başlangıç paketinin marjını aşındırır (en ince marjlı paket odur).

---

## 3. Değer testi: satıcı için mantıklı mı?

Profesyonel paket satıcısı, ortalama ₺700 sepet ve %25 net kâr ile ayda 300 sipariş yapıyorsa:

```
Aylık net kâr  = 300 × 700 × 0,25 ≈ ₺52.500
Depar bedeli   = ₺1.499
Kâra oranı     ≈ %2,9
```

Karşılığında: stok yatırımı yok, depo yok, kargo operasyonu yok.
**Abonelik, satıcının kârının %5'ini geçmemelidir** — geçtiği noktada satıcı kendi entegrasyonunu
yazmayı veya rakibe geçmeyi düşünmeye başlar. Paket üst limitleri bu orana göre seçildi.

Kıyas: Türkiye'de pazaryeri entegrasyon yazılımları ₺500–₺3.000/ay bandında, üstelik **çoğu
ciro üzerinden komisyon da alır**. Depar'ın "%0 komisyon" duruşu, büyüyen satıcı için en güçlü
tutundurma argümanıdır ve pazarlama mesajının merkezine bu yüzden konuldu.

---

## 4. Limit aşımı ve ek ücretler

| Kalem | Ücret | Gerekçe |
|---|---|---|
| Her +100 sipariş | ₺79 | Sert kesme yerine esneme: satışı durdurmak müşteriyi kaybettirir |
| Ek kullanıcı | ₺149/ay | Marjinal maliyeti düşük, yükseltmeye köprü |
| Ek pazaryeri mağazası | ₺299/ay | Her kanal gerçek maliyet üretir |

Üst üste 2 ay limit aşan satıcıya panelde otomatik yükseltme önerisi çıkar — bu, en verimli
gelir artırma kanalıdır.

---

## 5. Deneme ve iptal politikası

- **14 gün, kart istemeden.** Kart isteyen deneme, dönüşümü artırır ama ilk temasta güven kaybettirir;
  Depar'ın konumlandırması "risksiz başla" olduğu için kartsız seçildi.
- Denemede Profesyonel özellikleri açık — satıcının değeri görmesi için.
- İptal tek tıkla; taahhüt yok. Kalan gün iadesi yapılır.
- Kilitlenen hesabın ilanları pazaryerinden **silinmez**; yalnız senkron durur.

---

## 6. Zam ve gözden geçirme

- Fiyatlar yılda bir gözden geçirilir; artış en az 30 gün önce e-posta ile duyurulur.
- Mevcut müşteriye ilk yıl **fiyat kilidi** (grandfathering) uygulanır — erken müşteriyi ödüllendirir.
- Yıllık ödeyenlere dönem sonuna kadar eski fiyat geçerlidir.

---

## 7. İzlenecek metrikler

| Metrik | Hedef |
|---|---|
| Deneme → ücretli dönüşüm | > %25 |
| Aylık iptal (churn) | < %4 |
| Ortalama gelir / satıcı (ARPA) | Artan |
| Başlangıç → Profesyonel yükseltme oranı | > %20 / yıl |
| LTV / CAC | > 3 |
| Satıcı başına aktif ürün | Maliyet erken uyarı göstergesi |
