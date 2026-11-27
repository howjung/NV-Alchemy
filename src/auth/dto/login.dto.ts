import { IsEmail, IsString } from 'class-validator';

export class LoginDto {
  @IsEmail({}, { message: '이메일 형식이 올바르지 않아요.' })
  email: string;

  @IsString()
  password: string;
}
