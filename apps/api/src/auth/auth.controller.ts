import { Body, Controller, Get, HttpCode, Ip, Post, Req } from "@nestjs/common";
import { Throttle } from "@nestjs/throttler";
import type { Request } from "express";
import { AuthService } from "./auth.service";
import { RegisterDto } from "./dto/register.dto";
import { LoginDto } from "./dto/login.dto";
import { RefreshDto } from "./dto/refresh.dto";
import { Public } from "../common/decorators/public.decorator";
import { CurrentUser, type RequestUser } from "../common/decorators/current-user.decorator";

@Controller("v1/auth")
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public()
  @Post("register")
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  register(@Body() dto: RegisterDto, @Ip() ip: string, @Req() req: Request) {
    return this.auth.register(dto, { ip, userAgent: req.headers["user-agent"] });
  }

  @Public()
  @Post("login")
  @HttpCode(200)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  login(@Body() dto: LoginDto, @Ip() ip: string, @Req() req: Request) {
    return this.auth.login(dto, { ip, userAgent: req.headers["user-agent"] });
  }

  @Public()
  @Post("refresh")
  @HttpCode(200)
  refresh(@Body() dto: RefreshDto, @Ip() ip: string, @Req() req: Request) {
    return this.auth.refresh(dto.refreshToken, { ip, userAgent: req.headers["user-agent"] });
  }

  @Public()
  @Post("logout")
  @HttpCode(204)
  async logout(@Body() dto: RefreshDto): Promise<void> {
    await this.auth.logout(dto.refreshToken);
  }

  @Get("me")
  me(@CurrentUser() user: RequestUser) {
    return this.auth.buildSession(user.userId);
  }
}
