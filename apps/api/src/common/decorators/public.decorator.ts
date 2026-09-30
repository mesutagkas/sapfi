import { SetMetadata } from "@nestjs/common";

export const IS_PUBLIC_KEY = "isPublic";
/** Kimlik doğrulaması istemeyen uçlar. */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
