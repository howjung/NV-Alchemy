import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  email: string;

  // select: false → 평소 조회 결과에 섞여 나가지 않는다(로그인 때만 명시해서 읽음)
  @Column({ select: false })
  passwordHash: string;

  @Column()
  nickname: string;

  // 아래 신체 정보는 가입 직후엔 비어 있고, 온보딩에서 PATCH /users/me로 채운다
  @Column({ type: 'varchar', nullable: true })
  gender: string | null; // '남' | '여'

  @Column({ type: 'varchar', nullable: true })
  birthDate: string | null; // 'YYYY-MM-DD'

  @Column({ type: 'float', nullable: true })
  heightCm: number | null;

  @Column({ type: 'float', nullable: true })
  targetWeight: number | null;

  @Column({ type: 'int', default: 2000 })
  dailyCalorieGoal: number;

  @CreateDateColumn()
  createdAt: Date;
}
