import "reflect-metadata";
import { Logger, ValidationPipe } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { NestFactory } from "@nestjs/core";
import helmet from "helmet";
import { AppModule } from "./app.module";

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, { bufferLogs: false });
  const config = app.get(ConfigService);

  app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
  app.enableCors({
    origin: config.get<string[]>("corsOrigins"),
    credentials: true,
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,            // DTO'da olmayan alanlar düşer
      forbidNonWhitelisted: true, // fazladan alan gönderilirse hata
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  app.enableShutdownHooks();

  const port = config.get<number>("port") ?? 3001;
  await app.listen(port, "0.0.0.0");
  Logger.log(`Depar API hazır → http://localhost:${port}`, "Bootstrap");
}

void bootstrap();
