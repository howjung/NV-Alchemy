// 실행 중인 서버(기본 http://localhost:3000)에 요청을 보내 인증 규칙을 확인한다.
// 사용: 서버를 켠 뒤  node test/auth-smoke.mjs   (BASE_URL로 주소 변경 가능)
import assert from 'node:assert/strict';

const BASE = process.env.BASE_URL ?? 'http://localhost:3000';
const run = Date.now();
const call = async (method, path, body, token) => {
  const res = await fetch(BASE + path, {
    method,
    headers: { 'content-type': 'application/json', ...(token && { authorization: `Bearer ${token}` }) },
    body: body && JSON.stringify(body),
  });
  return { status: res.status, body: await res.json().catch(() => null) };
};
const signup = (email, nickname = '테스터', password = 'password1') =>
  call('POST', '/auth/signup', { email, password, nickname });

// 1) 가입 입력 규칙
assert.equal((await signup('bad')).status, 400, '이메일 형식');
assert.equal((await signup(`a${run}@t.com`, '테스터', 'short')).status, 400, '비밀번호 8자 미만');
assert.equal((await signup(`a${run}@t.com`, '가')).status, 400, '닉네임 1자');

// 2) 가입·중복·로그인
const a = await signup(`a${run}@t.com`);
assert.equal(a.status, 201); assert.ok(a.body.accessToken);
assert.equal((await signup(`a${run}@t.com`)).status, 409, '중복 이메일');
assert.equal((await call('POST', '/auth/login', { email: `a${run}@t.com`, password: 'wrong-pass' })).status, 401);
const login = await call('POST', '/auth/login', { email: `a${run}@t.com`, password: 'password1' });
assert.equal(login.status, 201); const tokenA = login.body.accessToken;

// 3) 토큰 없이는 접근 불가
assert.equal((await call('GET', '/weights')).status, 401);
assert.equal((await call('GET', '/weights', undefined, 'fake.token.value')).status, 401);

// 4) 내 정보와 입력 범위
const me = await call('GET', '/users/me', undefined, tokenA);
assert.equal(me.status, 200); assert.equal(me.body.passwordHash, undefined, '비밀번호 해시 노출 금지');
assert.equal((await call('PATCH', '/users/me', { heightCm: 99 }, tokenA)).status, 400, '키 범위');
assert.equal((await call('PATCH', '/users/me', { birthDate: `${new Date().getFullYear() - 10}-01-01` }, tokenA)).status, 400, '만 14세 미만');
assert.equal((await call('PATCH', '/users/me', { heightCm: 170, gender: '여', birthDate: '2000-05-05' }, tokenA)).status, 200);

// 5) 체중: 범위, 하루 한 번(덮어쓰기), 남의 기록 차단
assert.equal((await call('POST', '/weights', { weight: 10, recordedDate: '2026-11-20' }, tokenA)).status, 400, '체중 범위');
const w1 = await call('POST', '/weights', { weight: 65, recordedDate: '2026-11-20', userId: 999 }, tokenA);
const w2 = await call('POST', '/weights', { weight: 64, recordedDate: '2026-11-20' }, tokenA);
assert.equal(w1.body.id, w2.body.id, '같은 날은 덮어쓰기');
assert.equal(w1.body.userId, me.body.id, 'body의 userId는 무시하고 토큰의 유저로 저장');
const b = await signup(`b${run}@t.com`); const tokenB = b.body.accessToken;
assert.equal((await call('GET', `/weights/${w1.body.id}`, undefined, tokenB)).status, 404, '남의 기록');
assert.equal((await call('DELETE', `/weights/${w1.body.id}`, undefined, tokenB)).status, 404);
assert.equal((await call('GET', '/weights', undefined, tokenB)).body.length, 0, '내 기록만 목록에');

// 6) 탈퇴하면 로그인 불가
assert.equal((await call('DELETE', '/users/me', undefined, tokenA)).status, 200);
assert.equal((await call('POST', '/auth/login', { email: `a${run}@t.com`, password: 'password1' })).status, 401);

console.log('인증 스모크 테스트 통과');
