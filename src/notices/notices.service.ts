import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notice } from './entities/notice.entity';

// 처음 실행할 때 넣을 공지 (앱 화면의 문구와 같음)
const SEED = [
    {
        title: '연속 기록 보상이 생겼어요',
        date: '2026-10-13',
        body: '식단을 하루에 처음 기록하면 5P를 받고, 연속 기록 일수가 늘어나요. 물방울 모양의 연속 기록은 홈 상단 물방울 버튼에서 확인할 수 있어요.',
    },
    {
        title: '상품 구매 포인트 적립 정책 변경 안내',
        date: '2026-10-10',
        body: '상품 구매 시 결제 금액의 1%가 포인트로 적립돼요. 적립된 포인트는 다음 주문부터 사용할 수 있어요.',
    },
    {
        title: 'Antifreeze 서비스를 시작해요',
        date: '2026-10-01',
        body: 'Antifreeze와 함께 AI 맞춤 식단을 시작해 보세요. 식단 기록, 쇼핑, 크루까지 한곳에서 이어져요.',
    },
];

@Injectable()
export class NoticesService implements OnModuleInit {
    constructor(
        @InjectRepository(Notice) private notices: Repository<Notice>,
    ) { }

    // 서버가 켜질 때 한 번 실행. 테이블이 비어 있을 때만 넣는다
    async onModuleInit() {
        if ((await this.notices.count()) === 0) {
            await this.notices.save(SEED);
        }
    }

    // 최신 날짜부터
    findAll() {
        return this.notices.find({ order: { date: 'DESC' } });
    }
}