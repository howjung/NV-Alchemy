import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity()
export class Meal {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  mealType: string; // '아침', '점심', '저녁', '간식'

  @Column()
  foodName: string; // 음식 이름

  @Column({ type: 'int' })
  calories: number; // 총 칼로리 (kcal)

  @Column({ type: 'float', default: 0 })
  carbs: number; // 탄수화물 (g)

  @Column({ type: 'float', default: 0 })
  protein: number; // 단백질 (g)

  @Column({ type: 'float', default: 0 })
  fat: number; // 지방 (g)

  @Column({ nullable: true })
  imageUrl: string; // 로컬 서버에 저장된 음식 사진 경로 (예: '/uploads/food1.jpg')

  @Column()
  recordedDate: string; // 식사 날짜 (예: '2026-11-16')

  @Column()
  userId: number; // 회원 ID

  @CreateDateColumn()
  createdAt: Date;
}