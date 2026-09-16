/* Depar — arayüz etkileşimleri (bağımlılık yok) */
(function () {
  "use strict";

  /* --- 1. Mobil menü + yapışkan başlık --- */
  var nav = document.querySelector(".nav");
  var burger = document.querySelector(".nav__burger");
  if (burger && nav) {
    burger.addEventListener("click", function () {
      nav.classList.toggle("is-open");
      burger.setAttribute("aria-expanded", nav.classList.contains("is-open"));
    });
  }
  if (nav) {
    var onScroll = function () {
      nav.classList.toggle("is-stuck", window.scrollY > 8);
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
  }

  /* --- 2. Aktif menü bağlantısı --- */
  var here = location.pathname.split("/").pop() || "index.html";
  document.querySelectorAll(".nav__links a").forEach(function (a) {
    var href = (a.getAttribute("href") || "").split("#")[0];
    if (href && href === here) a.classList.add("is-active");
  });

  /* --- 3. Görünüme girince animasyon --- */
  var rv = document.querySelectorAll(".rv");
  if (rv.length && "IntersectionObserver" in window) {
    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (e) {
          if (e.isIntersecting) {
            e.target.classList.add("is-in");
            io.unobserve(e.target);
          }
        });
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.08 }
    );
    rv.forEach(function (el, i) {
      el.style.transitionDelay = (i % 4) * 70 + "ms";
      io.observe(el);
    });
  } else {
    rv.forEach(function (el) { el.classList.add("is-in"); });
  }

  /* --- 4. Sayaç animasyonu --- */
  var counters = document.querySelectorAll("[data-count]");
  if (counters.length && "IntersectionObserver" in window) {
    var cio = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (!e.isIntersecting) return;
        cio.unobserve(e.target);
        var el = e.target;
        var end = parseFloat(el.getAttribute("data-count"));
        var suffix = el.getAttribute("data-suffix") || "";
        var dur = 1100, t0 = performance.now();
        (function tick(t) {
          var p = Math.min(1, (t - t0) / dur);
          var v = Math.floor(end * (1 - Math.pow(1 - p, 3)));
          el.textContent = v.toLocaleString("tr-TR") + suffix;
          if (p < 1) requestAnimationFrame(tick);
          else el.textContent = end.toLocaleString("tr-TR") + suffix;
        })(t0);
      });
    }, { threshold: 0.4 });
    counters.forEach(function (c) { cio.observe(c); });
  }

  /* --- 5. SSS akordiyonu --- */
  document.querySelectorAll(".faq__q").forEach(function (q) {
    q.addEventListener("click", function () {
      var item = q.closest(".faq__item");
      var open = item.classList.contains("is-open");
      item.parentElement.querySelectorAll(".faq__item").forEach(function (i) {
        i.classList.remove("is-open");
        i.querySelector(".faq__q").setAttribute("aria-expanded", "false");
      });
      if (!open) {
        item.classList.add("is-open");
        q.setAttribute("aria-expanded", "true");
      }
    });
  });

  /* --- 6. Aylık / yıllık fiyat değişimi --- */
  var toggle = document.querySelector("[data-price-toggle]");
  if (toggle) {
    toggle.querySelectorAll("button").forEach(function (b) {
      b.addEventListener("click", function () {
        var mode = b.getAttribute("data-mode"); // monthly | yearly
        toggle.querySelectorAll("button").forEach(function (x) { x.classList.remove("is-on"); });
        b.classList.add("is-on");
        document.querySelectorAll("[data-monthly]").forEach(function (el) {
          var val = el.getAttribute(mode === "yearly" ? "data-yearly" : "data-monthly");
          el.textContent = val;
        });
        document.querySelectorAll("[data-per]").forEach(function (el) {
          el.textContent = mode === "yearly" ? "₺/ay · yıllık ödemede" : "₺/ay + KDV";
        });
        document.querySelectorAll("[data-save]").forEach(function (el) {
          el.classList.toggle("hide", mode !== "yearly");
        });
      });
    });
  }

  /* --- 7. Panel: sekmeler --- */
  document.querySelectorAll("[data-tabs]").forEach(function (group) {
    group.querySelectorAll("button[data-tab]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var key = btn.getAttribute("data-tab");
        group.querySelectorAll("button[data-tab]").forEach(function (b) { b.classList.remove("is-on"); });
        btn.classList.add("is-on");
        var scope = group.getAttribute("data-tabs");
        document.querySelectorAll('[data-panel="' + scope + '"]').forEach(function (p) {
          p.classList.toggle("hide", p.getAttribute("data-key") !== key);
        });
      });
    });
  });

  /* --- 8. Panel: rol değiştirici (satıcı / tedarikçi) --- */
  var roleSwitch = document.querySelector("[data-role-switch]");
  if (roleSwitch) {
    roleSwitch.querySelectorAll("button").forEach(function (b) {
      b.addEventListener("click", function () {
        var role = b.getAttribute("data-role");
        roleSwitch.querySelectorAll("button").forEach(function (x) { x.classList.remove("is-on"); });
        b.classList.add("is-on");
        document.querySelectorAll("[data-role-view]").forEach(function (v) {
          v.classList.toggle("hide", v.getAttribute("data-role-view") !== role);
        });
      });
    });
  }

  /* --- 9. Panel: "Mağazama aktar" demo davranışı --- */
  document.querySelectorAll("[data-push]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      if (btn.dataset.done === "1") return;
      btn.dataset.done = "1";
      var old = btn.innerHTML;
      btn.innerHTML = "Aktarılıyor…";
      btn.classList.add("btn--line");
      setTimeout(function () {
        btn.innerHTML = "✓ Mağazada";
        btn.classList.remove("btn--primary", "btn--line");
        btn.classList.add("btn--mint");
        toast("Ürün Trendyol mağazana aktarıldı (demo)");
      }, 900);
      void old;
    });
  });

  /* --- 10. Basit bildirim --- */
  function toast(msg) {
    var t = document.createElement("div");
    t.textContent = msg;
    t.style.cssText =
      "position:fixed;left:50%;bottom:26px;transform:translateX(-50%) translateY(14px);" +
      "background:#0A1733;color:#fff;padding:13px 20px;border-radius:12px;font-size:.92rem;font-weight:600;" +
      "box-shadow:0 20px 40px -18px rgba(10,23,51,.9);opacity:0;transition:all .25s ease;z-index:999";
    document.body.appendChild(t);
    requestAnimationFrame(function () {
      t.style.opacity = "1";
      t.style.transform = "translateX(-50%) translateY(0)";
    });
    setTimeout(function () {
      t.style.opacity = "0";
      t.style.transform = "translateX(-50%) translateY(14px)";
      setTimeout(function () { t.remove(); }, 300);
    }, 2400);
  }
  window.deparToast = toast;

  /* --- 11. Demo formlar --- */
  document.querySelectorAll("form[data-demo]").forEach(function (f) {
    f.addEventListener("submit", function (e) {
      e.preventDefault();
      toast("Demo arayüz — backend bağlandığında burası gerçek kayıt olacak.");
    });
  });
})();
