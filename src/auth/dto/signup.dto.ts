import { IsEmail, IsString, Length, MinLength } from 'class-validator';

// 입력 규칙은 PRD 7장: 비밀번호 8자 이상, 닉네임 2~12자
export class SignupDto {
  @IsEmail({}, { message: '이메일 형식이 올바르지 않아요.' })
  email: string;

  @IsString()
  @MinLength(8, { message: '비밀번호는 8자 이상으로 입력해 주세요.' })
  password: string;

  @IsString()
  @Length(2, 12, { message: '닉네임은 2~12자로 입력해 주세요.' })
  nickname: string;
}
