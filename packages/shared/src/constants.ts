export const PLAN_CODES = ["starter", "pro", "enterprise"] as const;
export type PlanCode = (typeof PLAN_CODES)[number];

export const TENANT_KINDS = ["seller", "supplier"] as const;
export type TenantKind = (typeof TENANT_KINDS)[number];

/** Deneme süresi: 14 gün, kartsız, Profesyonel özellikleriyle (docs/06). */
export const TRIAL_DAYS = 14;
export const TRIAL_PLAN: PlanCode = "pro";

export const MARKETPLACES = ["trendyol", "hepsiburada", "n11"] as const;
export type MarketplaceCode = (typeof MARKETPLACES)[number];

export const MARKETPLACE_LABELS: Record<string, string> = {
  trendyol: "Trendyol",
  hepsiburada: "Hepsiburada",
  n11: "N11",
  ciceksepeti: "Çiçeksepeti",
  pttavm: "PttAVM",
  amazon_tr: "Amazon TR",
};
