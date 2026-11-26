import 'package:capstone/core/state/body_metrics.dart';
import 'package:capstone/core/state/user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(resetUserData);

  test('Figma sample: 25세 남성 175cm 74kg', () {
    expect(bmi.toStringAsFixed(1), '24.2');
    expect(bmiLabel, '과체중');
    expect(bmr, 1714);
    expect(waterLiters.toStringAsFixed(1), '2.2');
    expect(macroGoals, (carbs: 256, protein: 128, fat: 64));
    expect(goalGap.remaining.toStringAsFixed(1), '6.0');
    expect((goalProgress * 100).round(), 35);
  });

  test('activity factor, floor and gender', () {
    userProfile['activity'] = '활동적';
    expect(recommendedCalories, (1714 * 1.55).round());
    userProfile
      ..['gender'] = '여성'
      ..['weight'] = '35'
      ..['height'] = '140'
      ..['activity'] = '비활동적';
    expect(recommendedCalories, 1200);
  });

  test('gaining goal', () {
    userProfile['goal'] = '80';
    expect(goalGap.verb, '증량');
  });
}
