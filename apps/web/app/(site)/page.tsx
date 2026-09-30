import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Depar — Stoksuz satış platformu",
  description: "Tedarikçinin ürünü, senin mağazanda. Trendyol, Hepsiburada ve N11'de stok tutmadan sat.",
};

export default function HomePage() {
  return (
    <>
      {/* ============ HERO ============ */}
      <section className="hero">
        <div className="dotgrid" aria-hidden="true"></div>
        <div className="wrap hero__grid">
          <div>
            <span className="eyebrow"><span className="dot pulse"></span> 3 pazaryeri · tek panel</span>
            <h1 className="h-xxl mt-16">Stok tutma.<br />Kargolama.<br /><span className="underline-mark">Sadece sat.</span></h1>
            <p className="lead mt-16">Tedarikçinin ürünü senin mağazanda. Sipariş gelir, kargoyu tedarikçi atar, kazanç sende kalır.</p>
            <div className="hero__cta">
              <a className="btn btn--primary btn--lg" href="/giris#kayit">14 gün ücretsiz dene
                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6" /></svg>
              </a>
              <a className="btn btn--ghost btn--lg" href="/panel">Paneli gör</a>
            </div>
            <div className="hero__note">
              <span><svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="#0FBF95" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Kredi kartı istemiyoruz</span>
              <span><svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="#0FBF95" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Satıştan komisyon yok</span>
              <span><svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="#0FBF95" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 5 dakikada kurulum</span>
            </div>
          </div>

          {/* hero görseli */}
          <div className="scene">
            <div className="scene__main">
              <div className="scene__bar"><i></i><i></i><i></i>
                <span className="tiny muted" style={{ marginLeft: "auto" }}>depar · ürün aktarımı</span>
              </div>

              <div className="pitem">
                <div className="pitem__img">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" /><path d="m4 7.5 8 4.5 8-4.5M12 12v9" /></svg>
                </div>
                <div style={{ flex: "1", minWidth: "0" }}>
                  <div className="h-s">Kablosuz Kulaklık Pro</div>
                  <div className="tiny muted">Tedarikçi: Anka Elektronik · Stok 412</div>
                </div>
                <div style={{ textAlign: "right" }}>
                  <div className="bold">₺410</div>
                  <div className="tiny muted">alış</div>
                </div>
              </div>

              <div className="flowline" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 5v14M6 13l6 6 6-6" /></svg>
              </div>

              <div className="stack" style={{ gap: "8px" }}>
                <div className="mini"><span className="mini__l"><i style={{ background: "#F27A1A" }}></i> Trendyol mağazam</span> <span className="badge badge--mint"><span className="dot"></span> Yayında ₺749</span></div>
                <div className="mini"><span className="mini__l"><i style={{ background: "#FF6000" }}></i> Hepsiburada</span> <span className="badge badge--mint"><span className="dot"></span> Yayında ₺769</span></div>
                <div className="mini"><span className="mini__l"><i style={{ background: "#7B3FA0" }}></i> N11</span> <span className="badge badge--amber"><span className="dot pulse"></span> Aktarılıyor</span></div>
              </div>
            </div>

            <div className="notif notif--tl">
              <div className="ico ico--sm ico--mint" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M20 11a8 8 0 0 0-14-4.5L4 9" /><path d="M4 5v4h4" /><path d="M4 13a8 8 0 0 0 14 4.5L20 15" /><path d="M20 19v-4h-4" /></svg>
              </div>
              <div>
                <div className="h-s">Stok senkronu</div>
                <div className="tiny muted">1.284 ürün · 6 dk önce</div>
              </div>
            </div>

            <div className="notif">
              <div className="ico ico--sm" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h11v10H3z" /><path d="M14 9h4l3 3v4h-7z" /><circle cx="7" cy="18" r="2" /><circle cx="17.5" cy="18" r="2" /></svg>
              </div>
              <div>
                <div className="h-s">Yeni sipariş · #10482</div>
                <div className="tiny muted">Tedarikçiye iletildi, kargo bugün çıkıyor</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============ İSTATİSTİK ============ */}
      <section className="section--tight">
        <div className="wrap">
          <div className="stats rv">
            <div className="stat"><b><span data-count="18400">0</span>+</b><span>hazır ürün</span></div>
            <div className="stat"><b><span data-count="260">0</span>+</b><span>onaylı tedarikçi</span></div>
            <div className="stat"><b><span data-count="48">0</span> sn</b><span>ortalama aktarım</span></div>
            <div className="stat"><b>%0</b><span>satış komisyonu</span></div>
          </div>
        </div>
      </section>

      {/* ============ 3 ADIM ============ */}
      <section className="section" id="nasil">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">3 adım</span>
            <h2 className="h-xl">Sermaye yok. Depo yok.</h2>
            <p className="lead maxw-44">Ürünü seç, mağazana gönder, siparişi bekle. Gerisi otomatik.</p>
          </div>

          <div className="steps">
            <article className="step rv">
              <div className="step__n">1</div>
              <h3 className="h-m">Ürünü seç</h3>
              <p className="muted small mt-8">18.000+ ürün arasından kârlı olanı seç.</p>
              <div className="step__art">
                <svg viewBox="0 0 320 150" width="100%" role="img" aria-label="Ürün kataloğu görseli">
                  <rect width="320" height="150" rx="14" fill="#F6F8FD" />
                  <rect x="18" y="20" width="130" height="10" rx="5" fill="#D8E3F6" />
                  <rect x="18" y="44" width="86" height="60" rx="10" fill="#fff" stroke="#E2E9F4" />
                  <rect x="30" y="56" width="62" height="24" rx="6" fill="#EAF1FF" />
                  <rect x="30" y="86" width="44" height="7" rx="3.5" fill="#D8E3F6" />
                  <rect x="116" y="44" width="86" height="60" rx="10" fill="#fff" stroke="#E2E9F4" />
                  <rect x="128" y="56" width="62" height="24" rx="6" fill="#E4F9F3" />
                  <rect x="128" y="86" width="44" height="7" rx="3.5" fill="#D8E3F6" />
                  <rect x="214" y="44" width="86" height="60" rx="10" fill="#fff" stroke="#2F6BFF" strokeWidth="2" />
                  <rect x="226" y="56" width="62" height="24" rx="6" fill="#EAF1FF" />
                  <rect x="226" y="86" width="44" height="7" rx="3.5" fill="#2F6BFF" />
                  <rect x="18" y="118" width="282" height="14" rx="7" fill="#fff" stroke="#E2E9F4" />
                </svg>
              </div>
            </article>

            <article className="step rv">
              <div className="step__n">2</div>
              <h3 className="h-m">Mağazana aktar</h3>
              <p className="muted small mt-8">Tek tıkla Trendyol, Hepsiburada, N11.</p>
              <div className="step__art">
                <svg viewBox="0 0 320 150" width="100%" role="img" aria-label="Pazaryerlerine aktarım görseli">
                  <rect width="320" height="150" rx="14" fill="#F6F8FD" />
                  <rect x="122" y="20" width="76" height="34" rx="10" fill="#0A1733" />
                  <text x="160" y="42" textAnchor="middle" fill="#fff" fontSize="13" fontWeight="700" fontFamily="Inter,Arial">depar</text>
                  <path d="M160 58v14M160 72l-70 16M160 72h0M160 72l70 16" stroke="#C7D5EC" strokeWidth="2" fill="none" />
                  <rect x="24" y="92" width="80" height="34" rx="10" fill="#fff" stroke="#E2E9F4" />
                  <circle cx="40" cy="109" r="6" fill="#F27A1A" /><rect x="52" y="105" width="38" height="8" rx="4" fill="#D8E3F6" />
                  <rect x="120" y="92" width="80" height="34" rx="10" fill="#fff" stroke="#E2E9F4" />
                  <circle cx="136" cy="109" r="6" fill="#FF6000" /><rect x="148" y="105" width="38" height="8" rx="4" fill="#D8E3F6" />
                  <rect x="216" y="92" width="80" height="34" rx="10" fill="#fff" stroke="#E2E9F4" />
                  <circle cx="232" cy="109" r="6" fill="#7B3FA0" /><rect x="244" y="105" width="38" height="8" rx="4" fill="#D8E3F6" />
                </svg>
              </div>
            </article>

            <article className="step rv">
              <div className="step__n">3</div>
              <h3 className="h-m">Siparişi bekle</h3>
              <p className="muted small mt-8">Kargoyu tedarikçi atar, tahsilat sana gelir.</p>
              <div className="step__art">
                <svg viewBox="0 0 320 150" width="100%" role="img" aria-label="Sipariş ve kargo görseli">
                  <rect width="320" height="150" rx="14" fill="#F6F8FD" />
                  <rect x="20" y="24" width="280" height="42" rx="12" fill="#fff" stroke="#E2E9F4" />
                  <circle cx="44" cy="45" r="11" fill="#E4F9F3" />
                  <path d="m39 45 4 4 7-8" stroke="#0FBF95" strokeWidth="2.4" fill="none" strokeLinecap="round" />
                  <rect x="64" y="36" width="120" height="8" rx="4" fill="#0A1733" opacity=".78" />
                  <rect x="64" y="50" width="76" height="7" rx="3.5" fill="#D8E3F6" />
                  <rect x="238" y="38" width="46" height="16" rx="8" fill="#E4F9F3" />
                  <rect x="20" y="78" width="280" height="48" rx="12" fill="#0A1733" />
                  <rect x="40" y="94" width="96" height="9" rx="4.5" fill="#fff" opacity=".9" />
                  <rect x="40" y="109" width="60" height="7" rx="3.5" fill="#fff" opacity=".4" />
                  <rect x="222" y="94" width="58" height="22" rx="11" fill="#0FBF95" />
                  <text x="251" y="109" textAnchor="middle" fill="#fff" fontSize="11" fontWeight="700" fontFamily="Inter,Arial">₺ Kâr</text>
                </svg>
              </div>
            </article>
          </div>
        </div>
      </section>

      {/* ============ KANALLAR ============ */}
      <section className="section section--soft">
        <div className="wrap">
          <div className="grid g2" style={{ alignItems: "center", gap: "52px" }}>
            <div className="rv">
              <span className="eyebrow">Entegrasyonlar</span>
              <h2 className="h-xl mt-16">Mağazan neredeyse, Depar orada.</h2>
              <p className="lead mt-16 maxw-44">API anahtarını gir, ürünlerin ve stokların otomatik aksın.</p>
              <div className="channels mt-24">
                <span className="chan chan--ty"><i></i> Trendyol</span>
                <span className="chan chan--hb"><i></i> Hepsiburada</span>
                <span className="chan chan--n11"><i></i> N11</span>
                <span className="chan chan--cs chan--soon"><i></i> Çiçeksepeti <span className="badge">yakında</span></span>
                <span className="chan chan--ptt chan--soon"><i></i> PttAVM <span className="badge">yakında</span></span>
                <span className="chan chan--am chan--soon"><i></i> Amazon TR <span className="badge">yakında</span></span>
              </div>
            </div>
            <div className="card card--pad-lg rv">
              <div className="row-between mb-24">
                <div>
                  <div className="h-s">Stok & fiyat senkronu</div>
                  <div className="tiny muted">Son 24 saat</div>
                </div>
                <span className="badge badge--mint"><span className="dot"></span> Canlı</span>
              </div>
              <div className="bars" aria-hidden="true">
                <i style={{ height: "38%" }}></i><i style={{ height: "52%" }}></i><i style={{ height: "44%" }}></i><i style={{ height: "61%" }}></i>
                <i style={{ height: "72%" }}></i><i style={{ height: "58%" }}></i><i style={{ height: "83%" }}></i><i style={{ height: "96%" }}></i>
              </div>
              <hr className="mt-24" />
              <div className="row-between mt-16">
                <span className="small muted">Güncellenen ürün</span><span className="bold">1.284</span>
              </div>
              <div className="row-between mt-8">
                <span className="small muted">Stoğu biten → kapatılan</span><span className="bold">37</span>
              </div>
              <div className="row-between mt-8">
                <span className="small muted">Hatalı aktarım</span><span className="bold" style={{ color: "#0FBF95" }}>0</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============ NEDEN DEPAR ============ */}
      <section className="section">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">Neden Depar</span>
            <h2 className="h-xl">Riski biz aldık.</h2>
            <p className="lead maxw-44">Satıcının en çok para kaybettiği 6 yeri kapattık.</p>
          </div>
          <div className="grid g3">
            <article className="card card--hover rv">
              <div className="ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M13 2 4.5 13.5H11L10 22l8.5-11.5H12L13 2Z" /></svg></div>
              <h3 className="h-m mt-16">Sıfır sermaye</h3>
              <p className="muted small mt-8">Ürünü satmadan ödeme yapmıyorsun.</p>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--mint"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M20 11a8 8 0 0 0-14-4.5L4 9" /><path d="M4 5v4h4" /><path d="M4 13a8 8 0 0 0 14 4.5L20 15" /><path d="M20 19v-4h-4" /></svg></div>
              <h3 className="h-m mt-16">Stok hatası yok</h3>
              <p className="muted small mt-8">Tedarikçide biten ürün mağazanda da kapanır.</p>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--amber"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h11v10H3z" /><path d="M14 9h4l3 3v4h-7z" /><circle cx="7" cy="18" r="2" /><circle cx="17.5" cy="18" r="2" /></svg></div>
              <h3 className="h-m mt-16">Kargo tedarikçide</h3>
              <p className="muted small mt-8">Paketleme, etiket, gönderi — hepsi onlarda.</p>
            </article>
            <article className="card card--hover rv">
              <div className="ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M3 20h18M6 20v-6M11 20V8M16 20v-9M21 20V5" /></svg></div>
              <h3 className="h-m mt-16">Kâr hesabı hazır</h3>
              <p className="muted small mt-8">Komisyon, kargo, KDV düşülmüş net kâr.</p>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--mint"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8a6 6 0 1 0-12 0c0 6-2 7-2 7h16s-2-1-2-7Z" /><path d="M10.5 20a2 2 0 0 0 3 0" /></svg></div>
              <h3 className="h-m mt-16">Anlık bildirim</h3>
              <p className="muted small mt-8">Sipariş düştüğü an sen ve tedarikçi haberdar.</p>
            </article>
            <article className="card card--hover rv">
              <div className="ico ico--amber"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M12 3 5 6v5.5c0 4.3 3 8 7 9.5 4-1.5 7-5.2 7-9.5V6l-7-3Z" /><path d="m9 12 2 2 4-4" /></svg></div>
              <h3 className="h-m mt-16">Onaylı tedarikçi</h3>
              <p className="muted small mt-8">Vergi levhası ve performans kontrolünden geçer.</p>
            </article>
          </div>
        </div>
      </section>

      {/* ============ SİPARİŞ AKIŞI (KOYU) ============ */}
      <section className="section section--ink">
        <div className="wrap">
          <div className="grid g2" style={{ gap: "56px", alignItems: "center" }}>
            <div className="rv">
              <span className="eyebrow">Sipariş anı</span>
              <h2 className="h-xl mt-16">Sen uyurken çalışır.</h2>
              <p className="lead mt-16 maxw-44">Sipariş düştüğü saniye zincir başlar. Elini sürmene gerek yok.</p>
              <a className="btn btn--white btn--lg mt-24" href="/nasil-calisir">Akışın tamamı</a>
            </div>
            <div className="timeline rv">
              <div className="tl">
                <div className="tl__d tl__d--on"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round"><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3.5 2" /></svg></div>
                <div><div className="h-s">00:00 · Sipariş düştü</div><div className="small muted">Trendyol → Depar</div></div>
              </div>
              <div className="tl">
                <div className="tl__d tl__d--on"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round"><path d="M18 8a6 6 0 1 0-12 0c0 6-2 7-2 7h16s-2-1-2-7Z" /><path d="M10.5 20a2 2 0 0 0 3 0" /></svg></div>
                <div><div className="h-s">00:03 · Çift bildirim</div><div className="small muted">Satıcı + tedarikçi anında haberdar</div></div>
              </div>
              <div className="tl">
                <div className="tl__d tl__d--on"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" /><path d="m4 7.5 8 4.5 8-4.5M12 12v9" /></svg></div>
                <div><div className="h-s">02:10 · Tedarikçi hazırladı</div><div className="small muted">Alıcı adresine, satıcı faturasıyla</div></div>
              </div>
              <div className="tl">
                <div className="tl__d tl__d--ok"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg></div>
                <div><div className="h-s">Kargo çıktı · Kâr yazıldı</div><div className="small muted">Tedarikçi bedeli cari hesabından düşer</div></div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============ KARŞILAŞTIRMA ============ */}
      <section className="section">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">Fark</span>
            <h2 className="h-xl">Aynı satış. Yarısı kadar iş.</h2>
          </div>
          <div className="vs">
            <div className="vs__col vs__col--bad rv">
              <span className="badge">Klasik yöntem</span>
              <h3 className="h-l mt-16">Önce öde, sonra sat</h3>
              <ul className="stack mt-24">
                <li className="bullet bullet--x"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg> Peşin stok yatırımı</li>
                <li className="bullet bullet--x"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg> Depo, paketleme, kargo</li>
                <li className="bullet bullet--x"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg> Excel ile stok takibi</li>
                <li className="bullet bullet--x"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg> Satılmayan ürün = ölü para</li>
              </ul>
            </div>
            <div className="vs__col vs__col--good rv">
              <span className="badge badge--brand">Depar ile</span>
              <h3 className="h-l mt-16">Önce sat, sonra öde</h3>
              <ul className="stack mt-24">
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Sermaye bağlamazsın</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Kargo ve paketleme tedarikçide</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Stok otomatik senkron</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Denemesi bedava, riski yok</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* ============ TEDARİKÇİ ŞERİDİ ============ */}
      <section className="section section--soft">
        <div className="wrap">
          <div className="card card--pad-lg rv" style={{ display: "grid", gridTemplateColumns: "1.2fr 1fr", gap: "40px", alignItems: "center" }}>
            <div>
              <span className="eyebrow">Tedarikçi misin?</span>
              <h2 className="h-l mt-16">Yüzlerce mağaza, tek yükleme.</h2>
              <p className="lead mt-8">Ürünlerini bir kez yükle; onlarca satıcının vitrininde çık. Üyelik ücretsiz.</p>
              <div className="row wrapf mt-24">
                <a className="btn btn--dark" href="/tedarikci">Tedarikçi ol</a>
                <span className="badge badge--mint"><span className="dot"></span> Excel · XML · API ile toplu yükleme</span>
              </div>
            </div>
            <div className="stack">
              <div className="mini"><span className="mini__l"><i style={{ background: "#2F6BFF" }}></i> Excel / CSV</span><span className="tiny muted">5 dk</span></div>
              <div className="mini"><span className="mini__l"><i style={{ background: "#0FBF95" }}></i> XML feed</span><span className="tiny muted">otomatik</span></div>
              <div className="mini"><span className="mini__l"><i style={{ background: "#FFB020" }}></i> API bağlantısı</span><span className="tiny muted">canlı stok</span></div>
              <div className="mini"><span className="mini__l"><i style={{ background: "#7B3FA0" }}></i> Ticimax · İkas · Ideasoft</span><span className="tiny muted">hazır</span></div>
            </div>
          </div>
        </div>
      </section>

      {/* ============ FİYAT ÖZETİ ============ */}
      <section className="section" id="fiyat">
        <div className="wrap">
          <div className="sec-head center rv">
            <span className="eyebrow">Fiyatlandırma</span>
            <h2 className="h-xl">Satıştan komisyon almıyoruz.</h2>
            <p className="lead maxw-44">Sabit aylık ücret. Ne kadar satarsan sat, kâr senin.</p>
          </div>

          <div className="center mb-32">
            <div className="toggle" data-price-toggle="">
              <button className="is-on" data-mode="monthly">Aylık</button>
              <button data-mode="yearly">Yıllık · 2 ay bedava</button>
            </div>
          </div>

          <div className="plans">
            <article className="plan rv">
              <div>
                <h3 className="h-m">Başlangıç</h3>
                <p className="small muted mt-8">İlk satışını yapacaklar için</p>
              </div>
              <div className="price"><b data-monthly="499" data-yearly="415">499</b><span className="price__per" data-per="">₺/ay + KDV</span></div>
              <a className="btn btn--ghost btn--block" href="/giris#kayit">14 gün ücretsiz</a>
              <hr />
              <ul>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 250 aktif ürün</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 1 pazaryeri mağazası</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 500 sipariş/ay</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 4 saatte bir stok senkronu</li>
              </ul>
            </article>

            <article className="plan plan--pop rv">
              <span className="plan__tag badge badge--brand">En çok seçilen</span>
              <div>
                <h3 className="h-m">Profesyonel</h3>
                <p className="small muted mt-8">Büyüyen mağazalar için</p>
              </div>
              <div className="price"><b data-monthly="1.499" data-yearly="1.249">1.499</b><span className="price__per" data-per="">₺/ay + KDV</span></div>
              <a className="btn btn--primary btn--block" href="/giris#kayit">14 gün ücretsiz</a>
              <hr />
              <ul>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 5.000 aktif ürün</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 3 pazaryeri mağazası</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 5.000 sipariş/ay</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 15 dakikada bir senkron</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Otomatik fiyat kuralları</li>
              </ul>
            </article>

            <article className="plan rv">
              <div>
                <h3 className="h-m">Kurumsal</h3>
                <p className="small muted mt-8">Çok kanallı operasyonlar için</p>
              </div>
              <div className="price"><b data-monthly="4.999" data-yearly="4.165">4.999</b><span className="price__per" data-per="">₺/ay + KDV</span></div>
              <a className="btn btn--ghost btn--block" href="/giris#kayit">Görüşme ayarla</a>
              <hr />
              <ul>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Sınırsız ürün</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> Sınırsız mağaza</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 50.000 sipariş/ay</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> 5 dakikada senkron + webhook</li>
                <li className="bullet"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 13 4 4L19 7" /></svg> API erişimi + özel temsilci</li>
              </ul>
            </article>
          </div>

          <p className="center muted small mt-32">Tedarikçi üyeliği her zaman ücretsiz. <a className="bold" style={{ color: "var(--brand)" }} href="/fiyatlandirma">Tüm karşılaştırma →</a></p>
        </div>
      </section>

      {/* ============ SSS ============ */}
      <section className="section section--soft">
        <div className="wrap" style={{ maxWidth: "860px" }}>
          <div className="sec-head center rv">
            <span className="eyebrow">Kısa cevaplar</span>
            <h2 className="h-xl">Aklındaki 5 soru</h2>
          </div>
          <div className="faq rv">
            <div className="faq__item is-open">
              <button className="faq__q" aria-expanded="true">Ürünün parasını ne zaman ödüyorum?
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>Sipariş geldikten sonra. Tedarikçi bedeli cari hesabından düşer, pazaryeri ödemesi sana geldiğinde kapanır.</p></div>
            </div>
            <div className="faq__item">
              <button className="faq__q" aria-expanded="false">Faturayı kim kesiyor?
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>Alıcıya sen keserim; tedarikçi sana keser. Paket alıcıya senin faturanla ve kurumsal kimliğinle gider.</p></div>
            </div>
            <div className="faq__item">
              <button className="faq__q" aria-expanded="false">İade gelirse ne oluyor?
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>İade tedarikçi adresine yönlenir, panelde tek ekrandan takip edilir ve cari hesabına alacak olarak işlenir.</p></div>
            </div>
            <div className="faq__item">
              <button className="faq__q" aria-expanded="false">Şirketim yoksa satış yapabilir miyim?
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>Pazaryerleri şahıs ya da limited şirket ister. Şirket kurulumu için yönlendirme yapıyoruz, Depar'a kaydolman için şart değil.</p></div>
            </div>
            <div className="faq__item">
              <button className="faq__q" aria-expanded="false">İstediğim zaman çıkabilir miyim?
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg></button>
              <div className="faq__a"><p>Evet. Taahhüt yok, tek tıkla iptal. Kalan gün kadar iade yapılır.</p></div>
            </div>
          </div>
        </div>
      </section>

      {/* ============ CTA ============ */}
      <section className="section--tight">
        <div className="wrap">
          <div className="cta-band rv center">
            <h2 className="h-xl">Bugün başla, bu hafta sat.</h2>
            <p className="lead mt-16 mx-auto maxw-44" style={{ color: "#C6D4EC" }}>Kurulum 5 dakika. İlk 14 gün bizden.</p>
            <div className="row wrapf mt-24" style={{ justifyContent: "center" }}>
              <a className="btn btn--white btn--lg" href="/giris#kayit">Ücretsiz hesap aç</a>
              <a className="btn btn--line btn--lg" href="/fiyatlandirma">Fiyatları gör</a>
            </div>
          </div>
        </div>
      </section>

      {/* ============ FOOTER ============ */}
    </>
  );
}
