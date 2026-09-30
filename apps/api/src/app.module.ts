import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { APP_FILTER, APP_GUARD } from "@nestjs/core";
import { ThrottlerGuard, ThrottlerModule } from "@nestjs/throttler";
import { loadConfig } from "./config/configuration";
import { PrismaModule } from "./prisma/prisma.module";
import { AuthModule } from "./auth/auth.module";
import { TenantsModule } from "./tenants/tenants.module";
import { HealthModule } from "./health/health.module";
import { JwtAuthGuard } from "./common/guards/jwt-auth.guard";
import { RolesGuard } from "./common/guards/roles.guard";
import { AllExceptionsFilter } from "./common/filters/all-exceptions.filter";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [loadConfig], envFilePath: [".env", "../../.env"] }),
    ThrottlerModule.forRoot([{ name: "default", ttl: 60_000, limit: 120 }]),
    PrismaModule,
    AuthModule,
    TenantsModule,
    HealthModule,
  ],
  providers: [
    // Sıra önemli: önce hız sınırı, sonra kimlik, sonra rol.
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
    { provide: APP_FILTER, useClass: AllExceptionsFilter },
  ],
})
export class AppModule {}
