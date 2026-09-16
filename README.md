# Depar — stoksuz satış (dropshipping) platformu

Tedarikçi ile pazaryeri satıcısını tek panelde buluşturan abonelik tabanlı platform.
Tedarikçi ürünü yükler → satıcı tek tıkla Trendyol / Hepsiburada / N11 mağazasına aktarır →
sipariş geldiğinde iki tarafa bildirim gider → kargoyu tedarikçi alıcıya gönderir →
tahsilat satıcıda kalır, tedarikçi bedeli satıcının carisinden düşer.

Gelir modeli: **satıcıdan aylık abonelik**. Satıştan komisyon alınmaz, tedarikçi üyeliği ücretsizdir.

---

## Bu depoda ne var?

### 1) Frontend (hazır, çalışır durumda)

Bağımlılık yok, derleme yok. `index.html` dosyasını tarayıcıda açman yeterli.

| Dosya | İçerik |
|---|---|
| `index.html` | Ana sayfa: hero, 3 adım, entegrasyonlar, fayda ızgarası, sipariş akışı, karşılaştırma, fiyat özeti, SSS |
| `nasil-calisir.html` | Uçtan uca akış şeması, rol dağılımı, kâr/para akışı, kurulum adımları |
| `tedarikci.html` | Tedarikçi tarafı: kazanç, yükleme yöntemleri, onay süreci, performans puanı |
| `fiyatlandirma.html` | 3 paket, aylık/yıllık geçiş, detaylı karşılaştırma tablosu, limit aşım ücretleri |
| `panel.html` | Satıcı **ve** tedarikçi panel demosu (rol değiştirici + sekmeler + demo veri) |
| `giris.html` | Giriş / kayıt ekranı (satıcı–tedarikçi rol seçimli) |
| `assets/css/depar.css` | Tek dosya tasarım sistemi (token, bileşen, duyarlı yerleşim) |
| `assets/js/depar.js` | Menü, sayaç, akordiyon, fiyat değiştirici, panel sekmeleri, demo etkileşimler |
| `assets/img/` | Logo, logo işareti, favicon (SVG) |

Yerelde sunucuyla bakmak için:

```bash
npx http-server . -p 4000     # ya da: python3 -m http.server 4000
```

### 2) Backend yol haritası (adım adım dokümanlar)

| Doküman | Ne anlatıyor |
|---|---|
| [`docs/00-YOL-HARITASI.md`](docs/00-YOL-HARITASI.md) | Faz faz plan, ekip, takvim, bütçe, MVP kapsamı |
| [`docs/01-MIMARI-VE-SUNUCU.md`](docs/01-MIMARI-VE-SUNUCU.md) | Teknoloji seçimi, servisler, sunucu kurulumu, domain/SSL, Docker, CI/CD, izleme, yedek |
| [`docs/02-VERITABANI.md`](docs/02-VERITABANI.md) | Veri modeli, tablo tablo açıklama, indeks ve ölçekleme kararları |
| [`docs/schema.sql`](docs/schema.sql) | Çalıştırılabilir PostgreSQL şeması |
| [`docs/03-PAZARYERI-ENTEGRASYONLARI.md`](docs/03-PAZARYERI-ENTEGRASYONLARI.md) | Trendyol, Hepsiburada, N11 API anahtarları nasıl alınır, hangi uçlar, kuyruk ve hata yönetimi |
| [`docs/04-ODEME-ABONELIK-FATURA.md`](docs/04-ODEME-ABONELIK-FATURA.md) | iyzico/PayTR abonelik altyapısı, cari hesap, e-fatura, tahsilat akışı |
| [`docs/05-GUVENLIK-KVKK.md`](docs/05-GUVENLIK-KVKK.md) | API anahtarı şifreleme, yetkilendirme, KVKK, sözleşmeler, denetim izi |
| [`docs/06-FIYATLANDIRMA-MANTIGI.md`](docs/06-FIYATLANDIRMA-MANTIGI.md) | Abonelik fiyatları neye göre belirlendi, birim maliyet ve marj hesabı |
| [`docs/07-MARKA-KILAVUZU.md`](docs/07-MARKA-KILAVUZU.md) | İsim gerekçesi, logo, renk paleti, tipografi, dil tonu |

---

## Marka özeti

- **İsim:** Depar — "atağa kalkmak, hızlanmak". Kısa, Türkçe, akılda kalıcı, `.com.tr` ve sosyal medyada tek kelime.
- **Slogan:** *Stok tutma. Kargolama. Sadece sat.*
- **Renkler:** Lacivert `#0A1733` (güven) · Kobalt `#2F6BFF` (aksiyon) · Nane `#0FBF95` (kazanç) · Amber `#FFB020` (uyarı)
- **Logo:** Hız çizgileri + ileri ok — ürünün tedarikçiden vitrine akışı.

## Sıradaki adım

`docs/00-YOL-HARITASI.md` dosyasındaki **Faz 0** kontrol listesiyle başla (alan adı, şirket, pazaryeri hesapları, sunucu).
