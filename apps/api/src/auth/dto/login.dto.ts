import { IsEmail, IsString, MinLength } from "class-validator";

export class LoginDto {
  @IsEmail({}, { message: "Geçerli bir e-posta adresi gir." })
  email!: string;

  @IsString() @MinLength(1, { message: "Şifre gerekli." })
  password!: string;
}
