# 07 — Marka Kılavuzu

## 1. İsim: **Depar**

Türkçede "depar atmak" = aniden hızlanmak, öne fırlamak.

- Tek kelime, iki hece, 5 harf — akılda kalır, telefonda yazdırması kolay.
- Türkçe kökenli ama yabancı dilde de rahat okunur.
- "Tedarik" ve "depo" çağrışımı taşır, ama ikisine de hapsolmaz.
- Doğrudan vaadi anlatır: satıcı için **hız**.

**Kullanım:** Logoda ve arayüzde küçük harfle `depar`. Metin içinde büyük harfle **Depar**.
Resmî unvan: *Depar Teknoloji A.Ş.*

**Kontrol edilecekler (Faz 0):** `depar.com.tr` / `depar.app` alan adları, TÜRKPATENT'te 9. ve 42.
sınıf marka tescili, `@depar` sosyal medya kullanıcı adları.

---

## 2. Slogan ve mesaj

**Ana slogan:** *Stok tutma. Kargolama. Sadece sat.*

| Kitle | Mesaj |
|---|---|
| Satıcı | "Sermaye bağlamadan sat." · "Sen uyurken çalışır." · "%0 komisyon." |
| Tedarikçi | "Bir yükle, yüzlerce vitrin." · "Satış gücünü kirala." |

**Dil tonu:** Kısa cümle, ikinci tekil şahıs ("sen"), abartısız. Sayı ve somut fayda kullan;
"dijital dönüşüm", "inovatif çözüm" gibi boş kalıplardan kaçın. Bir ekranda 3 cümleden fazla
açıklama varsa, onu bir görsele dönüştür.

---

## 3. Logo

`assets/img/logo.svg` (yatay) · `assets/img/logo-mark.svg` (işaret) · `assets/img/favicon.svg`

Kurgu: soldan sağa üç **hız çizgisi** + öne fırlayan **ok/paket** üçgeni. Ürünün tedarikçiden
satıcının vitrinine akışını ve hızı birlikte anlatır. Kare, yuvarlatılmış köşeli (13/48 yarıçap)
bir konteyner içinde gradyan zemin.

**Kurallar**
- Minimum işaret boyu: 24 px. Altında hız çizgileri okunmaz, sade varyantı (favicon) kullan.
- Koruma alanı: her yönde işaret yüksekliğinin %25'i kadar boşluk.
- Koyu zeminde logo beyaz yazıyla (`logo--light` sınıfı), açık zeminde lacivert yazıyla.
- Yapma: gradyanı değiştirme, işareti eğme/döndürme, gölge ekleme, kelimeyi büyük harfle yazma.

---

## 4. Renkler

| Rol | İsim | Kod | Kullanım |
|---|---|---|---|
| Ana | Depar Lacivert | `#0A1733` | Başlık, koyu bölümler, footer, güven |
| Aksiyon | Kobalt | `#2F6BFF` | Butonlar, bağlantılar, aktif durum |
| Kazanç | Nane | `#0FBF95` | Kâr, başarı, "yayında" durumu |
| Uyarı | Amber | `#FFB020` | Bekleyen işlem, dikkat |
| Hata | Mercan | `#EF4E3A` | Hata, stok bitti, iade |
| Metin | Mürekkep | `#0C1A33` / ikincil `#5D6D89` | Gövde metni |
| Zemin | Beyaz / Bulut | `#FFFFFF` / `#F6F8FD` | Sayfa ve bölüm zeminleri |
| Çizgi | `#E2E9F4` | Kart kenarı, ayraç |

Renk mantığı: **lacivert güven verir** (finansal veri taşıyan bir panel için şart),
**kobalt harekete geçirir**, **nane parayı temsil eder**. Üçü birlikte kullanılır; gradyan
(`#2F6BFF → #0FBF95`) yalnızca logo, avatar ve vurgu metninde.

Erişilebilirlik: gövde metni en az 4.5:1 kontrast; nane rengi beyaz zeminde metin olarak
kullanılmaz (rozet içinde koyulaştırılmış `#068a6b` tonu kullanılır).

---

## 5. Tipografi

**Inter** (Google Fonts), sistem yazı tipi yedeğiyle.

| Kullanım | Ağırlık / boyut |
|---|---|
| Hero başlık | 850, `clamp(2.4rem, 5.4vw, 4.1rem)`, harf aralığı −0.035em |
| Bölüm başlığı | 800, `clamp(2rem, 3.9vw, 3rem)` |
| Kart başlığı | 700–800, 1.2rem |
| Gövde | 400, 16px, satır yüksekliği 1.6 |
| Etiket/rozet | 700, 0.78rem, büyük harf, harf aralığı 0.09em |

Başlıklarda negatif harf aralığı markanın "sıkı ve hızlı" hissini taşır — değiştirme.

---

## 6. Görsel dil

- **Yazı az, görsel çok.** Her bölümde en fazla bir cümlelik açıklama; gerisi şema, kart, rozet, mockup.
- İllüstrasyonlar **satır içi SVG**; stok fotoğraf kullanma.
- Kartlar: 24 px yarıçap, 1 px `#E2E9F4` kenarlık, yumuşak gölge, hover'da 5 px yukarı.
- Durumlar her zaman renkli rozetle: yeşil "yayında", amber "işleniyor", kırmızı "hata".
- Animasyon ölçülü: görünüme girince yukarı kayma, yüzen bildirim kartı.
  `prefers-reduced-motion` daima saygı görür.
- Rakamlar `font-variant-numeric: tabular-nums` ile hizalanır (panel tabloları).

---

## 7. Uygulama notu

Tüm bu kararlar `assets/css/depar.css` dosyasında **token** olarak tanımlıdır (`:root`).
Next.js'e taşırken CSS dosyasını olduğu gibi al; renk veya boşluk değerini bileşen içine
sabit yazma, token üzerinden kullan.
