import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capstone/core/state/user_data.dart';
import 'package:capstone/features/auth/presentation/auth_screens.dart';
import 'package:capstone/features/onboarding/presentation/onboarding_screens.dart';

void main() {
  setUp(resetUserData);

  testWidgets('login blocks empty input', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('로그인').last);
    await tester.pump();
    expect(find.text('이메일과 비밀번호를 확인해 주세요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('sign up checks password rule and required terms', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'abc');
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pump();
    expect(find.text('비밀번호는 영문, 숫자 포함 8자 이상이에요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('onboarding rejects non-numeric body values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BodyGoalOnboardingScreen()),
    );
    await tester.enterText(find.byType(TextField).at(0), '');
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pump();
    expect(find.text('키와 체중을 숫자로 입력해 주세요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
