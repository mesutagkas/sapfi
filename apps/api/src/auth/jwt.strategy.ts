import { Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import type { RequestUser } from "../common/decorators/current-user.decorator";

interface AccessPayload {
  sub: string;
  tid: string | null;
  role: RequestUser["role"];
  email: string;
  typ: "access";
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, "jwt") {
  constructor(config: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get<string>("jwt.secret")!,
    });
  }

  validate(payload: AccessPayload): RequestUser {
    if (payload.typ !== "access") {
      throw new UnauthorizedException("Geçersiz oturum anahtarı.");
    }
    return { userId: payload.sub, tenantId: payload.tid, role: payload.role, email: payload.email };
  }
}
