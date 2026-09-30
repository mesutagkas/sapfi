"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

export default function LogoutButton() {
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  return (
    <button
      className="btn btn--ghost btn--sm"
      disabled={busy}
      onClick={async () => {
        setBusy(true);
        await fetch("/api/auth/logout", { method: "POST" });
        router.push("/giris");
        router.refresh();
      }}
    >
      {busy ? "Çıkılıyor…" : "Çıkış"}
    </button>
  );
}
