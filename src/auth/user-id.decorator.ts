import { createParamDecorator, ExecutionContext } from '@nestjs/common';

// 컨트롤러에서 `@UserId() userId: number`로 "지금 요청한 사람의 번호"를 받는다.
// 번호는 요청 body가 아니라 토큰에서 나온 값이라 앱이 속일 수 없다.
export const UserId = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): number =>
    ctx.switchToHttp().getRequest().userId,
);
