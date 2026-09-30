#!/usr/bin/env node
/**
 * Tek komutluk ilk kurulum:  npm run setup
 * Windows / macOS / Linux fark etmez — `cp` ve `openssl` gerekmez.
 *
 *  1. .env yoksa .env.example'dan oluşturur
 *  2. JWT ve şifreleme anahtarlarını rastgele üretir
 *  3. Sıradaki adımları yazar
 */
import { randomBytes } from "node:crypto";
import { copyFileSync, existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const envPath = resolve(root, ".env");
const examplePath = resolve(root, ".env.example");

if (existsSync(envPath)) {
  console.log("• .env zaten var — dokunulmadı.");
} else {
  copyFileSync(examplePath, envPath);

  const secrets = {
    JWT_SECRET: randomBytes(48).toString("hex"),
    JWT_REFRESH_SECRET: randomBytes(48).toString("hex"),
    ENCRYPTION_KEY: randomBytes(32).toString("hex"),
  };

  let env = readFileSync(envPath, "utf8");
  for (const [key, value] of Object.entries(secrets)) {
    env = env.replace(new RegExp(`^${key}=.*$`, "m"), `${key}=${value}`);
  }
  writeFileSync(envPath, env);

  console.log("✓ .env oluşturuldu, anahtarlar üretildi.");
}

console.log(`
Sıradaki adımlar:

  1) npm run infra:up      PostgreSQL + Redis + Mailpit (Docker Desktop açık olmalı)
  2) npm run db:migrate    tabloları oluşturur
  3) npm run db:seed       paketler, kategoriler, demo hesaplar

  Sonra üç ayrı terminalde:
     npm run dev:api       http://localhost:3001
     npm run dev:web       http://localhost:3000
     npm run dev:worker

  Demo giriş:  satici@depar.test  /  Depar1234!
`);
