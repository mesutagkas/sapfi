import { Controller, Get } from "@nestjs/common";
import { Public } from "../common/decorators/public.decorator";
import { PrismaService } from "../prisma/prisma.service";

@Controller()
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Get("health")
  async health() {
    const started = Date.now();
    let db = "down";
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      db = "up";
    } catch {
      db = "down";
    }
    return {
      status: db === "up" ? "ok" : "degraded",
      db,
      latencyMs: Date.now() - started,
      uptimeSec: Math.floor(process.uptime()),
      version: process.env.npm_package_version ?? "0.1.0",
    };
  }
}
