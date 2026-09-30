/**
 * Başlangıç verisi:  npm run db:seed
 *  - 3 abonelik paketi (docs/06-FIYATLANDIRMA-MANTIGI.md)
 *  - kategori ağacı
 *  - demo tedarikçi + ürünleri, demo satıcı (yalnız development ortamında)
 */
import { PrismaClient } from "@prisma/client";
import { hashPassword, TRIAL_DAYS } from "@depar/shared";

const prisma = new PrismaClient();

async function main() {
  // ---------- Paketler ----------
  const plans = [
    {
      code: "starter", name: "Başlangıç",
      monthlyPrice: 499, yearlyPrice: 4980,
      maxProducts: 250, maxChannels: 1, maxOrdersMonth: 500, maxUsers: 1,
      syncIntervalMin: 240, hasPriceRules: false, hasApi: false,
    },
    {
      code: "pro", name: "Profesyonel",
      monthlyPrice: 1499, yearlyPrice: 14988,
      maxProducts: 5000, maxChannels: 3, maxOrdersMonth: 5000, maxUsers: 3,
      syncIntervalMin: 15, hasPriceRules: true, hasApi: false,
    },
    {
      code: "enterprise", name: "Kurumsal",
      monthlyPrice: 4999, yearlyPrice: 49980,
      maxProducts: null, maxChannels: null, maxOrdersMonth: 50000, maxUsers: 10,
      syncIntervalMin: 5, hasPriceRules: true, hasApi: true,
    },
  ];
  for (const p of plans) {
    await prisma.plan.upsert({ where: { code: p.code }, update: p, create: p });
  }
  console.log(`✓ ${plans.length} paket hazır`);

  // ---------- Kategoriler ----------
  const tree: Array<{ name: string; children: string[] }> = [
    { name: "Elektronik", children: ["Kulaklık", "Giyilebilir Teknoloji", "Şarj & Kablo"] },
    { name: "Ev & Yaşam", children: ["Aydınlatma", "Mutfak"] },
    { name: "Moda & Aksesuar", children: ["Çanta", "Takı"] },
    { name: "Kozmetik", children: ["Cilt Bakımı"] },
  ];
  const catIds = new Map<string, bigint>();
  for (const root of tree) {
    const parent =
      (await prisma.category.findFirst({ where: { path: root.name } })) ??
      (await prisma.category.create({ data: { name: root.name, path: root.name } }));
    catIds.set(root.name, parent.id);

    for (const child of root.children) {
      const path = `${root.name} > ${child}`;
      const cat =
        (await prisma.category.findFirst({ where: { path } })) ??
        (await prisma.category.create({ data: { name: child, path, parentId: parent.id } }));
      catIds.set(path, cat.id);
    }
  }
  console.log(`✓ ${catIds.size} kategori hazır`);

  if (process.env.NODE_ENV === "production") {
    console.log("Üretim ortamı: demo veri atlandı.");
    return;
  }

  // ---------- Demo tedarikçi ----------
  const pass = await hashPassword("Depar1234!");

  const supplier = await prisma.tenant.upsert({
    where: { slug: "anka-elektronik" },
    update: {},
    create: {
      kind: "supplier", status: "active", slug: "anka-elektronik",
      companyName: "Anka Elektronik Ltd. Şti.",
      taxOffice: "Kadıköy", taxNumber: "1234567890",
      email: "tedarik@anka.example", phone: "02161112233",
      address: { il: "İstanbul", ilce: "Kadıköy", adres: "Örnek Mah. 1. Sk. No:1" },
      avgShipDays: 0.8, cancelRate: 0.4, stockAccuracy: 99.2,
      approvedAt: new Date(),
      users: {
        create: {
          email: "tedarikci@depar.test", passwordHash: pass,
          fullName: "Anka Tedarik", role: "supplier", isOwner: true,
        },
      },
    },
  });

  const demoProducts = [
    { sku: "ANK-KLK-001", title: "Kablosuz Kulaklık Pro", cat: "Elektronik > Kulaklık",
      barcode: "8680000000011", supply: 410, msrp: 749, stock: 412 },
    { sku: "ANK-SAT-002", title: "Akıllı Saat S2", cat: "Elektronik > Giyilebilir Teknoloji",
      barcode: "8680000000028", supply: 1180, msrp: 1999, stock: 87 },
    { sku: "ANK-PWB-003", title: "Powerbank 20.000mAh", cat: "Elektronik > Şarj & Kablo",
      barcode: "8680000000035", supply: 320, msrp: 599, stock: 0 },
    { sku: "ANK-LMB-004", title: "Masaüstü LED Lamba", cat: "Ev & Yaşam > Aydınlatma",
      barcode: "8680000000042", supply: 240, msrp: 449, stock: 168 },
  ];

  for (const p of demoProducts) {
    await prisma.product.upsert({
      where: { supplierId_sku: { supplierId: supplier.id, sku: p.sku } },
      update: {},
      create: {
        supplierId: supplier.id,
        categoryId: catIds.get(p.cat),
        sku: p.sku,
        title: p.title,
        description: `${p.title} — demo katalog kaydı.`,
        brand: "Anka",
        source: "manual",
        variants: {
          create: {
            variantSku: `${p.sku}-STD`,
            barcode: p.barcode,
            supplyPrice: p.supply,
            msrp: p.msrp,
            stock: p.stock,
            desi: 1,
            shipDays: 1,
          },
        },
      },
    });
  }
  console.log(`✓ demo tedarikçi + ${demoProducts.length} ürün`);

  // ---------- Demo satıcı ----------
  const now = new Date();
  const trialEnd = new Date(now.getTime() + TRIAL_DAYS * 86400_000);

  const seller = await prisma.tenant.upsert({
    where: { slug: "markus-store" },
    update: {},
    create: {
      kind: "seller", status: "active", slug: "markus-store",
      companyName: "Markus Ticaret Ltd. Şti.",
      email: "satici@depar.test", phone: "05001112233",
      address: { il: "İstanbul", ilce: "Şişli" },
      approvedAt: now,
      users: {
        create: {
          email: "satici@depar.test", passwordHash: pass,
          fullName: "Markus Yılmaz", role: "seller", isOwner: true,
        },
      },
    },
  });

  const hasSub = await prisma.subscription.findFirst({ where: { tenantId: seller.id } });
  if (!hasSub) {
    await prisma.subscription.create({
      data: {
        tenantId: seller.id, planCode: "pro", status: "trialing",
        trialEndsAt: trialEnd, currentStart: now, currentEnd: trialEnd,
      },
    });
  }
  console.log("✓ demo satıcı (satici@depar.test / Depar1234!)");
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
