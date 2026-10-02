# Sapfi Akvaryum — Tanıtım & Blog Sayfası

Akvaryum, süs balığı ve akvaryum malzemeleri için modern, mobil uyumlu tanıtım ve blog sitesi.
Satış / kullanıcı paneli yoktur; ziyaretçiler WhatsApp, telefon ve Instagram üzerinden iletişime geçer.

## Bölümler

- **Hero** – Animasyonlu su altı arka planı, WhatsApp ve “Hemen Arayın” butonları
- **Hakkımızda**
- **Ürünlerimiz** – Her kategoride ilgili ürün için hazır mesajla açılan “Bilgi al” (WhatsApp) bağlantısı
- **Blog** – Kategori filtresi, yazılar açılır pencerede okunur, her yazının paylaşılabilir linki vardır (`#yazi/...`)
- **S.S.S.**
- **İletişim** – WhatsApp, telefon, Instagram, adres (Google Haritalar), çalışma saatleri
- Sabit WhatsApp butonu (sağ alt köşe)

## Düzenleme

Tüm içerik `assets/js/main.js` dosyasının en üstünde bulunur:

| Ne değiştirilecek | Nerede |
| --- | --- |
| Firma adı, telefon, WhatsApp, Instagram, adres, çalışma saatleri | `CONFIG` |
| Ürün kategorileri | `PRODUCTS` |
| Blog yazıları | `POSTS` |
| Sıkça sorulan sorular | `FAQ` |

- Telefon ve WhatsApp numaralarını ülke koduyla, boşluksuz yazın: `905321234567`
- YouTube / Facebook / TikTok alanları boş bırakılırsa ikonları otomatik gizlenir.
- Blog yazısına fotoğraf eklemek için görseli `assets/img/` klasörüne koyup yazıya `image: "assets/img/dosya.jpg"` ekleyin.
- Sayfa başlığı ve açıklaması (Google'da görünen) `index.html` içindeki `<title>` ve `<meta name="description">` etiketlerindedir.

## Yayınlama

Derleme veya kurulum gerekmez; dosyaları herhangi bir statik hostinge yüklemeniz yeterlidir.

**GitHub Pages:** Repo → *Settings* → *Pages* → *Branch* olarak `main` ve `/ (root)` seçin.
Netlify, Vercel veya klasik bir hosting (cPanel `public_html`) da kullanılabilir.

## Yerelde çalıştırma

[Node.js](https://nodejs.org) kurulu olmalıdır (ek paket kurmaya gerek yok):

```bash
npm start
```

Tarayıcıda **http://localhost:3000** adresini açın. Durdurmak için terminalde `Ctrl + C`.

Node.js yoksa `python -m http.server 3000` komutu da aynı işi görür
ya da `index.html` dosyasını doğrudan tarayıcıda açabilirsiniz.
