import { IsNumber, Matches, Max, Min } from 'class-validator';

// userId는 받지 않는다. 누구의 기록인지는 토큰에서 정한다.
export class CreateWeightDto {
  @IsNumber()
  @Min(20, { message: '체중 범위는 20~300kg로 입력해 주세요.' })
  @Max(300, { message: '체중 범위는 20~300kg로 입력해 주세요.' })
  weight: number;

  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '날짜는 YYYY-MM-DD 형식이에요.' })
  recordedDate: string;
}
