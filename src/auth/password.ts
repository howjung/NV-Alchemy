import { randomBytes, scrypt, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';

const scryptAsync = promisify(scrypt);

// 비밀번호는 원문으로 저장하지 않고 "솔트:해시" 문자열로 저장한다.
// 솔트는 사용자마다 다른 난수라서, 같은 비밀번호여도 저장값이 달라진다.
export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16).toString('hex');
  const hash = (await scryptAsync(password, salt, 64)) as Buffer;
  return `${salt}:${hash.toString('hex')}`;
}

// 로그인할 때: 입력한 비밀번호를 같은 솔트로 다시 해시해서 저장값과 비교한다.
export async function verifyPassword(
  password: string,
  stored: string,
): Promise<boolean> {
  const [salt, hashHex] = stored.split(':');
  const expected = Buffer.from(hashHex, 'hex');
  const actual = (await scryptAsync(password, salt, 64)) as Buffer;
  return timingSafeEqual(expected, actual); // 시간 차이로 값을 추측하지 못하게 비교
}
