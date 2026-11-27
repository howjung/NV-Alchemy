import { Entity, PrimaryColumn } from 'typeorm';

// 식단을 기록한 날짜. 한 사람의 같은 날짜는 한 줄만 있다.
// 식단을 삭제해도 지우지 않는다(PRD: 연속 기록은 회수하지 않음).
@Entity()
export class RecordDay {
  @PrimaryColumn()
  userId: number;

  @PrimaryColumn()
  date: string; // 'YYYY-MM-DD' (한국 시간)
}
