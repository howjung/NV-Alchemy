import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

// entity = DB 테이블의 모양
@Entity()
export class Notice {
    @PrimaryGeneratedColumn() // 번호 자동 증가
    id: number;

    @Column()
    title: string;

    @Column()
    date: string; // '2026-10-01'

    @Column('text') // 긴 글
    body: string;
}