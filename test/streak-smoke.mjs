// 실행 중인 서버에 요청을 보내 연속 기록 규칙을 확인한다. 사용: node test/streak-smoke.mjs
import assert from 'node:assert/strict';

const BASE = process.env.BASE_URL ?? 'http://localhost:3000';
let token;
const call = async (method, path, body) => {
  const res = await fetch(BASE + path, {
    method,
    headers: { 'content-type': 'application/json', ...(token && { authorization: `Bearer ${token}` }) },
    body: body && JSON.stringify(body),
  });
  return { status: res.status, body: await res.json().catch(() => null) };
};
const today = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Seoul' }).format(new Date());
const meal = (recordedDate) => ({ mealType: '아침', foodName: '테스트', calories: 100, recordedDate });

const signup = await call('POST', '/auth/signup', { email: `s${Date.now()}@t.com`, password: 'password1', nickname: '테스터' });
assert.equal(signup.status, 201); token = signup.body.accessToken;

try {
  assert.deepEqual((await call('GET', '/streak')).body, { days: 0, recordedToday: false, broken: false, nextMilestone: 3 });
  assert.equal((await call('POST', '/meals', meal('2020-01-01'))).status, 400, '지난 날짜 거절');

  const first = await call('POST', '/meals', meal(today));
  assert.equal(first.status, 201, '오늘 식단 저장');
  assert.equal((await call('POST', '/meals', meal(today))).status, 201, '같은 날 두 번째 식단');
  assert.equal((await call('GET', '/streak')).body.days, 1, '같은 날은 1일');

  assert.equal((await call('PATCH', `/meals/${first.body.id}`, { recordedDate: '2020-01-01' })).status, 400, '날짜 변경 거절');
  assert.equal((await call('PATCH', `/meals/${first.body.id}`, { calories: 200 })).status, 200, '내용 수정');

  assert.equal((await call('DELETE', `/meals/${first.body.id}`)).status, 200);
  assert.equal((await call('GET', '/streak')).body.recordedToday, true, '삭제해도 연속 기록 유지');
} finally {
  assert.equal((await call('DELETE', '/users/me')).status, 200, '테스트 계정 정리');
}

console.log('연속 기록 테스트 통과');
