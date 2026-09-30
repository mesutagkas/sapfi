"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";

const LINKS = [
  { href: "/nasil-calisir", label: "Nasıl çalışır" },
  { href: "/tedarikci", label: "Tedarikçiler" },
  { href: "/fiyatlandirma", label: "Fiyatlar" },
  { href: "/panel", label: "Panel" },
];

export default function SiteHeader() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [stuck, setStuck] = useState(false);

  useEffect(() => {
    const onScroll = () => setStuck(window.scrollY > 8);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => setOpen(false), [pathname]);

  return (
    <header className={`nav${stuck ? " is-stuck" : ""}${open ? " is-open" : ""}`}>
      <div className="wrap nav__in">
        <Link className="logo" href="/" aria-label="Depar ana sayfa">
          <img className="logo__mark" src="/logo-mark.svg" alt="" width={36} height={36} />
          <span>depar</span>
        </Link>

        <nav className="nav__links">
          {LINKS.map((l) => (
            <Link key={l.href} href={l.href} className={pathname === l.href ? "is-active" : undefined}>
              {l.label}
            </Link>
          ))}
        </nav>

        <div className="nav__cta">
          <Link className="btn btn--ghost btn--sm" href="/giris">Giriş yap</Link>
          <Link className="btn btn--primary btn--sm" href="/giris?mod=kayit">Ücretsiz başla</Link>
          <button
            className="nav__burger"
            aria-label="Menü"
            aria-expanded={open}
            onClick={() => setOpen((v) => !v)}
          >
            <span />
          </button>
        </div>
      </div>
    </header>
  );
}
