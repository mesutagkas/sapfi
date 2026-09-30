import { ForbiddenException, Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class TenantsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Çok kiracılılık kuralı: her okuma/yazma, oturumdaki tenantId ile sınırlanır.
   * Kaynağın kimliği istekten gelse bile sahiplik burada tekrar doğrulanır.
   */
  async findMine(tenantId: string | null) {
    if (!tenantId) throw new ForbiddenException("Bu hesaba bağlı bir firma yok.");

    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      include: {
        users: { select: { id: true, email: true, fullName: true, role: true, isOwner: true, lastLoginAt: true } },
        subscriptions: { orderBy: { createdAt: "desc" }, take: 1, include: { plan: true } },
      },
    });
    if (!tenant) throw new NotFoundException("Firma bulunamadı.");

    const sub = tenant.subscriptions[0];
    return {
      id: tenant.id,
      kind: tenant.kind,
      status: tenant.status,
      companyName: tenant.companyName,
      taxOffice: tenant.taxOffice,
      taxNumber: tenant.taxNumber,
      email: tenant.email,
      phone: tenant.phone,
      createdAt: tenant.createdAt,
      users: tenant.users,
      plan: sub
        ? {
            code: sub.planCode,
            name: sub.plan.name,
            status: sub.status,
            maxProducts: sub.plan.maxProducts,
            maxChannels: sub.plan.maxChannels,
            maxOrdersMonth: sub.plan.maxOrdersMonth,
            syncIntervalMin: sub.plan.syncIntervalMin,
            trialEndsAt: sub.trialEndsAt,
            currentEnd: sub.currentEnd,
          }
        : null,
    };
  }

  /** Panelin boş durum ekranı için özet — Faz 2/3'te gerçek sayılarla dolacak. */
  async summary(tenantId: string | null, kind: string) {
    if (!tenantId) throw new ForbiddenException("Bu hesaba bağlı bir firma yok.");

    if (kind === "supplier") {
      const [products, variants, orderItems] = await Promise.all([
        this.prisma.product.count({ where: { supplierId: tenantId } }),
        this.prisma.productVariant.count({ where: { product: { supplierId: tenantId } } }),
        this.prisma.orderItem.count({ where: { supplierId: tenantId } }),
      ]);
      return { kind, products, variants, orderItems };
    }

    const [channels, listings, orders] = await Promise.all([
      this.prisma.channelAccount.count({ where: { tenantId } }),
      this.prisma.listing.count({ where: { sellerId: tenantId } }),
      this.prisma.order.count({ where: { sellerId: tenantId } }),
    ]);
    return { kind, channels, listings, orders };
  }
}
