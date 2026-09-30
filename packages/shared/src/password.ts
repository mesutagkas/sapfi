import { randomBytes, scrypt as _scrypt, timingSafeEqual } from "node:crypto";
import { promisify } from "node:util";

const scrypt = promisify(_scrypt) as (
  password: string,
  salt: Buffer,
  keylen: number,
  options: { N: number; r: number; p: number; maxmem: number },
) => Promise<Buffer>;

/**
 * Şifre özetleme.
 *
 * Node'un yerleşik scrypt'i kullanılır: derleme gerektiren native bağımlılık yok,
 * OWASP'ın önerdiği parametrelerle çalışır (N=2^15, r=8, p=1).
 * Format sürümlüdür ("scrypt$N$r$p$salt$hash"); ileride argon2id'ye geçilirse
 * `verify` eski özetleri doğrulamaya devam eder, `needsRehash` true döner.
 */
const N = 2 ** 15;
const R = 8;
const P = 1;
const KEYLEN = 64;
const MAXMEM = 128 * N * R * 2;

export async function hashPassword(plain: string): Promise<string> {
  const salt = randomBytes(16);
  const hash = await scrypt(plain.normalize("NFKC"), salt, KEYLEN, { N, r: R, p: P, maxmem: MAXMEM });
  return ["scrypt", N, R, P, salt.toString("base64"), hash.toString("base64")].join("$");
}

export async function verifyPassword(plain: string, stored: string): Promise<boolean> {
  const parts = stored.split("$");
  if (parts.length !== 6 || parts[0] !== "scrypt") return false;
  const [, n, r, p, saltB64, hashB64] = parts;
  const salt = Buffer.from(saltB64, "base64");
  const expected = Buffer.from(hashB64, "base64");
  const actual = await scrypt(plain.normalize("NFKC"), salt, expected.length, {
    N: Number(n),
    r: Number(r),
    p: Number(p),
    maxmem: 128 * Number(n) * Number(r) * 2,
  });
  return actual.length === expected.length && timingSafeEqual(actual, expected);
}

/** Parametreler güncel değilse giriş sırasında yeniden özetle. */
export function needsRehash(stored: string): boolean {
  const [algo, n, r, p] = stored.split("$");
  return algo !== "scrypt" || Number(n) !== N || Number(r) !== R || Number(p) !== P;
}
