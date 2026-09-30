import { NextResponse } from "next/server";
import type { AuthTokens, SessionUser } from "@depar/shared";
import { apiFetch, firstMessage } from "@/lib/api";
import { setAuthCookies } from "@/lib/cookies";

export async function POST(req: Request) {
  const b = await req.json().catch(() => ({}));

  const res = await apiFetch<{ user: SessionUser; tokens: AuthTokens }>("/v1/auth/register", {
    method: "POST",
    body: JSON.stringify({
      role: b.role,
      fullName: b.fullName,
      companyName: b.companyName,
      email: b.email,
      phone: b.phone || undefined,
      password: b.password,
    }),
  });

  if (!res.ok) {
    return NextResponse.json({ message: firstMessage(res.error) }, { status: res.error.statusCode });
  }

  const out = NextResponse.json({ user: res.data.user });
  setAuthCookies(out, res.data.tokens);
  return out;
}
