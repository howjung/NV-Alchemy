import { IsIn, IsInt, IsNotEmpty, IsNumber, IsOptional, IsString, Matches, Min } from 'class-validator';

// userId는 받지 않는다. 누구의 기록인지는 토큰에서 정한다.
export class CreateMealDto {
  @IsIn(['아침', '점심', '저녁', '간식'], { message: '끼니는 아침·점심·저녁·간식 중 하나예요.' })
  mealType: string;

  @IsString()
  @IsNotEmpty()
  foodName: string;

  @IsInt()
  @Min(0)
  calories: number;

  @IsOptional() @IsNumber() @Min(0) carbs?: number;
  @IsOptional() @IsNumber() @Min(0) protein?: number;
  @IsOptional() @IsNumber() @Min(0) fat?: number;

  @IsOptional() @IsString() imageUrl?: string;

  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '날짜는 YYYY-MM-DD 형식이에요.' })
  recordedDate: string;
}
