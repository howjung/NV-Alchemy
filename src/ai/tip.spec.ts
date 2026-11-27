import { pickTip } from './tip';

const goal = { calories: 2000, carbs: 210, protein: 105, fat: 52 };

describe('AI 한마디 고르기', () => {
  it('기록이 없으면 기록을 권한다', () => {
    expect(pickTip(null, goal).kind).toBe('none');
  });

  it('칼로리를 넘으면 넘은 양을 알려 준다', () => {
    const tip = pickTip({ calories: 2300, carbs: 0, protein: 0, fat: 0 }, goal);
    expect(tip).toMatchObject({ kind: 'over', title: '목표보다 300kcal 더 먹었어요' });
  });

  it('가장 많이 모자란 영양소를 고른다', () => {
    const tip = pickTip({ calories: 900, carbs: 150, protein: 30, fat: 40 }, goal);
    expect(tip).toMatchObject({ kind: 'protein', title: '단백질이 75g 부족해요' });
    expect(pickTip({ calories: 900, carbs: 20, protein: 100, fat: 40 }, goal).kind).toBe('carbs');
  });

  it('모두 거의 채웠으면 균형이 좋다고 한다', () => {
    expect(pickTip({ calories: 1990, carbs: 200, protein: 100, fat: 50 }, goal).kind).toBe('balanced');
  });
});
