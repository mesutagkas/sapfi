import { IsEmail, IsIn, IsOptional, IsString, Matches, MaxLength, MinLength } from "class-validator";

export class RegisterDto {
  @IsIn(["seller", "supplier"], { message: "Rol 'seller' veya 'supplier' olmalı." })
  role!: "seller" | "supplier";

  @IsString() @MinLength(2, { message: "Ad soyad en az 2 karakter olmalı." }) @MaxLength(120)
  fullName!: string;

  @IsString() @MinLength(2, { message: "Firma ünvanı en az 2 karakter olmalı." }) @MaxLength(200)
  companyName!: string;

  @IsEmail({}, { message: "Geçerli bir e-posta adresi gir." })
  email!: string;

  @IsOptional() @IsString() @MaxLength(20)
  phone?: string;

  @IsString()
  @MinLength(8, { message: "Şifre en az 8 karakter olmalı." })
  @MaxLength(128)
  @Matches(/[A-Za-zÇĞİÖŞÜçğıöşü]/, { message: "Şifre en az bir harf içermeli." })
  @Matches(/\d/, { message: "Şifre en az bir rakam içermeli." })
  password!: string;
}
