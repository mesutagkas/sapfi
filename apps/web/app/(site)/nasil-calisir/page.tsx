import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Nasıl çalışır — Depar",
  description: "Ürün seç, mağazana aktar, sipariş gelsin. Stoksuz satışın tüm akışı tek sayfada.",
};

export default function NasilCalisirPage() {
  return (
    <>
      {/* başlık */}
      <section className="section section--tight">
        <div className="wrap center">
          <span className="eyebrow">Akışın tamamı</span>
          <h1 className="h-xxl mt-16">Ürün onların.<br />Vitrin senin.</h1>
          <p className="lead mt-16 mx-auto maxw-44">Tek şema: tedarikçiden alıcıya kadar her adım.</p>
        </div>
      </section>

      {/* büyük şema */}
      <section className="section--tight">
        <div className="wrap">
          <div className="card card--pad-lg rv">
            <div className="flowmap">
              <div className="flowmap__node">
                <div className="ico mx-auto"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" /><path d="m4 7.5 8 4.5 8-4.5M12 12v9" /></svg></div>
                <div className="h-s mt-16">Tedarikçi</div>
                <div className="tiny muted">Ürün · stok · fiyat</div>
              </div>
              <div className="flowmap__arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6" /></svg></div>
              <div className="flowmap__node" style={{ borderColor: "#2F6BFF", boxShadow: "0 20px 50px -28px rgba(47,107,255,.8)" }}>
                <div className="ico ico--mint mx-auto"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M10 14a4 4 0 0 0 5.66 0l3-3A4 4 0 0 0 13 5.34l-1.5 1.5" /><path d="M14 10a4 4 0 0 0-5.66 0l-3 3A4 4 0 0 0 11 18.66l1.5-1.5" /></svg></div>
                <div className="h-s mt-16">Depar</div>
                <div className="tiny muted">Eşleştirme · senkron · sipariş yönetimi</div>
              </div>
              <div className="flowmap__arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6" /></svg></div>
              <div className="flowmap__node">
                <div className="ico ico--amber mx-auto"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M4 9h16v11H4z" /><path d="M3 9l1.5-5h15L21 9a3 3 0 0 1-6 0 3 3 0 0 1-6 0 3 3 0 0 1-6 0Z" /></svg></div>
                <div className="h-s mt-16">Satıcı mağazası</div>
                <div className="tiny muted">Trendyol · Hepsiburada · N11</div>
              </div>
            </div>
            <hr className="mt-32" />
            <div className="grid g3 mt-32">
              <div className="row" style={{ alignItems: "flex-start", gap: "12px" }}>
                <div className="ico ico--sm"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M20 11a8 8 0 0 0-14-4.5L4 9" /><path d="M4 5v4h4" /><path d="M4 13a8 8 0 0 0 14 4.5L20 15" /><path d="M20 19v-4h-4" /></svg></div>
                <div><div className="h-s">Stok tek yönlü akar</div><div className="small muted">Tedarikçi → mağaza, dakikalar içinde.</div></div>
              </div>
              <div className="row" style={{ alignItems: "flex-start", gap: "12px" }}>
                <div className="ico ico--sm ico--mint"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h11v10H3z" /><path d="M14 9h4l3 3v4h-7z" /><circle cx="7" cy="18" r="2" /><circle cx="17.5" cy="18" r="2" /></svg></div>
                <div><div className="h-s">Sipariş ters yönde</div><div className="small muted">Mağaza → Depar → tedarikçi.</div></div>
              </div>
              <div className="row" style={{ alignItems: "flex-start", gap: "12px" }}>
                <div className="ico ico--sm ico--amber"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="7" width="18" height="12" rx="2" /><path d="M3 7a2 2 0 0 1 2-2h12v2" /><circle cx="17" cy="13" r="1.3" /></svg></div>
                <div><div className="h-s">Para satıcıda toplanır</div><div className="small muted">Tedarikçi bedeli cariden düşer.</div></div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* rol bazlı */}
      <section className="section">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">İki taraf</span>
            <h2 className="h-xl">Kim ne yapıyor?</h2>
          </div>
          <div className="vs">
            <div className="vs__col rv">
              <span className="badge badge--brand">Satıcı</span>
              <h3 className="h-l mt-16">Sen sadece satarsın</h3>
              <ul className="stack mt-24">
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Mağaza API'ni bağlarsın</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Katalogdan ürün seçersin</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Fiyatını sen belirlersin</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Alıcıya faturayı sen kesersin</li>
              </ul>
            </div>
            <div className="vs__col rv">
              <span className="badge badge--mint">Tedarikçi</span>
              <h3 className="h-l mt-16">O sadece gönderir</h3>
              <ul className="stack mt-24">
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Ürün ve stoğu yükler</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Siparişi hazırlar</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Alıcı adresine kargolar</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Satıcıya fatura keser</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* para akışı */}
      <section className="section section--soft">
        <div className="wrap">
          <div className="grid g2" style={{ gap: "52px", alignItems: "center" }}>
            <div className="rv">
              <span className="eyebrow">Para akışı</span>
              <h2 className="h-xl mt-16">Kâr, satıştan önce belli.</h2>
              <p className="lead mt-16 maxw-44">Panel komisyonu, kargoyu ve KDV'yi düşer; net kârı ürün kartında gösterir.</p>
              <div className="row wrapf mt-24">
                <span className="badge badge--mint"><span className="dot"></span> Zarar edecek fiyata kilit</span>
                <span className="badge badge--brand"><span className="dot"></span> Otomatik fiyat kuralı</span>
              </div>
            </div>
            <div className="card card--pad-lg rv">
              <div className="row-between"><span className="h-s">Örnek sipariş</span><span className="badge">Kablosuz Kulaklık Pro</span></div>
              <hr className="mt-16" />
              <div className="row-between mt-16"><span className="muted small">Satış fiyatın</span><span className="bold">₺749,00</span></div>
              <div className="row-between mt-8"><span className="muted small">Pazaryeri komisyonu (%15)</span><span className="bold" style={{ color: "var(--danger)" }}>− ₺112,35</span></div>
              <div className="row-between mt-8"><span className="muted small">Kargo</span><span className="bold" style={{ color: "var(--danger)" }}>− ₺44,90</span></div>
              <div className="row-between mt-8"><span className="muted small">Tedarikçi bedeli</span><span className="bold" style={{ color: "var(--danger)" }}>− ₺410,00</span></div>
              <hr className="mt-16" />
              <div className="row-between mt-16">
                <span className="h-s">Net kârın</span>
                <span className="h-l" style={{ color: "#0FBF95" }}>₺181,75</span>
              </div>
              <div className="tiny muted mt-8">KDV hariç gösterim. Oranlar kategoriye göre panelde otomatik güncellenir.</div>
            </div>
          </div>
        </div>
      </section>

      {/* kurulum adımları */}
      <section className="section">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">Kurulum</span>
            <h2 className="h-xl">5 dakika, 4 adım.</h2>
          </div>
          <div className="grid g4">
            <div className="card card--hover rv"><div className="step__n">1</div><h3 className="h-s">Hesap aç</h3><p className="small muted mt-8">E-posta ve vergi bilgisi.</p></div>
            <div className="card card--hover rv"><div className="step__n" style={{ background: "var(--brand)" }}>2</div><h3 className="h-s">API anahtarını gir</h3><p className="small muted mt-8">Pazaryeri panelinden kopyala-yapıştır.</p></div>
            <div className="card card--hover rv"><div className="step__n" style={{ background: "var(--mint)" }}>3</div><h3 className="h-s">Ürün seç</h3><p className="small muted mt-8">Filtrele, kârı gör, aktar.</p></div>
            <div className="card card--hover rv"><div className="step__n" style={{ background: "var(--amber)" }}>4</div><h3 className="h-s">Sat</h3><p className="small muted mt-8">Siparişler panele düşsün.</p></div>
          </div>
          <div className="center mt-48">
            <a className="btn btn--primary btn--lg" href="/giris#kayit">Hemen kur</a>
          </div>
        </div>
      </section>
    </>
  );
}
