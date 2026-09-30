import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { createHash, randomBytes } from "node:crypto";
import { hashPassword, needsRehash, verifyPassword, TRIAL_DAYS, TRIAL_PLAN } from "@depar/shared";
import type { AuthTokens, SessionUser } from "@depar/shared";
import { PrismaService } from "../prisma/prisma.service";
import type { RegisterDto } from "./dto/register.dto";
import type { LoginDto } from "./dto/login.dto";

interface ClientInfo {
  ip?: string;
  userAgent?: string;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  // ---------------------------------------------------------------- kayıt
  async register(dto: RegisterDto, client: ClientInfo): Promise<{ user: SessionUser; tokens: AuthTokens }> {
    const email = dto.email.trim().toLowerCase();

    const exists = await this.prisma.user.findUnique({ where: { email } });
    if (exists) {
      throw new ConflictException("Bu e-posta ile zaten bir hesap var.");
    }

    const passwordHash = await hashPassword(dto.password);
    const now = new Date();
    const trialEnd = new Date(now.getTime() + TRIAL_DAYS * 86_400_000);

    const user = await this.prisma.$transaction(async (tx) => {
      const tenant = await tx.tenant.create({
        data: {
          kind: dto.role,
          // Satıcı hemen satışa başlayabilir; tedarikçi belge onayından geçer (docs/00 Faz 2).
          status: dto.role === "seller" ? "active" : "pending",
          companyName: dto.companyName.trim(),
          email,
          phone: dto.phone?.trim(),
          slug: await this.uniqueSlug(tx, dto.companyName),
          approvedAt: dto.role === "seller" ? now : null,
        },
      });

      const created = await tx.user.create({
        data: {
          tenantId: tenant.id,
          email,
          passwordHash,
          fullName: dto.fullName.trim(),
          phone: dto.phone?.trim(),
          role: dto.role,
          isOwner: true,
        },
      });

      // Satıcıya 14 günlük kartsız deneme (Profesyonel özellikleriyle) — docs/06.
      if (dto.role === "seller") {
        await tx.subscription.create({
          data: {
            tenantId: tenant.id,
            planCode: TRIAL_PLAN,
            status: "trialing",
            trialEndsAt: trialEnd,
            currentStart: now,
            currentEnd: trialEnd,
          },
        });
      }

      await tx.auditLog.create({
        data: {
          tenantId: tenant.id,
          userId: created.id,
          action: "auth.register",
          entity: "tenant",
          entityId: tenant.id,
          after: { kind: dto.role, companyName: tenant.companyName },
          ip: client.ip,
        },
      });

      return created;
    });

    const tokens = await this.issueTokens(user.id, client);
    return { user: await this.buildSession(user.id), tokens };
  }

  // ---------------------------------------------------------------- giriş
  async login(dto: LoginDto, client: ClientInfo): Promise<{ user: SessionUser; tokens: AuthTokens }> {
    const email = dto.email.trim().toLowerCase();
    const user = await this.prisma.user.findUnique({ where: { email } });

    // Kullanıcı yoksa da şifre doğrulama süresi kadar bekle: e-posta var/yok bilgisi sızmasın.
    const stored = user?.passwordHash ?? (await this.dummyHash());
    const ok = await verifyPassword(dto.password, stored);

    if (!user || !ok) {
      throw new UnauthorizedException("E-posta veya şifre hatalı.");
    }
    if (user.tenantId) {
      const tenant = await this.prisma.tenant.findUnique({ where: { id: user.tenantId } });
      if (tenant?.status === "closed" || tenant?.status === "suspended") {
        throw new UnauthorizedException("Hesabın askıya alınmış. Destek ekibiyle iletişime geç.");
      }
    }

    if (needsRehash(user.passwordHash)) {
      await this.prisma.user.update({
        where: { id: user.id },
        data: { passwordHash: await hashPassword(dto.password) },
      });
    }

    await this.prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } });

    const tokens = await this.issueTokens(user.id, client);
    return { user: await this.buildSession(user.id), tokens };
  }

  // ------------------------------------------------------------- yenileme
  async refresh(refreshToken: string, client: ClientInfo): Promise<AuthTokens> {
    const tokenHash = this.hashToken(refreshToken);
    const record = await this.prisma.refreshToken.findUnique({ where: { tokenHash } });

    if (!record || record.revokedAt || record.expiresAt < new Date()) {
      throw new UnauthorizedException("Oturum süresi doldu, tekrar giriş yap.");
    }

    // Rotasyon: kullanılan token iptal edilir, yenisi verilir.
    await this.prisma.refreshToken.update({
      where: { id: record.id },
      data: { revokedAt: new Date() },
    });

    return this.issueTokens(record.userId, client);
  }

  async logout(refreshToken: string): Promise<void> {
    const tokenHash = this.hashToken(refreshToken);
    await this.prisma.refreshToken.updateMany({
      where: { tokenHash, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async logoutAll(userId: string): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  // ---------------------------------------------------------------- oturum
  async buildSession(userId: string): Promise<SessionUser> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        tenant: {
          include: {
            subscriptions: {
              orderBy: { createdAt: "desc" },
              take: 1,
              include: { plan: true },
            },
          },
        },
      },
    });
    if (!user) throw new UnauthorizedException("Kullanıcı bulunamadı.");

    const sub = user.tenant?.subscriptions[0];
    const end = sub?.trialEndsAt ?? sub?.currentEnd;

    return {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      role: user.role as SessionUser["role"],
      isOwner: user.isOwner,
      tenant: user.tenant
        ? {
            id: user.tenant.id,
            kind: user.tenant.kind as "seller" | "supplier",
            companyName: user.tenant.companyName,
            status: user.tenant.status,
          }
        : null,
      subscription: sub
        ? {
            planCode: sub.planCode,
            planName: sub.plan.name,
            status: sub.status,
            trialEndsAt: sub.trialEndsAt?.toISOString() ?? null,
            currentEnd: sub.currentEnd.toISOString(),
            daysLeft: end ? Math.max(0, Math.ceil((end.getTime() - Date.now()) / 86_400_000)) : 0,
          }
        : null,
    };
  }

  // -------------------------------------------------------------- yardımcı
  private async issueTokens(userId: string, client: ClientInfo): Promise<AuthTokens> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new BadRequestException("Kullanıcı bulunamadı.");

    const accessTtl = this.config.get<string>("jwt.accessTtl")!;
    const accessToken = await this.jwt.signAsync(
      { sub: user.id, tid: user.tenantId, role: user.role, email: user.email, typ: "access" },
      { secret: this.config.get<string>("jwt.secret")!, expiresIn: accessTtl },
    );

    // Refresh token JWT değil: rastgele üretilir, hash'i saklanır, tek kullanımlıktır.
    const refreshToken = randomBytes(48).toString("base64url");
    const days = Number((this.config.get<string>("jwt.refreshTtl") ?? "30d").replace(/\D/g, "")) || 30;

    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: this.hashToken(refreshToken),
        expiresAt: new Date(Date.now() + days * 86_400_000),
        ip: client.ip,
        userAgent: client.userAgent?.slice(0, 250),
      },
    });

    return { accessToken, refreshToken, expiresIn: this.ttlToSeconds(accessTtl) };
  }

  private hashToken(token: string): string {
    return createHash("sha256").update(token).digest("hex");
  }

  private ttlToSeconds(ttl: string): number {
    const m = /^(\d+)([smhd])$/.exec(ttl);
    if (!m) return 900;
    const n = Number(m[1]);
    return { s: n, m: n * 60, h: n * 3600, d: n * 86400 }[m[2] as "s" | "m" | "h" | "d"];
  }

  private dummyHashCache: string | null = null;
  private async dummyHash(): Promise<string> {
    this.dummyHashCache ??= await hashPassword(randomBytes(16).toString("hex"));
    return this.dummyHashCache;
  }

  private async uniqueSlug(tx: { tenant: { findUnique: (a: any) => Promise<unknown> } }, name: string): Promise<string> {
    const base =
      name
        .toLowerCase()
        .replace(/ı/g, "i").replace(/ğ/g, "g").replace(/ü/g, "u")
        .replace(/ş/g, "s").replace(/ö/g, "o").replace(/ç/g, "c")
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "")
        .slice(0, 40) || "firma";

    let slug = base;
    for (let i = 2; await tx.tenant.findUnique({ where: { slug } }); i++) {
      slug = `${base}-${i}`;
      if (i > 50) {
        slug = `${base}-${randomBytes(3).toString("hex")}`;
        break;
      }
    }
    return slug;
  }
}
