/* =========================================================
   AYARLAR — İletişim bilgilerinizi sadece buradan değiştirin.
   Boş bıraktığınız sosyal medya bağlantıları sayfada gizlenir.
   ========================================================= */
const CONFIG = {
  brandName: "Sapfi Akvaryum",

  // Telefon: ülke koduyla, boşluksuz (örn. 905321234567)
  phone: "905555555555",
  // Sayfada görünecek hali
  phoneDisplay: "0555 555 55 55",

  // WhatsApp numarası (genelde telefonla aynı), ülke koduyla, + ve boşluk olmadan
  whatsapp: "905555555555",
  whatsappMessage: "Merhaba, web sitenizden ulaşıyorum. Bilgi almak istiyorum.",

  instagramHandle: "sapfiakvaryum",

  address: "Örnek Mah. Akvaryum Cad. No:1, İstanbul",
  // Google Haritalar bağlantısı (boş bırakılırsa adresle arama yapılır)
  mapsUrl: "",

  hours: "Pazartesi – Cumartesi: 10:00 – 20:00 · Pazar: 12:00 – 18:00",

  // İsteğe bağlı — boş bırakılırsa ikon gizlenir
  youtube: "",
  facebook: "",
  tiktok: "",
};

/* =========================================================
   ÜRÜN / HİZMET KATEGORİLERİ
   ========================================================= */
const PRODUCTS = [
  { icon: "🐟", title: "Akvaryumlar", text: "Hazır ve ölçüye özel akvaryumlar, dolaplı setler, nano ve bitkili akvaryum çözümleri.", tags: ["Ölçüye özel", "Nano", "Set"] },
  { icon: "🐠", title: "Süs Balıkları", text: "Karantinadan geçmiş, sağlıklı tatlı su süs balıkları ve karides çeşitleri.", tags: ["Lepistes", "Tetra", "Betta", "Karides"] },
  { icon: "🌿", title: "Canlı Bitkiler", text: "Bakımı kolay başlangıç bitkilerinden zemin örtücülere kadar geniş bitki seçkisi.", tags: ["Anubias", "Yosun", "Kriptokorin"] },
  { icon: "🌀", title: "Filtre & Pompa", text: "İç filtre, dış filtre, askı filtre, hava motoru ve sirkülasyon pompaları.", tags: ["Dış filtre", "Hava motoru"] },
  { icon: "💡", title: "Aydınlatma", text: "Bitki gelişimini destekleyen, renkleri canlı gösteren LED akvaryum aydınlatmaları.", tags: ["LED", "Zamanlayıcı"] },
  { icon: "🌡️", title: "Isıtıcı & Ölçüm", text: "Termostatlı ısıtıcılar, termometreler ve su değerlerini ölçen test kitleri.", tags: ["Isıtıcı", "Test kiti"] },
  { icon: "🍤", title: "Yem & Vitamin", text: "Pul, granül, tablet ve dondurulmuş yemler; türe özel beslenme ürünleri.", tags: ["Pul yem", "Dondurulmuş"] },
  { icon: "🪸", title: "Dekor & Zemin", text: "Doğal taşlar, kökler, bitki kumu, akvaryum kumu ve dekoratif ürünler.", tags: ["Kök", "Taş", "Bitki kumu"] },
  { icon: "🧪", title: "Bakım Ürünleri", text: "Su düzenleyiciler, bakteri kültürleri, sifon ve temizlik ekipmanları.", tags: ["Su düzenleyici", "Bakteri"] },
];

/* =========================================================
   BLOG YAZILARI
   Yeni yazı eklemek için listeye yeni bir nesne ekleyin.
   - slug: adres çubuğunda görünür (Türkçe karakter ve boşluk kullanmayın)
   - image: isterseniz "assets/img/dosya.jpg" gibi kapak fotoğrafı verin
   ========================================================= */
const POSTS = [
  {
    slug: "ilk-akvaryum-kurulumu",
    title: "İlk Akvaryumunuzu Kurarken Bilmeniz Gereken 7 Adım",
    category: "Başlangıç",
    date: "2026-09-20",
    readTime: 6,
    emoji: "🏠",
    color: ["#1fb6c9", "#0b4f6c"],
    excerpt: "Akvaryum almadan önce yer seçiminden balık eklemeye kadar dikkat etmeniz gereken temel adımlar.",
    content: `
      <p>Akvaryum kurmak heyecan verici bir süreç. Ancak acele etmek, yeni başlayanların en sık yaptığı hatadır. Aşağıdaki adımları takip ederek sağlıklı ve uzun ömürlü bir akvaryuma sahip olabilirsiniz.</p>
      <h3>1. Doğru yeri seçin</h3>
      <p>Akvaryumu doğrudan güneş ışığı almayan, kalorifer ve klimadan uzak, sağlam ve düz bir zemine yerleştirin. Unutmayın; 100 litrelik bir akvaryum dolu haliyle 130 kg'ı aşabilir.</p>
      <h3>2. Boyutu iyi belirleyin</h3>
      <p>Küçük akvaryumların bakımı daha kolay sanılır ama tam tersi geçerlidir. Su hacmi arttıkça değerler daha stabil kalır. Yeni başlayanlar için <strong>60–100 litre</strong> idealdir.</p>
      <h3>3. Temel ekipmanları hazırlayın</h3>
      <ul>
        <li>Filtre (akvaryum hacmine uygun)</li>
        <li>Termostatlı ısıtıcı ve termometre</li>
        <li>LED aydınlatma</li>
        <li>Zemin malzemesi, dekor ve bitkiler</li>
        <li>Su düzenleyici (klor giderici)</li>
      </ul>
      <h3>4. Zemini ve dekoru yerleştirin</h3>
      <p>Kumu yıkayarak serin, taş ve kökleri yerleştirin. Bitkili akvaryum planlıyorsanız alta bitki kumu koymayı unutmayın.</p>
      <h3>5. Suyu doldurun ve düzenleyici ekleyin</h3>
      <p>Musluk suyundaki klor faydalı bakterilere ve balıklara zarar verir. Mutlaka su düzenleyici kullanın.</p>
      <h3>6. Azot döngüsünü tamamlayın</h3>
      <p>En önemli adım budur. Filtre çalışmaya başladıktan sonra faydalı bakterilerin oluşması <strong>3–6 hafta</strong> sürer. Bu süreçte balık eklemeyin veya bakteri kültürü kullanarak süreci destekleyin.</p>
      <div class="tip">💡 <strong>İpucu:</strong> Döngü tamamlandığında amonyak ve nitrit 0, nitrat ise ölçülebilir seviyede olmalıdır. Bunu test kitiyle kontrol edebilirsiniz.</div>
      <h3>7. Balıkları yavaş yavaş ekleyin</h3>
      <p>Tüm balıkları bir anda eklemek yerine birkaç hafta arayla küçük gruplar halinde ekleyin. Poşeti 15–20 dakika suda bekletip yavaşça akvaryum suyuna alıştırın.</p>
    `,
  },
  {
    slug: "azot-dongusu-nedir",
    title: "Azot Döngüsü Nedir? Akvaryumda Döngü Nasıl Kurulur?",
    category: "Bakım",
    date: "2026-09-12",
    readTime: 5,
    emoji: "🔄",
    color: ["#39d0a8", "#0b6b5c"],
    excerpt: "Balık ölümlerinin bir numaralı sebebi olan döngüsüz akvaryumu önlemek için bilmeniz gereken her şey.",
    content: `
      <p>Akvaryumdaki görünmez kahramanlar faydalı bakterilerdir. Azot döngüsü, balık atıklarından oluşan zehirli maddelerin bu bakteriler sayesinde daha az zararlı hale gelmesidir.</p>
      <h3>Döngü nasıl işler?</h3>
      <ol>
        <li><strong>Amonyak (NH₃):</strong> Balık dışkısı, artan yem ve çürüyen bitkilerden oluşur. Çok zehirlidir.</li>
        <li><strong>Nitrit (NO₂):</strong> Faydalı bakteriler amonyağı nitrite dönüştürür. Bu da zehirlidir.</li>
        <li><strong>Nitrat (NO₃):</strong> Başka bir bakteri grubu nitriti nitrata çevirir. Nitrat düşük seviyelerde görece zararsızdır ve su değişimiyle uzaklaştırılır.</li>
      </ol>
      <h3>Döngüyü nasıl başlatırım?</h3>
      <p>Filtreyi çalıştırın ve ortama bir amonyak kaynağı sağlayın (az miktarda yem veya bakteri kültürü). Bakteriler filtre süngerinde ve zeminde yerleşerek çoğalır.</p>
      <div class="tip">💡 <strong>Önemli:</strong> Filtre süngerini asla musluk suyuyla yıkamayın. Akvaryumdan aldığınız suyla hafifçe çalkalayın; aksi halde bakteri kolonisini yok edersiniz.</div>
      <h3>Döngünün bittiğini nasıl anlarım?</h3>
      <p>Test kitiyle ölçüm yaptığınızda amonyak ve nitrit 0 ppm, nitrat ise ölçülebilir seviyedeyse döngünüz tamamlanmıştır. Artık balıklarınızı yavaş yavaş ekleyebilirsiniz.</p>
    `,
  },
  {
    slug: "yeni-baslayanlar-icin-kolay-baliklar",
    title: "Yeni Başlayanlar İçin Bakımı Kolay 8 Süs Balığı",
    category: "Balıklar",
    date: "2026-08-30",
    readTime: 7,
    emoji: "🐠",
    color: ["#ff9a76", "#d64f2a"],
    excerpt: "Dayanıklı, uyumlu ve renkli: İlk akvaryumunuz için en doğru balık seçimleri.",
    content: `
      <p>İlk akvaryumda dayanıklı ve barışçıl türler seçmek hem sizin hem de balıklarınız için işleri kolaylaştırır. İşte en sevdiğimiz başlangıç türleri:</p>
      <h3>1. Lepistes (Guppy)</h3>
      <p>Renkli, hareketli ve dayanıklı. Kolayca ürerler; erkek-dişi oranına dikkat edin (1 erkeğe 2–3 dişi).</p>
      <h3>2. Plati</h3>
      <p>Sakin yapılı, farklı renk seçenekleri olan, topluluk akvaryumları için mükemmel bir tür.</p>
      <h3>3. Neon Tetra</h3>
      <p>Parlak mavi-kırmızı çizgileriyle göz alıcıdır. En az 6–8 kişilik sürüler halinde beslenmelidir.</p>
      <h3>4. Zebra Danyo</h3>
      <p>Neredeyse yorulmak bilmeyen, çok dayanıklı bir sürü balığıdır.</p>
      <h3>5. Koridoras</h3>
      <p>Zeminde yaşayan, artık yemleri temizleyen sevimli balıklar. Grup halinde (6+) ve yumuşak zeminde tutulmalıdır.</p>
      <h3>6. Beta (Siyam Savaşçısı)</h3>
      <p>Muhteşem yüzgeçleriyle tek başına bile bir akvaryumu güzelleştirir. İki erkek beta aynı akvaryumda kesinlikle tutulmamalıdır.</p>
      <h3>7. Ancistrus (Vatoz)</h3>
      <p>Yosun yiyen, küçük boyda kalan bir vatoz türüdür. Ortamda bir kök bulunması onun için faydalıdır.</p>
      <h3>8. Moli</h3>
      <p>Barışçıl ve canlı bir türdür. Biraz daha geniş akvaryumları ve stabil su değerlerini sever.</p>
      <div class="tip">💡 <strong>İpucu:</strong> Balık alırken akvaryumunuzun hacmini, mevcut balıklarınızı ve su sıcaklığını bize söyleyin; uyumlu türleri birlikte belirleyelim.</div>
    `,
  },
  {
    slug: "bakimi-kolay-akvaryum-bitkileri",
    title: "Bitkili Akvaryuma Başlangıç: Bakımı Kolay 6 Bitki",
    category: "Bitkiler",
    date: "2026-08-18",
    readTime: 5,
    emoji: "🌿",
    color: ["#4ade80", "#166534"],
    excerpt: "CO₂ sistemi olmadan da yemyeşil bir akvaryum mümkün. İşte en dayanıklı akvaryum bitkileri.",
    content: `
      <p>Canlı bitkiler sadece görsel değil, aynı zamanda biyolojik olarak da akvaryuma büyük katkı sağlar: nitratı tüketir, yosunla rekabet eder ve balıklara saklanma alanı oluşturur.</p>
      <h3>1. Anubias</h3>
      <p>Neredeyse yok edilemez bir bitkidir. Düşük ışıkta yaşar. Köksapı (rizom) toprağa gömülmemeli, taş veya köke bağlanmalıdır.</p>
      <h3>2. Java Eğreltisi</h3>
      <p>Anubias gibi köke veya taşa bağlanarak yetiştirilir. Yavaş büyür ama çok dayanıklıdır.</p>
      <h3>3. Java Yosunu</h3>
      <p>Karides ve yavru balıklar için harika bir saklanma alanıdır. Kökleri ve taşları kaplayarak doğal bir görünüm sağlar.</p>
      <h3>4. Kriptokorin</h3>
      <p>Zemine dikilen, farklı renk ve boyları olan bir bitkidir. İlk haftalarda yaprak dökebilir; panik yapmayın, yeniden çıkar.</p>
      <h3>5. Valisneria</h3>
      <p>Uzun şerit yapraklı, hızlı çoğalan bir arka plan bitkisidir.</p>
      <h3>6. Amazon Kılıcı</h3>
      <p>Geniş yapraklarıyla orta ve büyük akvaryumlarda harika bir odak noktası oluşturur. Kök tabletleriyle beslenmeyi sever.</p>
      <div class="tip">💡 <strong>İpucu:</strong> Işıkları günde 6–8 saat açık tutun. Fazla ışık, bitkilerden önce yosunun işine yarar.</div>
    `,
  },
  {
    slug: "dogru-filtre-secimi",
    title: "Akvaryum Filtresi Nasıl Seçilir? İç, Dış ve Askı Filtre Karşılaştırması",
    category: "Ekipman",
    date: "2026-08-05",
    readTime: 5,
    emoji: "🌀",
    color: ["#60a5fa", "#1e3a8a"],
    excerpt: "Filtre akvaryumun kalbidir. Hacminize ve balıklarınıza uygun filtreyi seçmenin püf noktaları.",
    content: `
      <p>Doğru filtre; temiz su, sağlıklı balıklar ve daha az bakım demektir. Seçim yaparken akvaryum hacmini ve balık yoğunluğunu göz önünde bulundurmalısınız.</p>
      <h3>Debi ne kadar olmalı?</h3>
      <p>Genel kural olarak filtrenin saatlik debisi, akvaryum hacminin <strong>en az 4–5 katı</strong> olmalıdır. Örneğin 100 litrelik bir akvaryum için 400–500 L/saat debili bir filtre uygundur. Japon balığı gibi çok atık yapan türlerde bu oranı artırın.</p>
      <h3>İç filtre</h3>
      <p>Ekonomik ve kurulumu kolaydır. Küçük ve orta boy akvaryumlar için idealdir; ancak akvaryum içinde yer kaplar.</p>
      <h3>Askı (şelale) filtre</h3>
      <p>Akvaryumun kenarına asılır, bakımı pratiktir ve suyu havalandırır. Kapaklı akvaryumlarda uyumluluğu kontrol edin.</p>
      <h3>Dış filtre</h3>
      <p>Büyük filtre hacmi sayesinde en güçlü biyolojik filtrasyonu sağlar. Dolabın içinde durduğu için akvaryumda yer kaplamaz. 100 litre ve üzeri akvaryumlar için önerimizdir.</p>
      <h3>Süngerli (hava motorlu) filtre</h3>
      <p>Yavru balık ve karides akvaryumları için güvenli ve ekonomik bir tercihtir.</p>
    `,
  },
  {
    slug: "akvaryum-su-degisimi",
    title: "Akvaryumda Su Değişimi: Ne Sıklıkla ve Nasıl Yapılmalı?",
    category: "Bakım",
    date: "2026-07-22",
    readTime: 4,
    emoji: "💧",
    color: ["#38bdf8", "#075985"],
    excerpt: "Düzenli su değişimi sağlıklı bir akvaryumun temelidir. Doğru oran ve yöntemleri öğrenin.",
    content: `
      <p>Filtre ne kadar iyi olursa olsun, nitrat ve çözünmüş atıklar zamanla birikir. Bunları uzaklaştırmanın tek yolu düzenli su değişimidir.</p>
      <h3>Ne sıklıkla?</h3>
      <p>Çoğu akvaryum için <strong>haftada bir, suyun %20–30'unu</strong> değiştirmek idealdir. Az ve sık değişim, seyrek ve büyük değişimden her zaman daha iyidir.</p>
      <h3>Adım adım su değişimi</h3>
      <ol>
        <li>Isıtıcı ve filtreyi kapatın.</li>
        <li>Sifon ile zemindeki atıkları çekerek suyu boşaltın.</li>
        <li>Camları yosun kazıyıcı ile temizleyin.</li>
        <li>Yeni suya su düzenleyici ekleyin ve sıcaklığını akvaryum suyuna yakın tutun.</li>
        <li>Suyu yavaşça doldurun, ekipmanları tekrar çalıştırın.</li>
      </ol>
      <div class="tip">💡 <strong>Dikkat:</strong> Tüm suyu bir anda değiştirmeyin ve akvaryumu deterjanla yıkamayın. Bu, faydalı bakterileri yok eder ve balıkları strese sokar.</div>
    `,
  },
  {
    slug: "japon-baligi-bakimi",
    title: "Japon Balığı Bakımı: Fanus Efsanesine Son!",
    category: "Balıklar",
    date: "2026-07-08",
    readTime: 5,
    emoji: "🐡",
    color: ["#fbbf24", "#c2410c"],
    excerpt: "Japon balıkları sanıldığı gibi fanusta yaşamaz. Uzun ve sağlıklı bir ömür için doğru koşullar.",
    content: `
      <p>Japon balıkları doğru koşullarda <strong>10 yıldan fazla</strong> yaşayabilir. Ancak fanuslarda tutulduklarında bu süre ne yazık ki çok kısalır.</p>
      <h3>Neden fanus uygun değil?</h3>
      <p>Japon balıkları çok yem yer ve çok atık üretir. Küçük, filtresiz bir fanusta amonyak hızla yükselir ve balık zehirlenir.</p>
      <h3>İdeal ortam</h3>
      <ul>
        <li>İlk balık için en az <strong>60–80 litre</strong>, her ek balık için yaklaşık 40 litre daha</li>
        <li>Güçlü bir filtre</li>
        <li>18–23 °C civarında su; çoğu zaman ısıtıcıya gerek yoktur</li>
        <li>Haftalık düzenli su değişimi</li>
      </ul>
      <h3>Beslenme</h3>
      <p>Günde 1–2 kez, 2 dakikada tüketebilecekleri kadar yem verin. Batan yemler, yüzeyden hava yutmayı azaltarak yüzme kesesi sorunlarını önlemeye yardımcı olur.</p>
      <div class="tip">💡 <strong>İpucu:</strong> Japon balıkları tropikal balıklarla aynı akvaryumda tutulmamalıdır; sıcaklık ihtiyaçları farklıdır.</div>
    `,
  },
];

/* =========================================================
   SIKÇA SORULAN SORULAR
   ========================================================= */
const FAQ = [
  { q: "Online satış yapıyor musunuz?", a: "Sitemiz üzerinden satış yapmıyoruz. Ürünler, stok ve fiyat bilgisi için WhatsApp'tan bize yazabilir, telefonla arayabilir veya mağazamızı ziyaret edebilirsiniz." },
  { q: "Ölçüye özel akvaryum yapıyor musunuz?", a: "Evet. İstediğiniz ölçü ve cam kalınlığında akvaryum ile uyumlu dolap imalatı yapıyoruz. Ölçülerinizi WhatsApp'tan iletmeniz yeterli." },
  { q: "Kurulum ve bakım hizmetiniz var mı?", a: "Akvaryum kurulumu, taşıma ve periyodik bakım hizmeti veriyoruz. Bölgenize göre detaylar için bizimle iletişime geçin." },
  { q: "Yeni başlayan biri için hangi akvaryumu önerirsiniz?", a: "60–100 litre arası bir akvaryum, yeni başlayanlar için hem bakım kolaylığı hem de su değerlerinin stabil kalması açısından idealdir. Size en uygun seti birlikte belirleyebiliriz." },
  { q: "Balıklarınız sağlıklı mı?", a: "Tüm balıklarımız satışa sunulmadan önce karantina sürecinden geçirilir ve düzenli olarak gözlemlenir." },
  { q: "Akvaryumumda sorun var, yardımcı olur musunuz?", a: "Elbette! Bulanık su, yosun, hasta balık gibi sorunlarda akvaryumunuzun fotoğrafını ve su değerlerinizi WhatsApp'tan gönderin, ücretsiz yardımcı olalım." },
];

/* =========================================================
   UYGULAMA — Bu kısmı değiştirmenize gerek yok.
   ========================================================= */
(function () {
  document.documentElement.classList.remove("no-js");

  const $ = (s, el = document) => el.querySelector(s);
  const $$ = (s, el = document) => [...el.querySelectorAll(s)];

  const waLink = (text = CONFIG.whatsappMessage) =>
    `https://wa.me/${CONFIG.whatsapp}?text=${encodeURIComponent(text)}`;

  const LINKS = {
    whatsapp: CONFIG.whatsapp ? waLink() : "",
    phone: CONFIG.phone ? `tel:+${CONFIG.phone}` : "",
    instagram: CONFIG.instagramHandle ? `https://instagram.com/${CONFIG.instagramHandle}` : "",
    maps: CONFIG.mapsUrl || (CONFIG.address ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(CONFIG.address)}` : ""),
    youtube: CONFIG.youtube,
    facebook: CONFIG.facebook,
    tiktok: CONFIG.tiktok,
  };

  /* --- Bağlantıları ve metinleri doldur --- */
  $$("[data-link]").forEach((el) => {
    const key = el.dataset.link;
    let href = LINKS[key];
    if (key === "whatsapp" && el.dataset.waText) href = waLink(el.dataset.waText);
    if (href) el.href = href;
    else el.hidden = true;
  });

  $$("[data-config]").forEach((el) => {
    const val = CONFIG[el.dataset.config];
    if (val) el.textContent = (el.dataset.prefix || "") + val;
  });

  $("#year").textContent = new Date().getFullYear();

  const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

  /* --- Ürün kartları --- */
  $("#productCards").innerHTML = PRODUCTS.map((p) => `
    <article class="card reveal">
      <div class="card__icon" aria-hidden="true">${p.icon}</div>
      <h3>${esc(p.title)}</h3>
      <p>${esc(p.text)}</p>
      <div class="card__tags">${p.tags.map((t) => `<span>${esc(t)}</span>`).join("")}</div>
      <a class="card__link" href="${waLink(`Merhaba, ${p.title} hakkında bilgi almak istiyorum.`)}" target="_blank" rel="noopener">
        <svg class="icon" aria-hidden="true"><use href="#i-whatsapp"/></svg> Bilgi al
      </a>
    </article>`).join("");

  /* --- Blog --- */
  const fmtDate = (d) => new Date(d + "T00:00:00").toLocaleDateString("tr-TR", { day: "numeric", month: "long", year: "numeric" });
  const cover = (p) => p.image
    ? `<img src="${esc(p.image)}" alt="" loading="lazy" />`
    : `<span class="emoji" aria-hidden="true">${p.emoji}</span>`;
  const coverStyle = (p) => `background: linear-gradient(135deg, ${p.color[0]}, ${p.color[1]});`;

  const posts = [...POSTS].sort((a, b) => b.date.localeCompare(a.date));
  const postsEl = $("#blogPosts");
  postsEl.innerHTML = posts.map((p, i) => `
    <article class="post${i === 0 ? " post--featured" : ""} reveal" data-category="${esc(p.category)}" data-slug="${p.slug}" tabindex="0" role="link" aria-label="${esc(p.title)}">
      <div class="post__cover" style="${coverStyle(p)}">
        <span class="post__badge">${esc(p.category)}</span>
        ${cover(p)}
      </div>
      <div class="post__body">
        <div class="post__meta"><span>📅 ${fmtDate(p.date)}</span><span>⏱ ${p.readTime} dk okuma</span></div>
        <h3>${esc(p.title)}</h3>
        <p class="post__excerpt">${esc(p.excerpt)}</p>
        <span class="post__more">Devamını oku</span>
      </div>
    </article>`).join("");

  const categories = ["Tümü", ...new Set(posts.map((p) => p.category))];
  const filtersEl = $("#blogFilters");
  filtersEl.innerHTML = categories.map((c, i) =>
    `<button class="filter${i === 0 ? " is-active" : ""}" role="tab" aria-selected="${i === 0}" data-filter="${esc(c)}">${esc(c)}</button>`
  ).join("");

  filtersEl.addEventListener("click", (e) => {
    const btn = e.target.closest(".filter");
    if (!btn) return;
    $$(".filter", filtersEl).forEach((b) => { b.classList.toggle("is-active", b === btn); b.setAttribute("aria-selected", b === btn); });
    const cat = btn.dataset.filter;
    $$(".post", postsEl).forEach((el) => el.classList.toggle("is-hidden", cat !== "Tümü" && el.dataset.category !== cat));
  });

  /* --- Yazı penceresi (modal) --- */
  const modal = $("#postModal");
  let lastFocus = null;

  function openPost(slug, push = true) {
    const p = POSTS.find((x) => x.slug === slug);
    if (!p) return;
    lastFocus = document.activeElement;
    $("#modalCover").setAttribute("style", coverStyle(p));
    $("#modalCover").innerHTML = cover(p);
    $("#modalMeta").innerHTML = `<span>🏷 ${esc(p.category)}</span><span>📅 ${fmtDate(p.date)}</span><span>⏱ ${p.readTime} dk okuma</span>`;
    $("#modalTitle").textContent = p.title;
    $("#modalContent").innerHTML = p.content;
    $("#modalWa").href = waLink(`Merhaba, "${p.title}" yazınızı okudum, bir sorum var.`);
    $("#modalWa").hidden = !CONFIG.whatsapp;
    modal.hidden = false;
    document.body.style.overflow = "hidden";
    $(".modal__dialog", modal).scrollTop = 0;
    $(".modal__close", modal).focus();
    document.title = `${p.title} | ${CONFIG.brandName}`;
    if (push) history.pushState({ post: slug }, "", `#yazi/${slug}`);
  }

  const baseTitle = document.title;
  function closePost(push = true) {
    if (modal.hidden) return;
    modal.hidden = true;
    document.body.style.overflow = "";
    document.title = baseTitle;
    if (push && location.hash.startsWith("#yazi/")) history.pushState(null, "", "#blog");
    if (lastFocus) lastFocus.focus();
  }

  postsEl.addEventListener("click", (e) => {
    const card = e.target.closest(".post");
    if (card) openPost(card.dataset.slug);
  });
  postsEl.addEventListener("keydown", (e) => {
    const card = e.target.closest(".post");
    if (card && (e.key === "Enter" || e.key === " ")) { e.preventDefault(); openPost(card.dataset.slug); }
  });
  modal.addEventListener("click", (e) => { if (e.target.closest("[data-close]")) closePost(); });
  document.addEventListener("keydown", (e) => { if (e.key === "Escape") { closePost(); closeMenu(); } });

  const syncHash = () => {
    const m = location.hash.match(/^#yazi\/(.+)$/);
    if (m) openPost(decodeURIComponent(m[1]), false);
    else closePost(false);
  };
  window.addEventListener("popstate", syncHash);
  syncHash();

  /* --- SSS --- */
  $("#faqList").innerHTML = FAQ.map((f, i) => `
    <details class="reveal"${i === 0 ? " open" : ""}>
      <summary>${esc(f.q)}</summary>
      <p>${esc(f.a)}</p>
    </details>`).join("");

  /* --- Menü --- */
  const nav = $("#nav");
  const menu = $("#navMenu");
  const toggle = $("#navToggle");

  function closeMenu() {
    menu.classList.remove("is-open");
    toggle.setAttribute("aria-expanded", "false");
    toggle.setAttribute("aria-label", "Menüyü aç");
  }
  toggle.addEventListener("click", () => {
    const open = menu.classList.toggle("is-open");
    toggle.setAttribute("aria-expanded", open);
    toggle.setAttribute("aria-label", open ? "Menüyü kapat" : "Menüyü aç");
  });
  menu.addEventListener("click", (e) => { if (e.target.closest("a")) closeMenu(); });

  const onScroll = () => nav.classList.toggle("is-scrolled", window.scrollY > 30);
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();

  // Aktif menü bağlantısı
  const sections = $$("main section[id]");
  const navLinks = $$('.nav__menu a[href^="#"]');
  if ("IntersectionObserver" in window) {
    const spy = new IntersectionObserver((entries) => {
      entries.forEach((en) => {
        if (en.isIntersecting) navLinks.forEach((a) => a.classList.toggle("is-active", a.getAttribute("href") === `#${en.target.id}`));
      });
    }, { rootMargin: "-45% 0px -50% 0px" });
    sections.forEach((s) => spy.observe(s));
  }

  /* --- Kabarcıklar --- */
  const bubbles = $("#bubbles");
  for (let i = 0; i < 22; i++) {
    const b = document.createElement("span");
    const size = 4 + Math.random() * 16;
    Object.assign(b.style, {
      width: `${size}px`, height: `${size}px`,
      left: `${Math.random() * 100}%`,
      animationDuration: `${8 + Math.random() * 12}s`,
      animationDelay: `${-Math.random() * 20}s`,
    });
    bubbles.appendChild(b);
  }

  /* --- Görünme animasyonu --- */
  const reveals = $$(".reveal");
  if ("IntersectionObserver" in window) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((en) => {
        if (en.isIntersecting) { en.target.classList.add("is-visible"); io.unobserve(en.target); }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -40px 0px" });
    reveals.forEach((el) => io.observe(el));
  } else {
    reveals.forEach((el) => el.classList.add("is-visible"));
  }
})();
