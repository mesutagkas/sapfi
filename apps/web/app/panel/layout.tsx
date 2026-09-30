import Link from "next/link";
import { redirect } from "next/navigation";
import LogoutButton from "@/components/LogoutButton";
import { getSession } from "@/lib/session";

const NAV_SELLER = [
  { label: "Genel bakış", href: "/panel", ready: true },
  { label: "Katalog", href: "/panel", ready: false },
  { label: "Siparişler", href: "/panel", ready: false },
  { label: "Mağazalarım", href: "/panel", ready: false },
  { label: "Cari & ödemeler", href: "/panel", ready: false },
];

const NAV_SUPPLIER = [
  { label: "Genel bakış", href: "/panel", ready: true },
  { label: "Ürünlerim", href: "/panel", ready: false },
  { label: "Gelen siparişler", href: "/panel", ready: false },
  { label: "Stok kaynağı", href: "/panel", ready: false },
];

export default async function PanelLayout({ children }: { children: React.ReactNode }) {
  const session = await getSession();
  if (!session) redirect("/giris?next=/panel");

  const isSupplier = session.tenant?.kind === "supplier";
  const nav = isSupplier ? NAV_SUPPLIER : NAV_SELLER;
  const initials = session.fullName
    .split(" ")
    .map((p) => p[0])
    .slice(0, 2)
    .join("")
    .toUpperCase();

  return (
    <div className="app">
      <aside className="side">
        <Link className="logo logo--light" href="/">
          <img className="logo__mark" src="/logo-mark.svg" alt="" width={36} height={36} />
          <span>depar</span>
        </Link>

        <nav className="side__nav">
          {nav.map((item, i) => (
            <Link
              key={item.label}
              href={item.href}
              className={i === 0 ? "is-active" : undefined}
              style={item.ready ? undefined : { opacity: 0.55 }}
            >
              {item.label}
              {!item.ready && <span className="badge" style={{ marginLeft: "auto" }}>yakında</span>}
            </Link>
          ))}
        </nav>

        <div className="side__foot">
          {session.subscription && (
            <div className="card card--glass" style={{ padding: 14, borderRadius: 14 }}>
              <div className="h-s" style={{ color: "#fff" }}>{session.subscription.planName} paket</div>
              <div className="tiny" style={{ color: "#9DB2D6" }}>
                {session.subscription.status === "trialing"
                  ? `Deneme · ${session.subscription.daysLeft} gün kaldı`
                  : `Yenileme: ${new Date(session.subscription.currentEnd).toLocaleDateString("tr-TR")}`}
              </div>
            </div>
          )}
          <Link className="tiny mt-16" style={{ display: "block", color: "#8FA3C6" }} href="/">
            ← Siteye dön
          </Link>
        </div>
      </aside>

      <div>
        <div className="topbar">
          <div className="row" style={{ gap: 12 }}>
            <span className="badge badge--brand">
              {isSupplier ? "Tedarikçi paneli" : "Satıcı paneli"}
            </span>
            <span className="small muted">{session.tenant?.companyName}</span>
          </div>
          <div className="row" style={{ gap: 12 }}>
            <div className="avatar" title={session.email}>{initials}</div>
            <LogoutButton />
          </div>
        </div>
        {children}
      </div>
    </div>
  );
}
