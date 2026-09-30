import "server-only";
import type { NextResponse } from "next/server";
import { ACCESS_COOKIE, REFRESH_COOKIE } from "./session";

// Secure çerez yalnızca https üzerinde gönderilir; http://localhost'ta kapalı olmalı
// yoksa tarayıcı çerezi hiç saklamaz.
const secure = (process.env.APP_URL ?? "").startsWith("https://");

export function setAuthCookies(
  res: NextResponse,
  tokens: { accessToken: string; refreshToken: string; expiresIn: number },
): void {
  res.cookies.set(ACCESS_COOKIE, tokens.accessToken, {
    httpOnly: true, secure, sameSite: "lax", path: "/", maxAge: tokens.expiresIn,
  });
  res.cookies.set(REFRESH_COOKIE, tokens.refreshToken, {
    httpOnly: true, secure, sameSite: "lax", path: "/", maxAge: 30 * 86400,
  });
}

export function clearAuthCookies(res: NextResponse): void {
  res.cookies.delete(ACCESS_COOKIE);
  res.cookies.delete(REFRESH_COOKIE);
}
