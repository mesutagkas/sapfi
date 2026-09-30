import type { Metadata } from "next";
import Link from "next/link";
import { apiFetch } from "@/lib/api";
import { getAccessToken, getSession } from "@/lib/session";

export const metadata: Metadata = { title: "Panel" };

interface Summary {
  kind: string;
  channels?: number;
  listings?: number;
  orders?: number;
  products?: number;
  variants?: number;
  orderItems?: number;
}

export default async function PanelPage() {
  const session = await getSession();
  const token = await getAccessToken();
  const res = await apiFetch<Summary>("/v1/tenant/summary", { token: token ?? undefined });
  const summary = res.ok ? res.data : null;
  const isSupplier = session?.tenant?.kind === "supplier";

  const kpis = isSupplier
    ? [
        { label: "Yüklü ürün", value: summary?.products ?? 0 },
        { label: "Varyant", value: summary?.variants ?? 0 },
        { label: "Gelen sipariş", value: summary?.orderItems ?? 0 },
        { label: "Aktif satıcı", value: 0 },
      ]
    : [
        { label: "Bağlı mağaza", value: summary?.channels ?? 0 },
        { label: "Aktif ilan", value: summary?.listings ?? 0 },
        { label: "Sipariş", value: summary?.orders ?? 0 },
        { label: "Net kâr (₺)", value: 0 },
      ];

  const steps = isSupplier
    ? [
        { n: 1, title: "Belgelerini yükle", body: "Vergi levhası ve imza sirküleri onaydan geçsin.", tag: "Faz 2" },
        { n: 2, title: "Ürünlerini yükle", body: "Excel, XML feed veya API ile toplu aktarım.", tag: "Faz 2" },
        { n: 3, title: "Siparişleri karşıla", body: "Sipariş düştükçe kargo etiketin panelde oluşsun.", tag: "Faz 3" },
      ]
    : [
        { n: 1, title: "Mağazanı bağla", body: "Trendyol, Hepsiburada veya N11 API anahtarını gir.", tag: "Faz 3" },
        { n: 2, title: "Katalogdan ürün seç", body: "Kârını gör, tek tıkla mağazana aktar.", tag: "Faz 2" },
        { n: 3, title: "Siparişini bekle", body: "Sipariş geldiğinde tedarikçine otomatik iletilsin.", tag: "Faz 3" },
      ];

  return (
    <main className="main">
      <div className="row-between mb-24 wrapf">
        <div>
          <h1 className="h-l">Merhaba {session?.fullName.split(" ")[0]} 👋</h1>
          <p className="muted small">
            {session?.tenant?.status === "pending"
              ? "Hesabın onay bekliyor. Belgelerin incelendikten sonra katalog açılacak."
              : "Hesabın hazır. Kurulumu tamamlamak için aşağıdaki adımları izle."}
          </p>
        </div>
        {session?.subscription?.status === "trialing" && (
          <span className="badge badge--mint">
            <span className="dot" /> Deneme · {session.subscription.daysLeft} gün kaldı
          </span>
        )}
      </div>

      {!res.ok && (
        <div className="panelbox mb-24" style={{ borderColor: "#F3C3BB" }}>
          <div className="panelbox__h">
            <span className="h-s" style={{ color: "#c0341f" }}>Özet verisi alınamadı</span>
            <span className="badge badge--danger">API</span>
          </div>
          <div style={{ padding: 16 }} className="small muted">
            {Array.isArray(res.error.message) ? res.error.message[0] : res.error.message}
          </div>
        </div>
      )}

      <div className="kpi mb-24">
        {kpis.map((k) => (
          <div className="kpi__card" key={k.label}>
            <span className="tiny muted">{k.label}</span>
            <b>{k.value.toLocaleString("tr-TR")}</b>
            <span className="tiny muted">henüz veri yok</span>
          </div>
        ))}
      </div>

      <div className="panelbox mb-24">
        <div className="panelbox__h">
          <span className="h-s">Kuruluma devam et</span>
          <span className="badge">{isSupplier ? "Tedarikçi" : "Satıcı"} kurulumu</span>
        </div>
        <div style={{ padding: 16, display: "flex", flexDirection: "column", gap: 12 }}>
          {steps.map((s) => (
            <div className="mini" key={s.n}>
              <span className="mini__l">
                <span className="step__n" style={{ width: 28, height: 28, borderRadius: 9, marginBottom: 0, fontSize: ".82rem" }}>
                  {s.n}
                </span>
                <span>
                  <span className="h-s">{s.title}</span>
                  <br />
                  <span className="tiny muted">{s.body}</span>
                </span>
              </span>
              <span className="badge badge--amber">{s.tag}</span>
            </div>
          ))}
        </div>
      </div>

      <div className="grid g2" style={{ gap: 16 }}>
        <div className="panelbox">
          <div className="panelbox__h"><span className="h-s">Hesap</span></div>
          <div style={{ padding: 16 }} className="stack">
            <div className="row-between"><span className="small muted">Firma</span><span className="bold">{session?.tenant?.companyName}</span></div>
            <div className="row-between"><span className="small muted">E-posta</span><span className="bold">{session?.email}</span></div>
            <div className="row-between"><span className="small muted">Rol</span><span className="bold">{isSupplier ? "Tedarikçi" : "Satıcı"}</span></div>
            <div className="row-between">
              <span className="small muted">Durum</span>
              <span className={`badge ${session?.tenant?.status === "active" ? "badge--mint" : "badge--amber"}`}>
                <span className="dot" /> {session?.tenant?.status === "active" ? "Aktif" : "Onay bekliyor"}
              </span>
            </div>
          </div>
        </div>

        <div className="panelbox">
          <div className="panelbox__h"><span className="h-s">Abonelik</span></div>
          <div style={{ padding: 16 }} className="stack">
            {session?.subscription ? (
              <>
                <div className="row-between"><span className="small muted">Paket</span><span className="bold">{session.subscription.planName}</span></div>
                <div className="row-between"><span className="small muted">Durum</span><span className="bold">{session.subscription.status === "trialing" ? "Deneme" : session.subscription.status}</span></div>
                <div className="row-between"><span className="small muted">Bitiş</span><span className="bold">{new Date(session.subscription.currentEnd).toLocaleDateString("tr-TR")}</span></div>
                <Link className="btn btn--ghost btn--sm mt-8" href="/fiyatlandirma">Paketleri gör</Link>
              </>
            ) : (
              <p className="small muted">Tedarikçi hesaplarında abonelik ücreti yoktur.</p>
            )}
          </div>
        </div>
      </div>
    </main>
  );
}
