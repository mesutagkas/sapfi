import "server-only";

const API = process.env.API_INTERNAL_URL ?? "http://localhost:3001";

export interface ApiError {
  statusCode: number;
  message: string | string[];
  error?: string;
}

/** Sunucu tarafından Depar API'sine istek. Token verilirse Bearer olarak eklenir. */
export async function apiFetch<T>(
  path: string,
  options: RequestInit & { token?: string } = {},
): Promise<{ ok: true; data: T } | { ok: false; error: ApiError }> {
  const { token, headers, ...rest } = options;

  let res: Response;
  try {
    res = await fetch(`${API}${path}`, {
      ...rest,
      cache: "no-store",
      headers: {
        "Content-Type": "application/json",
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...headers,
      },
    });
  } catch {
    return {
      ok: false,
      error: { statusCode: 503, message: "API'ye ulaşılamıyor. Servis çalışıyor mu?" },
    };
  }

  if (res.status === 204) return { ok: true, data: undefined as T };

  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    return {
      ok: false,
      error: { statusCode: res.status, message: body.message ?? "Beklenmeyen bir hata oluştu.", error: body.error },
    };
  }
  return { ok: true, data: body as T };
}

/** Hata mesajını tek satıra indirger (class-validator dizi döndürebilir). */
export function firstMessage(error: ApiError): string {
  return Array.isArray(error.message) ? error.message[0] : error.message;
}
