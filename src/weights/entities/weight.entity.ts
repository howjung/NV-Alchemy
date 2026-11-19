import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity()
export class Weight {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'float' })
  weight: number; // 체중 (kg)

  @Column()
  recordedDate: string; // 기록 날짜 (예: '2026-11-16')

  @Column()
  userId: number; // 회원 ID

  @CreateDateColumn()
  createdAt: Date;
}