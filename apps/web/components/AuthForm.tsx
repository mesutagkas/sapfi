"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

type Mode = "giris" | "kayit";
type Role = "seller" | "supplier";

export default function AuthForm({ initialMode, next }: { initialMode: Mode; next: string }) {
  const router = useRouter();
  const [mode, setMode] = useState<Mode>(initialMode);
  const [role, setRole] = useState<Role>("seller");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    setBusy(true);

    const form = new FormData(e.currentTarget);
    const payload = Object.fromEntries(form.entries());

    try {
      const res = await fetch(`/api/auth/${mode === "giris" ? "login" : "register"}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(mode === "giris" ? payload : { ...payload, role }),
      });
      const body = await res.json().catch(() => ({}));

      if (!res.ok) {
        setError(body.message ?? "İşlem tamamlanamadı, tekrar dene.");
        return;
      }
      router.push(next);
      router.refresh();
    } catch {
      setError("Bağlantı kurulamadı. İnternetini ve API servisini kontrol et.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="auth__form-in">
      <div className="tabs mb-32">
        <button type="button" className={mode === "giris" ? "is-on" : ""} style={{ flex: 1 }} onClick={() => setMode("giris")}>
          Giriş yap
        </button>
        <button type="button" className={mode === "kayit" ? "is-on" : ""} style={{ flex: 1 }} onClick={() => setMode("kayit")}>
          Hesap aç
        </button>
      </div>

      <h1 className="h-l">{mode === "giris" ? "Tekrar hoş geldin" : "14 gün ücretsiz"}</h1>
      <p className="muted small mt-8 mb-24">
        {mode === "giris"
          ? "Panelden kaldığın yerden devam et."
          : "Kart bilgisi istemiyoruz, istediğin an bırak."}
      </p>

      {mode === "kayit" && (
        <div className="segment mb-24">
          <label>
            <input type="radio" name="rol" checked={role === "seller"} onChange={() => setRole("seller")} />
            <span className="ico ico--sm" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 9h16v11H4z" />
                <path d="M3 9l1.5-5h15L21 9a3 3 0 0 1-6 0 3 3 0 0 1-6 0 3 3 0 0 1-6 0Z" />
              </svg>
            </span>
            <span className="segment__b">
              <span className="h-s">Satıcıyım</span>
              <br />
              <span className="tiny muted">Pazaryerinde satarım</span>
            </span>
          </label>
          <label>
            <input type="radio" name="rol" checked={role === "supplier"} onChange={() => setRole("supplier")} />
            <span className="ico ico--sm ico--mint" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
                <path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" />
                <path d="m4 7.5 8 4.5 8-4.5M12 12v9" />
              </svg>
            </span>
            <span className="segment__b">
              <span className="h-s">Tedarikçiyim</span>
              <br />
              <span className="tiny muted">Ürün sağlarım</span>
            </span>
          </label>
        </div>
      )}

      {error && (
        <div className="card" style={{ padding: "12px 14px", borderColor: "#F3C3BB", background: "#FEECE9", marginBottom: 16 }}>
          <span className="small bold" style={{ color: "#c0341f" }}>{error}</span>
        </div>
      )}

      <form className="stack" onSubmit={submit}>
        {mode === "kayit" && (
          <>
            <div className="grid g2" style={{ gap: 12 }}>
              <div className="field">
                <label htmlFor="fullName">Ad soyad</label>
                <input id="fullName" name="fullName" type="text" placeholder="Markus Yılmaz" required minLength={2} />
              </div>
              <div className="field">
                <label htmlFor="phone">Telefon</label>
                <input id="phone" name="phone" type="tel" placeholder="05xx xxx xx xx" />
              </div>
            </div>
            <div className="field">
              <label htmlFor="companyName">Firma ünvanı</label>
              <input id="companyName" name="companyName" type="text" placeholder="Örnek Ticaret Ltd. Şti." required minLength={2} />
            </div>
          </>
        )}

        <div className="field">
          <label htmlFor="email">E-posta</label>
          <input id="email" name="email" type="email" placeholder="ornek@sirket.com" required autoComplete="email" />
        </div>

        <div className="field">
          <label htmlFor="password">Şifre</label>
          <input
            id="password"
            name="password"
            type="password"
            placeholder={mode === "kayit" ? "En az 8 karakter, harf ve rakam" : "••••••••"}
            required
            minLength={mode === "kayit" ? 8 : 1}
            autoComplete={mode === "kayit" ? "new-password" : "current-password"}
          />
        </div>

        {mode === "kayit" && (
          <label className="row tiny mt-8" style={{ gap: 8, alignItems: "flex-start" }}>
            <input type="checkbox" required style={{ marginTop: 3 }} />
            <span className="muted">Kullanım koşullarını ve KVKK aydınlatma metnini okudum, onaylıyorum.</span>
          </label>
        )}

        <button className="btn btn--primary btn--block btn--lg mt-8" type="submit" disabled={busy}>
          {busy ? "Gönderiliyor…" : mode === "giris" ? "Giriş yap" : "Ücretsiz hesabımı aç"}
        </button>
      </form>

      <p className="center small muted mt-24">
        {mode === "giris" ? (
          <>Hesabın yok mu? <button type="button" className="bold" style={linkBtn} onClick={() => setMode("kayit")}>Ücretsiz aç</button></>
        ) : (
          <>Zaten üye misin? <button type="button" className="bold" style={linkBtn} onClick={() => setMode("giris")}>Giriş yap</button></>
        )}
      </p>
    </div>
  );
}

const linkBtn: React.CSSProperties = {
  background: "none",
  border: 0,
  padding: 0,
  color: "var(--brand)",
  cursor: "pointer",
  font: "inherit",
  fontWeight: 700,
};
