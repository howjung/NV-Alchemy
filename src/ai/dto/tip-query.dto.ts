import { Type } from 'class-transformer';
import { IsInt, Max, Min } from 'class-validator';

// 하루 목표는 앱이 프로필 값(활동량 등)으로 계산해서 보낸다. 주소 뒤 ?calories=…로 오므로 숫자로 바꾼다
export class TipQueryDto {
  @Type(() => Number) @IsInt() @Min(500) @Max(10000)
  calories: number;

  @Type(() => Number) @IsInt() @Min(1) @Max(2000)
  carbs: number;

  @Type(() => Number) @IsInt() @Min(1) @Max(2000)
  protein: number;

  @Type(() => Number) @IsInt() @Min(1) @Max(2000)
  fat: number;
}
