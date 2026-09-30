"use client";

import { useEffect } from "react";

/**
 * Pazarlama sayfalarındaki statik işaretlemenin davranış katmanı
 * (görünüme girince animasyon, sayaç, SSS akordiyonu, fiyat değiştirici).
 *
 * Bu sayfalar tasarımdan birebir taşındığı için davranış tek yerde, DOM üzerinden
 * yönetiliyor. Durum taşıyan gerçek ürün ekranları (panel, giriş) normal React
 * bileşenleridir — oraya bu dosyadan hiçbir şey dokunmaz.
 */
export default function SiteInteractions() {
  useEffect(() => {
    const cleanups: Array<() => void> = [];

    // --- görünüme girince animasyon ---
    const revealables = document.querySelectorAll<HTMLElement>(".rv:not(.is-in)");
    if (revealables.length) {
      const io = new IntersectionObserver(
        (entries) => {
          entries.forEach((e) => {
            if (e.isIntersecting) {
              e.target.classList.add("is-in");
              io.unobserve(e.target);
            }
          });
        },
        { rootMargin: "0px 0px -8% 0px", threshold: 0.08 },
      );
      revealables.forEach((el, i) => {
        el.style.transitionDelay = `${(i % 4) * 70}ms`;
        io.observe(el);
      });
      cleanups.push(() => io.disconnect());
    }

    // --- sayaçlar ---
    const counters = document.querySelectorAll<HTMLElement>("[data-count]");
    if (counters.length) {
      const cio = new IntersectionObserver(
        (entries) => {
          entries.forEach((e) => {
            if (!e.isIntersecting) return;
            cio.unobserve(e.target);
            const el = e.target as HTMLElement;
            const end = Number(el.dataset.count ?? 0);
            const t0 = performance.now();
            const tick = (t: number) => {
              const p = Math.min(1, (t - t0) / 1100);
              el.textContent = Math.floor(end * (1 - (1 - p) ** 3)).toLocaleString("tr-TR");
              if (p < 1) requestAnimationFrame(tick);
              else el.textContent = end.toLocaleString("tr-TR");
            };
            requestAnimationFrame(tick);
          });
        },
        { threshold: 0.4 },
      );
      counters.forEach((c) => cio.observe(c));
      cleanups.push(() => cio.disconnect());
    }

    // --- SSS akordiyonu ---
    const onFaq = (ev: Event) => {
      const q = (ev.target as HTMLElement).closest<HTMLElement>(".faq__q");
      if (!q) return;
      const item = q.closest(".faq__item");
      const wasOpen = item?.classList.contains("is-open");
      item?.parentElement?.querySelectorAll(".faq__item").forEach((i) => {
        i.classList.remove("is-open");
        i.querySelector(".faq__q")?.setAttribute("aria-expanded", "false");
      });
      if (!wasOpen) {
        item?.classList.add("is-open");
        q.setAttribute("aria-expanded", "true");
      }
    };
    document.addEventListener("click", onFaq);
    cleanups.push(() => document.removeEventListener("click", onFaq));

    // --- aylık / yıllık fiyat değiştirici ---
    const onPrice = (ev: Event) => {
      const btn = (ev.target as HTMLElement).closest<HTMLElement>("[data-price-toggle] button");
      if (!btn) return;
      const group = btn.closest("[data-price-toggle]")!;
      const yearly = btn.dataset.mode === "yearly";
      group.querySelectorAll("button").forEach((b) => b.classList.remove("is-on"));
      btn.classList.add("is-on");
      document.querySelectorAll<HTMLElement>("[data-monthly]").forEach((el) => {
        el.textContent = (yearly ? el.dataset.yearly : el.dataset.monthly) ?? "";
      });
      document.querySelectorAll<HTMLElement>("[data-per]").forEach((el) => {
        el.textContent = yearly ? "₺/ay · yıllık ödemede" : "₺/ay + KDV";
      });
      document.querySelectorAll<HTMLElement>("[data-save]").forEach((el) => {
        el.classList.toggle("hide", !yearly);
      });
    };
    document.addEventListener("click", onPrice);
    cleanups.push(() => document.removeEventListener("click", onPrice));

    return () => cleanups.forEach((fn) => fn());
  }, []);

  return null;
}
