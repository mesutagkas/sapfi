import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Fiyatlandırma — Depar",
  description: "Satıştan komisyon yok, sabit aylık abonelik. Paketleri karşılaştır.",
};

export default function FiyatlandirmaPage() {
  return (
    <>
      <section className="section section--tight">
        <div className="wrap center">
          <span className="eyebrow">Fiyatlandırma</span>
          <h1 className="h-xxl mt-16">Ne satarsan sat,<br /><span className="underline-mark">komisyon yok.</span></h1>
          <p className="lead mt-16 mx-auto maxw-44">Sadece sabit aylık abonelik. Ciron büyüdükçe faturan büyümez.</p>
          <div className="center mt-32">
            <div className="toggle" data-price-toggle="">
              <button className="is-on" data-mode="monthly">Aylık</button>
              <button data-mode="yearly">Yıllık · 2 ay bedava</button>
            </div>
          </div>
        </div>
      </section>

      <section className="section--tight">
        <div className="wrap">
          <div className="plans">
            <article className="plan rv">
              <div><h3 className="h-m">Başlangıç</h3><p className="small muted mt-8">İlk satışını yapacaklar</p></div>
              <div className="price"><b data-monthly="499" data-yearly="415">499</b><span className="price__per" data-per="">₺/ay + KDV</span></div>
              <span className="badge badge--mint hide" data-save="">Yılda ₺1.008 tasarruf</span>
              <a className="btn btn--ghost btn--block" href="/giris#kayit">14 gün ücretsiz</a>
              <hr />
              <ul>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 250 aktif ürün</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 1 pazaryeri mağazası</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 500 sipariş/ay</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 4 saatte bir senkron</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 1 kullanıcı · e-posta destek</li>
              </ul>
            </article>

            <article className="plan plan--pop rv">
              <span className="plan__tag badge badge--brand">En çok seçilen</span>
              <div><h3 className="h-m">Profesyonel</h3><p className="small muted mt-8">Büyüyen mağazalar</p></div>
              <div className="price"><b data-monthly="1.499" data-yearly="1.249">1.499</b><span className="price__per" data-per="">₺/ay + KDV</span></div>
              <span className="badge badge--mint hide" data-save="">Yılda ₺3.000 tasarruf</span>
              <a className="btn btn--primary btn--block" href="/giris#kayit">14 gün ücretsiz</a>
              <hr />
              <ul>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 5.000 aktif ürün</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 3 pazaryeri mağazası</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 5.000 sipariş/ay</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 15 dakikada bir senkron</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Otomatik fiyat & kâr kuralları</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 3 kullanıcı · WhatsApp destek</li>
              </ul>
            </article>

            <article className="plan rv">
              <div><h3 className="h-m">Kurumsal</h3><p className="small muted mt-8">Çok kanallı operasyon</p></div>
              <div className="price"><b data-monthly="4.999" data-yearly="4.165">4.999</b><span className="price__per" data-per="">₺/ay + KDV</span></div>
              <span className="badge badge--mint hide" data-save="">Yılda ₺10.008 tasarruf</span>
              <a className="btn btn--ghost btn--block" href="/giris#kayit">Görüşme ayarla</a>
              <hr />
              <ul>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Sınırsız ürün</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Sınırsız mağaza</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 50.000 sipariş/ay</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 5 dakikada senkron + webhook</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Depar API + özel entegrasyon</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 10 kullanıcı · özel temsilci</li>
              </ul>
            </article>
          </div>
          <p className="center muted small mt-32">Fiyatlara KDV dahil değildir. İstediğin an yükselt, düşür ya da iptal et.</p>
        </div>
      </section>

      {/* neye göre fiyat */}
      <section className="section">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">Şeffaf mantık</span>
            <h2 className="h-xl">Fiyatı ne belirliyor?</h2>
            <p className="lead maxw-44">Gizli kalem yok. Paket, sistemde tükettiğin kaynağa göre kurgulandı.</p>
          </div>
          <div className="grid g4">
            <div className="card rv"><div className="ico ico--sm"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" /></svg></div><h3 className="h-s mt-16">Aktif ürün</h3><p className="small muted mt-8">Her ürün sürekli stok/fiyat kontrolü demek.</p></div>
            <div className="card rv"><div className="ico ico--sm ico--mint"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M4 9h16v11H4z" /><path d="M3 9l1.5-5h15L21 9a3 3 0 0 1-6 0 3 3 0 0 1-6 0 3 3 0 0 1-6 0Z" /></svg></div><h3 className="h-s mt-16">Mağaza sayısı</h3><p className="small muted mt-8">Her kanal ayrı API kotası ve eşleme.</p></div>
            <div className="card rv"><div className="ico ico--sm ico--amber"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h11v10H3z" /><path d="M14 9h4l3 3v4h-7z" /><circle cx="7" cy="18" r="2" /><circle cx="17.5" cy="18" r="2" /></svg></div><h3 className="h-s mt-16">Sipariş adedi</h3><p className="small muted mt-8">Sipariş = bildirim, fatura, kargo takibi.</p></div>
            <div className="card rv"><div className="ico ico--sm"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3.5 2" /></svg></div><h3 className="h-s mt-16">Senkron sıklığı</h3><p className="small muted mt-8">Sık senkron = daha az stok hatası.</p></div>
          </div>
        </div>
      </section>

      {/* karşılaştırma tablosu */}
      <section className="section section--soft">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">Detay</span>
            <h2 className="h-xl">Paket karşılaştırma</h2>
          </div>
          <div className="table-wrap rv">
            <table className="tbl">
              <thead>
                <tr><th>Özellik</th><th>Başlangıç</th><th>Profesyonel</th><th>Kurumsal</th></tr>
              </thead>
              <tbody>
                <tr><td>Aylık ücret</td><td className="num">₺499</td><td className="num">₺1.499</td><td className="num">₺4.999</td></tr>
                <tr><td>Aktif ürün</td><td className="num">250</td><td className="num">5.000</td><td className="num">Sınırsız</td></tr>
                <tr><td>Pazaryeri mağazası</td><td className="num">1</td><td className="num">3</td><td className="num">Sınırsız</td></tr>
                <tr><td>Aylık sipariş</td><td className="num">500</td><td className="num">5.000</td><td className="num">50.000</td></tr>
                <tr><td>Stok / fiyat senkronu</td><td>4 saat</td><td>15 dakika</td><td>5 dakika + webhook</td></tr>
                <tr><td>Kullanıcı sayısı</td><td className="num">1</td><td className="num">3</td><td className="num">10</td></tr>
                <tr><td>Otomatik fiyat kuralları</td><td className="no">—</td><td className="yes">✓</td><td className="yes">✓</td></tr>
                <tr><td>Kâr & komisyon hesaplayıcı</td><td className="yes">✓</td><td className="yes">✓</td><td className="yes">✓</td></tr>
                <tr><td>Toplu ürün aktarımı</td><td className="num">50/gün</td><td className="num">1.000/gün</td><td>Sınırsız</td></tr>
                <tr><td>İade & iptal yönetimi</td><td className="yes">✓</td><td className="yes">✓</td><td className="yes">✓</td></tr>
                <tr><td>Depar API erişimi</td><td className="no">—</td><td className="no">—</td><td className="yes">✓</td></tr>
                <tr><td>Özel entegrasyon / ERP</td><td className="no">—</td><td className="no">—</td><td className="yes">✓</td></tr>
                <tr><td>Destek</td><td>E-posta</td><td>WhatsApp · 4 saat</td><td>Özel temsilci · 1 saat</td></tr>
                <tr><td>Satış komisyonu</td><td className="yes">%0</td><td className="yes">%0</td><td className="yes">%0</td></tr>
              </tbody>
            </table>
          </div>
          <div className="grid g3 mt-32">
            <div className="card rv"><h3 className="h-s">Limit aşımı</h3><p className="small muted mt-8">Sipariş limitini aşarsan sistem durmaz; aşan her 100 sipariş için ₺79 eklenir.</p></div>
            <div className="card rv"><h3 className="h-s">Ek kullanıcı</h3><p className="small muted mt-8">Paket dışı her kullanıcı ₺149/ay.</p></div>
            <div className="card rv"><h3 className="h-s">Ek mağaza</h3><p className="small muted mt-8">Paket dışı her pazaryeri mağazası ₺299/ay.</p></div>
          </div>
        </div>
      </section>

      {/* sss */}
      <section className="section">
        <div className="wrap" style={{ maxWidth: "860px" }}>
          <div className="sec-head center rv"><span className="eyebrow">Fatura & abonelik</span><h2 className="h-xl">Sık sorulanlar</h2></div>
          <div className="faq rv">
            <div className="faq__item is-open">
              <button className="faq__q" aria-expanded="true">Deneme süresinde kart isteniyor mu?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>Hayır. 14 gün boyunca kart bilgisi girmeden tüm Profesyonel özellikleri kullanırsın.</p></div>
            </div>
            <div className="faq__item">
              <button className="faq__q" aria-expanded="false">Paketimi sonradan değiştirebilir miyim?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>Evet. Yükseltmede fark anında, düşürmede bir sonraki dönemde geçerli olur.</p></div>
            </div>
            <div className="faq__item">
              <button className="faq__q" aria-expanded="false">Tedarikçiler de ödüyor mu?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>Hayır. Tedarikçi üyeliği ve ürün yükleme tamamen ücretsizdir.</p></div>
            </div>
            <div className="faq__item">
              <button className="faq__q" aria-expanded="false">Ödeme nasıl alınıyor?<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>Kredi kartından otomatik yenilemeli olarak, 3D Secure ile. Her dönem e-fatura düzenlenir.</p></div>
            </div>
          </div>
          <div className="center mt-48">
            <a className="btn btn--primary btn--lg" href="/giris#kayit">14 gün ücretsiz başla</a>
          </div>
        </div>
      </section>
    </>
  );
}
