const MILESTONES = [3, 7, 14, 30, 50, 100]; // 보상 단계(PRD 4.4)
const DAY_MS = 86_400_000;

// 서버 시계가 어느 나라 기준이든 "한국의 오늘"을 'YYYY-MM-DD'로 돌려준다
export function todayKst(now = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Seoul' }).format(now);
}

// 날짜를 하루에 1씩 커지는 번호로 바꾼다
const dayNumber = (date: string) => Date.parse(date) / DAY_MS;

export function calcStreak(dates: string[], today: string) {
  const recorded = new Set(dates.map(dayNumber));
  const now = dayNumber(today);
  const recordedToday = recorded.has(now);

  // 오늘 아직 기록하지 않았으면 어제부터 센다(오늘이 끝나기 전까지는 유지)
  let day = recordedToday ? now : now - 1;
  let days = 0;
  while (recorded.has(day)) {
    days++;
    day--;
  }

  return {
    days,
    recordedToday,
    broken: days === 0 && recorded.size > 0, // 처음 쓰는 사람은 끊긴 것이 아니다
    nextMilestone: MILESTONES.find((m) => m > days) ?? null,
  };
}
