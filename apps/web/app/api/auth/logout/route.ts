import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { apiFetch } from "@/lib/api";
import { clearAuthCookies } from "@/lib/cookies";
import { REFRESH_COOKIE } from "@/lib/session";

export async function POST() {
  const jar = await cookies();
  const refreshToken = jar.get(REFRESH_COOKIE)?.value;

  if (refreshToken) {
    await apiFetch("/v1/auth/logout", { method: "POST", body: JSON.stringify({ refreshToken }) });
  }

  const res = NextResponse.json({ ok: true });
  clearAuthCookies(res);
  return res;
}
