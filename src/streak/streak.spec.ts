import { calcStreak, todayKst } from './streak';

describe('연속 기록', () => {
  const today = '2026-11-01';

  it('기록이 없으면 0일이고 끊긴 것이 아니다', () => {
    expect(calcStreak([], today)).toEqual({ days: 0, recordedToday: false, broken: false, nextMilestone: 3 });
  });

  it('오늘까지 이어지면 오늘을 포함해 센다(달이 바뀌어도)', () => {
    const result = calcStreak(['2026-10-30', '2026-10-31', '2026-11-01'], today);
    expect(result).toEqual({ days: 3, recordedToday: true, broken: false, nextMilestone: 7 });
  });

  it('오늘 아직 기록하지 않아도 어제까지의 일수는 유지한다', () => {
    const result = calcStreak(['2026-10-30', '2026-10-31'], today);
    expect(result).toMatchObject({ days: 2, recordedToday: false, broken: false });
  });

  it('어제 기록이 없으면 끊긴다', () => {
    expect(calcStreak(['2026-10-29', '2026-10-30'], today)).toMatchObject({ days: 0, broken: true });
  });

  it('중간에 빈 날이 있으면 그 뒤부터만 센다', () => {
    expect(calcStreak(['2026-10-29', '2026-10-31', '2026-11-01'], today).days).toBe(2);
  });

  it('오늘 날짜는 한국 시간 기준이다', () => {
    expect(todayKst(new Date('2026-10-31T15:00:00Z'))).toBe('2026-11-01');
    expect(todayKst(new Date('2026-10-31T14:59:59Z'))).toBe('2026-10-31');
  });
});
