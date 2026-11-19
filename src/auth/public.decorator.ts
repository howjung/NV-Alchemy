import { SetMetadata } from '@nestjs/common';

// 로그인 없이 쓸 수 있는 API에만 붙인다. 붙이지 않은 API는 모두 로그인이 필요하다.
export const IS_PUBLIC = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC, true);
