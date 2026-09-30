import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import AuthForm from "@/components/AuthForm";
import { getSession } from "@/lib/session";

export const metadata: Metadata = { title: "Giriş / Kayıt" };

export default async function GirisPage({
  searchParams,
}: {
  searchParams: Promise<{ mod?: string; next?: string }>;
}) {
  const params = await searchParams;
  const session = await getSession();
  if (session) redirect("/panel");

  const mode = params.mod === "kayit" ? "kayit" : "giris";
  const next = params.next?.startsWith("/") ? params.next : "/panel";

  return (
    <div className="auth">
      <aside className="auth__side">
        <Link className="logo logo--light" href="/" style={{ position: "relative", zIndex: 1 }}>
          <img className="logo__mark" src="/logo-mark.svg" alt="" width={36} height={36} />
          <span>depar</span>
        </Link>

        <div style={{ position: "relative", zIndex: 1, marginTop: "auto" }}>
          <h2 className="h-xl">
            Stok tutma.
            <br />
            Kargolama.
            <br />
            Sadece sat.
          </h2>
          <p className="lead mt-16 maxw-44" style={{ color: "#C6D4EC" }}>
            14 gün ücretsiz. Kart istemiyoruz.
          </p>
          <ul className="stack mt-32">
            {["18.000+ hazır ürün", "Trendyol · Hepsiburada · N11", "Satıştan %0 komisyon"].map((t) => (
              <li className="bullet" style={{ color: "#fff" }} key={t}>
                <svg viewBox="0 0 24 24" fill="none" stroke="#4FE3BE" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="m5 13 4 4L19 7" />
                </svg>
                {t}
              </li>
            ))}
          </ul>
        </div>

        <div className="tiny" style={{ position: "relative", zIndex: 1, color: "#8FA3C6" }}>
          © {new Date().getFullYear()} Depar Teknoloji A.Ş.
        </div>
      </aside>

      <main className="auth__form">
        <div style={{ width: "100%", maxWidth: 410 }}>
          <AuthForm initialMode={mode} next={next} />
          <p className="center tiny muted mt-32">
            <Link href="/">← Siteye dön</Link>
          </p>
        </div>
      </main>
    </div>
  );
}
