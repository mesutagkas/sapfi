import { createParamDecorator, ExecutionContext } from "@nestjs/common";

export interface RequestUser {
  userId: string;
  tenantId: string | null;
  role: "seller" | "supplier" | "admin" | "support";
  email: string;
}

/** Doğrulanmış kullanıcıyı denetleyiciye taşır: @CurrentUser() user: RequestUser */
export const CurrentUser = createParamDecorator((data: keyof RequestUser | undefined, ctx: ExecutionContext) => {
  const req = ctx.switchToHttp().getRequest();
  return data ? req.user?.[data] : req.user;
});
