import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Tedarikçiler — Depar",
  description: "Ürünlerini bir kez yükle, yüzlerce satıcının vitrininde çık. Tedarikçi üyeliği ücretsiz.",
};

export default function TedarikciPage() {
  return (
    <>
      {/* hero */}
      <section className="hero">
        <div className="dotgrid" aria-hidden="true"></div>
        <div className="wrap hero__grid">
          <div>
            <span className="eyebrow"><span className="dot"></span> Üyelik ücretsiz</span>
            <h1 className="h-xxl mt-16">Bir yükle.<br /><span className="underline-mark">Yüzlerce vitrin.</span></h1>
            <p className="lead mt-16">Sen üretirsin, onlar satar. Reklam bütçesi yok, pazarlama derdi yok.</p>
            <div className="hero__cta">
              <a className="btn btn--primary btn--lg" href="/giris#kayit">Tedarikçi başvurusu</a>
              <a className="btn btn--ghost btn--lg" href="#yukleme">Yükleme yöntemleri</a>
            </div>
            <div className="hero__note">
              <span><svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="#0FBF95" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Komisyon yok</span>
              <span><svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="#0FBF95" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Aylık ücret yok</span>
              <span><svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="#0FBF95" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Reklam bütçesi yok</span>
            </div>
          </div>

          <div className="scene">
            <div className="scene__main">
              <div className="scene__bar"><i></i><i></i><i></i><span className="tiny muted" style={{ marginLeft: "auto" }}>tedarikçi paneli</span></div>
              <div className="row-between">
                <div><div className="h-s">Ürünlerim</div><div className="tiny muted">1.842 aktif</div></div>
                <span className="badge badge--mint"><span className="dot"></span> 126 satıcı vitrininde</span>
              </div>
              <div className="stack" style={{ gap: "8px" }}>
                <div className="mini"><span className="mini__l"><i style={{ background: "#2F6BFF" }}></i> Kablosuz Kulaklık Pro</span><span className="tiny muted">38 satıcı</span></div>
                <div className="mini"><span className="mini__l"><i style={{ background: "#0FBF95" }}></i> Akıllı Saat S2</span><span className="tiny muted">24 satıcı</span></div>
                <div className="mini"><span className="mini__l"><i style={{ background: "#FFB020" }}></i> Powerbank 20.000mAh</span><span className="tiny muted">51 satıcı</span></div>
              </div>
              <hr />
              <div className="row-between">
                <span className="small muted">Bu ay gelen sipariş</span><span className="h-m">1.407</span>
              </div>
            </div>
            <div className="notif">
              <div className="ico ico--sm ico--mint"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg></div>
              <div><div className="h-s">Yeni sipariş · hazırla</div><div className="tiny muted">Etiket panelde hazır</div></div>
            </div>
          </div>
        </div>
      </section>

      {/* kazanç */}
      <section className="section">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">Ne kazanırsın</span>
            <h2 className="h-xl">Satış gücünü kirala.</h2>
          </div>
          <div className="grid g3">
            <article className="card card--hover rv">
              <div className="ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="8" r="3.2" /><path d="M3 20c0-3.3 2.7-5.5 6-5.5s6 2.2 6 5.5" /><path d="M16 5.3a3.2 3.2 0 0 1 0 5.4M18 14.8c2.4.6 4 2.5 4 5.2" /></svg></div>
              <h3 className="h-m mt-16">Hazır satıcı ağı</h3>
              <p className="muted small mt-8">Binlerce mağazaya tek yüklemeyle ulaş.</p>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--mint"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M3 20h18M6 20v-6M11 20V8M16 20v-9M21 20V5" /></svg></div>
              <h3 className="h-m mt-16">Toplu sipariş hacmi</h3>
              <p className="muted small mt-8">Perakende iş yükü olmadan ölçek.</p>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--amber"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="7" width="18" height="12" rx="2" /><path d="M3 7a2 2 0 0 1 2-2h12v2" /><circle cx="17" cy="13" r="1.3" /></svg></div>
              <h3 className="h-m mt-16">Garantili tahsilat</h3>
              <p className="muted small mt-8">Satıcı cari limiti ve teminatı Depar kontrol eder.</p>
            </article>
          </div>
        </div>
      </section>

      {/* yükleme yöntemleri */}
      <section className="section section--soft" id="yukleme">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">Ürün yükleme</span>
            <h2 className="h-xl">Sana uyan yolu seç.</h2>
            <p className="lead maxw-44">Dört yöntem, aynı sonuç: katalogda canlı ürün.</p>
          </div>
          <div className="grid g4">
            <article className="card card--hover rv">
              <div className="ico ico--sm"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8l-5-5Z" /><path d="M14 3v5h5" /></svg></div>
              <h3 className="h-s mt-16">Excel / CSV</h3>
              <p className="small muted mt-8">Şablonu indir, doldur, yükle.</p>
              <span className="badge badge--brand mt-16">5 dakika</span>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--sm ico--mint"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="m9 8-5 4 5 4M15 8l5 4-5 4" /></svg></div>
              <h3 className="h-s mt-16">XML feed</h3>
              <p className="small muted mt-8">Linki ver, saatlik otomatik çeksin.</p>
              <span className="badge badge--mint mt-16">Otomatik</span>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--sm ico--amber"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M10 14a4 4 0 0 0 5.66 0l3-3A4 4 0 0 0 13 5.34l-1.5 1.5" /><path d="M14 10a4 4 0 0 0-5.66 0l-3 3A4 4 0 0 0 11 18.66l1.5-1.5" /></svg></div>
              <h3 className="h-s mt-16">API bağlantısı</h3>
              <p className="small muted mt-8">Anlık stok ve fiyat, gecikmesiz.</p>
              <span className="badge badge--amber mt-16">Canlı</span>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--sm"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M4 9h16v11H4z" /><path d="M3 9l1.5-5h15L21 9a3 3 0 0 1-6 0 3 3 0 0 1-6 0 3 3 0 0 1-6 0Z" /></svg></div>
              <h3 className="h-s mt-16">E-ticaret altyapın</h3>
              <p className="small muted mt-8">Ticimax, İkas, Ideasoft, WooCommerce.</p>
              <span className="badge mt-16">Hazır eklenti</span>
            </article>
          </div>
        </div>
      </section>

      {/* süreç */}
      <section className="section section--ink">
        <div className="wrap">
          <div className="grid g2" style={{ gap: "56px", alignItems: "center" }}>
            <div className="rv">
              <span className="eyebrow">Başvurudan satışa</span>
              <h2 className="h-xl mt-16">48 saatte yayında.</h2>
              <p className="lead mt-16 maxw-44">Belgeler tamamsa ekibimiz aynı gün dönüş yapar.</p>
              <a className="btn btn--white btn--lg mt-24" href="/giris#kayit">Başvuruyu başlat</a>
            </div>
            <div className="timeline rv">
              <div className="tl"><div className="tl__d tl__d--on"><b>1</b></div><div><div className="h-s">Başvuru</div><div className="small muted">Vergi levhası, imza sirküleri, iletişim</div></div></div>
              <div className="tl"><div className="tl__d tl__d--on"><b>2</b></div><div><div className="h-s">Onay</div><div className="small muted">Ürün ve kargo kapasitesi kontrolü</div></div></div>
              <div className="tl"><div className="tl__d tl__d--on"><b>3</b></div><div><div className="h-s">Katalog</div><div className="small muted">Excel, XML veya API ile yükleme</div></div></div>
              <div className="tl"><div className="tl__d tl__d--ok"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg></div><div><div className="h-s">Satış</div><div className="small muted">Siparişler panele düşmeye başlar</div></div></div>
            </div>
          </div>
        </div>
      </section>

      {/* şartlar */}
      <section className="section">
        <div className="wrap">
          <div className="grid g2" style={{ gap: "52px", alignItems: "center" }}>
            <div className="card card--pad-lg card--soft rv">
              <h3 className="h-l">Aradığımız tedarikçi</h3>
              <ul className="stack mt-24">
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Şahıs ya da limited şirket</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Aynı gün / ertesi gün kargo</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Güncel stok bildirimi</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Nötr paket (kendi markanı koymaman)</li>
              </ul>
            </div>
            <div className="rv">
              <span className="eyebrow">Şeffaflık</span>
              <h2 className="h-xl mt-16">Performansın görünür.</h2>
              <p className="lead mt-16 maxw-44">Kargo süresi, iptal oranı ve stok doğruluğu puanın satıcıya gösterilir. İyi tedarikçi öne çıkar.</p>
              <div className="grid g3 mt-24" style={{ gap: "12px" }}>
                <div className="card" style={{ padding: "16px" }}><div className="tiny muted">Kargo</div><div className="h-m">0,8 gün</div></div>
                <div className="card" style={{ padding: "16px" }}><div className="tiny muted">İptal</div><div className="h-m">%0,4</div></div>
                <div className="card" style={{ padding: "16px" }}><div className="tiny muted">Stok doğruluğu</div><div className="h-m">%99,2</div></div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="section--tight" style={{ paddingBottom: "88px" }}>
        <div className="wrap">
          <div className="cta-band rv center">
            <h2 className="h-xl">Ürünlerin satılmayı bekliyor.</h2>
            <p className="lead mt-16 mx-auto maxw-44" style={{ color: "#C6D4EC" }}>Tedarikçi üyeliği ücretsiz. Bugün yükle, bu hafta sat.</p>
            <div className="row wrapf mt-24" style={{ justifyContent: "center" }}>
              <a className="btn btn--white btn--lg" href="/giris#kayit">Tedarikçi ol</a>
              <a className="btn btn--line btn--lg" href="mailto:tedarikci@depar.com.tr">Bize yaz</a>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
