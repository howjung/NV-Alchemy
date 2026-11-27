import { Controller, Get } from '@nestjs/common';
import { Public } from '../auth/public.decorator'; // 점 두 개(..)
import { NoticesService } from './notices.service';

@Public() // 로그인 없이 볼 수 있다
@Controller('notices')
export class NoticesController {
    constructor(private readonly noticesService: NoticesService) { }

    @Get() // GET /notices
    findAll() {
        return this.noticesService.findAll();
    }
}