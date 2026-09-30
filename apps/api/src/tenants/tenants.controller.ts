import { Controller, Get } from "@nestjs/common";
import { TenantsService } from "./tenants.service";
import { CurrentUser, type RequestUser } from "../common/decorators/current-user.decorator";

@Controller("v1/tenant")
export class TenantsController {
  constructor(private readonly tenants: TenantsService) {}

  @Get()
  mine(@CurrentUser() user: RequestUser) {
    return this.tenants.findMine(user.tenantId);
  }

  @Get("summary")
  summary(@CurrentUser() user: RequestUser) {
    return this.tenants.summary(user.tenantId, user.role);
  }
}
