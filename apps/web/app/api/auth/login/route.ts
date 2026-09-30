import { NextResponse } from "next/server";
import type { AuthTokens, SessionUser } from "@depar/shared";
import { apiFetch, firstMessage } from "@/lib/api";
import { setAuthCookies } from "@/lib/cookies";

export async function POST(req: Request) {
  const body = await req.json().catch(() => ({}));

  const res = await apiFetch<{ user: SessionUser; tokens: AuthTokens }>("/v1/auth/login", {
    method: "POST",
    body: JSON.stringify({ email: body.email, password: body.password }),
  });

  if (!res.ok) {
    return NextResponse.json({ message: firstMessage(res.error) }, { status: res.error.statusCode });
  }

  const out = NextResponse.json({ user: res.data.user });
  setAuthCookies(out, res.data.tokens);
  return out;
}
