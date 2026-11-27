import {
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Length,
  Matches,
  Max,
  Min,
} from 'class-validator';

// 보낸 항목만 수정한다. 범위는 PRD 7장 기준(키 100~250cm, 체중 20~300kg, 닉네임 2~12자).
export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @Length(2, 12, { message: '닉네임은 2~12자로 입력해 주세요.' })
  nickname?: string;

  @IsOptional()
  @IsIn(['남', '여'], { message: '성별은 남 또는 여로 입력해 주세요.' })
  gender?: string;

  // 만 14~100세 검사는 날짜 계산이 필요해서 users.service에서 한다
  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '생년월일은 YYYY-MM-DD 형식이에요.' })
  birthDate?: string;

  @IsOptional()
  @IsNumber()
  @Min(100, { message: '키 범위는 100~250cm로 입력해 주세요.' })
  @Max(250, { message: '키 범위는 100~250cm로 입력해 주세요.' })
  heightCm?: number;

  @IsOptional()
  @IsNumber()
  @Min(20, { message: '목표 체중 범위는 20~300kg로 입력해 주세요.' })
  @Max(300, { message: '목표 체중 범위는 20~300kg로 입력해 주세요.' })
  targetWeight?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  dailyCalorieGoal?: number;
}
