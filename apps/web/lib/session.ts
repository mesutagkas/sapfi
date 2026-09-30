import "server-only";
import { cookies } from "next/headers";
import type { SessionUser } from "@depar/shared";
import { apiFetch } from "./api";

export const ACCESS_COOKIE = "depar_at";
export const REFRESH_COOKIE = "depar_rt";

/**
 * Token'lar httpOnly çerezde tutulur — JavaScript erişemez, XSS ile çalınamaz.
 * Access token kısa ömürlüdür; süresi dolmuşsa refresh ile sessizce yenilenir.
 */
export async function getSession(): Promise<SessionUser | null> {
  const jar = await cookies();
  const access = jar.get(ACCESS_COOKIE)?.value;

  if (access) {
    const res = await apiFetch<SessionUser>("/v1/auth/me", { token: access });
    if (res.ok) return res.data;
    if (res.error.statusCode !== 401) return null;
  }

  const refresh = jar.get(REFRESH_COOKIE)?.value;
  if (!refresh) return null;

  const refreshed = await apiFetch<{ accessToken: string }>("/v1/auth/refresh", {
    method: "POST",
    body: JSON.stringify({ refreshToken: refresh }),
  });
  if (!refreshed.ok) return null;

  const me = await apiFetch<SessionUser>("/v1/auth/me", { token: refreshed.data.accessToken });
  return me.ok ? me.data : null;
}

export async function getAccessToken(): Promise<string | null> {
  const jar = await cookies();
  return jar.get(ACCESS_COOKIE)?.value ?? null;
}
