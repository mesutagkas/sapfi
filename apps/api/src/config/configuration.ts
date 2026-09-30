/** Ortam değişkenleri tek yerden okunur ve açılışta doğrulanır. */
export interface AppConfig {
  env: string;
  port: number;
  corsOrigins: string[];
  jwt: { secret: string; refreshSecret: string; accessTtl: string; refreshTtl: string };
}

function required(name: string): string {
  const v = process.env[name];
  if (!v || v.trim() === "") {
    throw new Error(`Ortam değişkeni eksik: ${name} (.env dosyasını kontrol et)`);
  }
  return v;
}

export function loadConfig(): AppConfig {
  const env = process.env.NODE_ENV ?? "development";
  const dev = env !== "production";

  const secret = process.env.JWT_SECRET ?? (dev ? "dev-only-jwt-secret-degistir" : required("JWT_SECRET"));
  const refreshSecret =
    process.env.JWT_REFRESH_SECRET ?? (dev ? "dev-only-refresh-secret-degistir" : required("JWT_REFRESH_SECRET"));

  if (!dev && (secret.includes("degistir") || refreshSecret.includes("degistir"))) {
    throw new Error("Üretimde varsayılan JWT anahtarları kullanılamaz.");
  }
  required("DATABASE_URL");

  return {
    env,
    port: Number(process.env.API_PORT ?? 3001),
    corsOrigins: (process.env.CORS_ORIGINS ?? "http://localhost:3000").split(",").map((s) => s.trim()),
    jwt: {
      secret,
      refreshSecret,
      accessTtl: process.env.JWT_ACCESS_TTL ?? "15m",
      refreshTtl: process.env.JWT_REFRESH_TTL ?? "30d",
    },
  };
}
