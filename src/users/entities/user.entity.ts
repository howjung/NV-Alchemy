import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  email: string;

  @Column()
  nickname: string;

  @Column({ type: 'float', nullable: true })
  targetWeight: number;

  @Column({ type: 'int', default: 2000 })
  dailyCalorieGoal: number;

  @CreateDateColumn()
  createdAt: Date;
}