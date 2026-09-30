import { PrismaClient } from "@prisma/client";

export * from "@prisma/client";

/** Tek örnek (singleton) Prisma istemcisi — geliştirmede hot-reload'da bağlantı sızdırmaz. */
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["warn", "error"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
