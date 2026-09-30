import Link from "next/link";
import SiteHeader from "@/components/SiteHeader";
import SiteFooter from "@/components/SiteFooter";

export default function NotFound() {
  return (
    <>
      <SiteHeader />
      <main className="section center">
        <div className="wrap">
          <span className="eyebrow">404</span>
          <h1 className="h-xl mt-16">Bu sayfa vitrinde yok.</h1>
          <p className="lead mt-16 mx-auto maxw-44">Aradığın sayfa taşınmış ya da hiç var olmamış olabilir.</p>
          <div className="row wrapf mt-32" style={{ justifyContent: "center" }}>
            <Link className="btn btn--primary btn--lg" href="/">Ana sayfa</Link>
            <Link className="btn btn--ghost btn--lg" href="/panel">Panele git</Link>
          </div>
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
