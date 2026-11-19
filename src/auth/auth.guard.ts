import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { IS_PUBLIC } from './public.decorator';

// 모든 요청이 컨트롤러에 도착하기 전에 이 문지기를 한 번 거친다(app.module에서 전역 등록).
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private jwt: JwtService,
    private reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // 1) @Public()이 붙은 API(가입·로그인)는 통과
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    // 2) 나머지는 "Authorization: Bearer <토큰>" 헤더가 있어야 한다
    const request = context.switchToHttp().getRequest();
    const [type, token] = (request.headers.authorization ?? '').split(' ');
    if (type !== 'Bearer' || !token) {
      throw new UnauthorizedException('로그인이 필요해요.');
    }

    // 3) 토큰이 진짜인지(서명)·만료되지 않았는지 검사하고, 안에 든 유저 번호를 꺼낸다
    try {
      const payload = await this.jwt.verifyAsync<{ sub: number }>(token);
      request.userId = payload.sub;
      return true;
    } catch {
      throw new UnauthorizedException('로그인이 만료되었거나 올바르지 않아요.');
    }
  }
}
