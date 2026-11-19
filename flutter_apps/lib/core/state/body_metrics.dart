import 'user_data.dart';

// 프로필 값(userProfile)으로 계산하는 신체 지표. 식은 PRD 4.2(제안값)를 따른다.
double _num(String key, double fallback) =>
    double.tryParse(userProfile[key] ?? '') ?? fallback;

double get _weight => _num('weight', 74);
double get _height => _num('height', 175);

double get bmi => _weight / ((_height / 100) * (_height / 100));

String get bmiLabel => bmi < 18.5 ? '저체중' : (bmi < 23 ? '정상' : '과체중');

/// Mifflin-St Jeor
int get bmr {
  final base = 10 * _weight + 6.25 * _height - 5 * _num('age', 25);
  return (base + (userProfile['gender'] == '여성' ? -161 : 5)).round();
}

double get _activityFactor => switch (userProfile['activity']) {
  '비활동적' => 1.2,
  '활동적' => 1.55,
  _ => 1.375,
};

/// 활동량까지 반영한 권장 칼로리. 하한은 남성 1500, 여성 1200.
int get recommendedCalories {
  final floor = userProfile['gender'] == '여성' ? 1200 : 1500;
  final value = (bmr * _activityFactor).round();
  return value < floor ? floor : value;
}

/// 하루 목표 칼로리(프로필에 저장된 값, 없으면 권장값).
int get calorieGoal =>
    int.tryParse(userProfile['calories'] ?? '') ?? recommendedCalories;

/// 하루 물 권장량(L): 체중 1kg당 30ml.
double get waterLiters => _weight * 30 / 1000;

/// 하루 권장 탄수화물·단백질·지방(g). 비율은 Figma 예시값에 맞춘 임시 비율.
({int carbs, int protein, int fat}) get macroGoals => (
  carbs: (calorieGoal * .42 / 4).round(),
  protein: (calorieGoal * .21 / 4).round(),
  fat: (calorieGoal * .235 / 9).round(),
);

/// 목표 체중까지 남은 kg(절댓값)과 방향.
({double remaining, String verb}) get goalGap {
  final diff = _weight - _num('goal', 68);
  return (remaining: diff.abs(), verb: diff > 0 ? '감량' : '증량');
}

/// 시작 체중에서 목표까지 얼마나 왔는지(0~1).
double get goalProgress {
  final start = _num('startWeight', 77.3);
  final goal = _num('goal', 68);
  if (start == goal) return 1;
  return ((_weight - start) / (goal - start)).clamp(0.0, 1.0);
}
