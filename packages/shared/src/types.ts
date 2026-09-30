export interface JwtPayload {
  sub: string;          // user id
  tid: string | null;   // tenant id
  role: "seller" | "supplier" | "admin" | "support";
  typ: "access" | "refresh";
}

export interface SessionUser {
  id: string;
  email: string;
  fullName: string;
  role: JwtPayload["role"];
  isOwner: boolean;
  tenant: {
    id: string;
    kind: "seller" | "supplier";
    companyName: string;
    status: string;
  } | null;
  subscription: {
    planCode: string;
    planName: string;
    status: string;
    trialEndsAt: string | null;
    currentEnd: string;
    daysLeft: number;
  } | null;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}
