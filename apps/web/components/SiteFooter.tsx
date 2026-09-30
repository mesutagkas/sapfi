import Link from "next/link";

export default function SiteFooter() {
  return (
    <footer className="footer">
      <div className="wrap">
        <div className="footer__grid">
          <div>
            <Link className="logo logo--light" href="/">
              <img className="logo__mark" src="/logo-mark.svg" alt="" width={36} height={36} />
              <span>depar</span>
            </Link>
            <p className="small mt-16 maxw-44">
              Stoksuz satışta tedarikçiyle satıcıyı tek panelde buluşturur.
            </p>
          </div>
          <div>
            <h4>Ürün</h4>
            <ul className="stack">
              <li><Link href="/nasil-calisir">Nasıl çalışır</Link></li>
              <li><Link href="/fiyatlandirma">Fiyatlandırma</Link></li>
              <li><Link href="/panel">Panel</Link></li>
            </ul>
          </div>
          <div>
            <h4>Tedarikçi</h4>
            <ul className="stack">
              <li><Link href="/tedarikci">Neden Depar</Link></li>
              <li><Link href="/tedarikci#yukleme">Ürün yükleme</Link></li>
              <li><Link href="/giris?mod=kayit">Başvuru</Link></li>
            </ul>
          </div>
          <div>
            <h4>Kurumsal</h4>
            <ul className="stack">
              <li><Link href="/fiyatlandirma">Abonelik</Link></li>
              <li><Link href="/giris">Giriş</Link></li>
              <li><a href="mailto:destek@depar.com.tr">destek@depar.com.tr</a></li>
            </ul>
          </div>
        </div>
        <div className="footer__bottom">
          <span>© {new Date().getFullYear()} Depar Teknoloji A.Ş.</span>
          <span>KVKK · Kullanım Koşulları · Mesafeli Satış</span>
        </div>
      </div>
    </footer>
  );
}
