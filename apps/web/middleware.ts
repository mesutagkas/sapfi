import { NextResponse, type NextRequest } from "next/server";

/** Panel yalnızca oturumlu kullanıcıya açık; çerez yoksa girişe yönlendirilir. */
export function middleware(req: NextRequest) {
  const hasSession =
    req.cookies.has("depar_at") || req.cookies.has("depar_rt");

  if (!hasSession) {
    const url = req.nextUrl.clone();
    url.pathname = "/giris";
    url.search = `?next=${encodeURIComponent(req.nextUrl.pathname)}`;
    return NextResponse.redirect(url);
  }
  return NextResponse.next();
}

export const config = { matcher: ["/panel/:path*"] };
