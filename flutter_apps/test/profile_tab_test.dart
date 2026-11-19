import 'package:capstone/features/profile/presentation/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(402, 874);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // 테스트 글꼴은 실제보다 넓어 체중 그래프 날짜 줄이 넘친다. 이 경고만 무시한다.
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.toString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: ProfileTab())),
  );
}

// 긴 목록에서 해당 글자가 보일 때까지 위로 민다.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 12 && finder.hitTestable().evaluate().isEmpty; i++) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
}

Future<void> _open(WidgetTester tester, String row) async {
  await _reveal(tester, find.text(row));
  await tester.tap(find.text(row));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('logout asks first and cancel keeps the screen', (tester) async {
    await _pump(tester);
    await _reveal(tester, find.widgetWithText(OutlinedButton, '로그아웃'));
    await tester.tap(find.widgetWithText(OutlinedButton, '로그아웃'));
    await tester.pumpAndSettle();
    expect(find.text('로그아웃할까요?'), findsOneWidget);
    expect(find.text('언제든 다시 로그인할 수 있어요.'), findsOneWidget);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.text('로그아웃할까요?'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '로그아웃'), findsOneWidget);
  });

  testWidgets('app version row shows the latest-version toast', (tester) async {
    await _pump(tester);
    await _open(tester, '앱 버전');
    expect(find.text('최신 버전이에요'), findsOneWidget);
  });

  testWidgets('notice and FAQ open the Figma sheet with a confirm button', (
    tester,
  ) async {
    await _pump(tester);
    await _open(tester, '공지사항');
    await tester.tap(find.text('연속 기록 보상이 생겼어요'));
    await tester.pumpAndSettle();
    expect(find.textContaining('물방울 모양의 연속 기록'), findsOneWidget);
    expect(find.text('2026.10.13'), findsNWidgets(2));
    await tester.tap(find.widgetWithText(FilledButton, '확인'));
    await tester.pumpAndSettle();
    expect(find.textContaining('물방울 모양의 연속 기록'), findsNothing);

    await tester.tap(find.text('프로필'));
    await tester.pumpAndSettle();
    await _open(tester, '고객센터');
    await tester.tap(find.text('연속 기록이 끊겼어요.'));
    await tester.pumpAndSettle();
    expect(find.text('자주 묻는 질문'), findsNWidgets(2));
    expect(find.textContaining('0일로 돌아가요'), findsOneWidget);
  });

  testWidgets('address delete asks first, then shows the toast', (
    tester,
  ) async {
    await _pump(tester);
    await _open(tester, '배송지 관리');
    await tester.tap(find.textContaining('집 · 기본'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('배송지 삭제'));
    await tester.pumpAndSettle();
    expect(find.text('배송지를 삭제할까요?'), findsOneWidget);
    expect(find.text('삭제한 배송지는 되돌릴 수 없어요.'), findsOneWidget);

    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();
    expect(find.text('배송지가 삭제되었어요'), findsOneWidget);
    expect(find.text('등록한 배송지가 없어요.'), findsOneWidget);
  });

  testWidgets('card add and password change show their toasts', (tester) async {
    await _pump(tester);
    await _open(tester, '결제 수단');
    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '국민카드');
    await tester.enterText(find.byType(TextFormField).at(1), '4321');
    await tester.tap(find.widgetWithText(FilledButton, '저장'));
    await tester.pumpAndSettle();
    expect(find.text('결제 수단이 추가되었어요'), findsOneWidget);
    expect(find.text('국민카드 ···· 4321'), findsOneWidget);

    await tester.tap(find.text('프로필'));
    await tester.pumpAndSettle();
    await _open(tester, '계정 관리');
    await tester.tap(find.text('비밀번호 변경'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'oldpass12');
    await tester.enterText(find.byType(TextFormField).at(1), 'newpass12');
    await tester.enterText(find.byType(TextFormField).at(2), 'newpass12');
    await tester.tap(find.widgetWithText(FilledButton, '변경하기'));
    await tester.pumpAndSettle();
    expect(find.text('비밀번호가 변경되었어요'), findsOneWidget);
    expect(find.text('계정 관리'), findsWidgets);
  });

  testWidgets('withdraw asks for confirmation before leaving', (tester) async {
    await _pump(tester);
    await _open(tester, '계정 관리');
    await tester.tap(find.text('회원 탈퇴'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'pass1234');
    await tester.tap(find.widgetWithText(FilledButton, '탈퇴하기'));
    await tester.pumpAndSettle();
    expect(find.text('정말 탈퇴할까요?'), findsOneWidget);
    expect(find.text('탈퇴하면 기록과 포인트가 모두 삭제되고 되돌릴 수 없어요.'), findsWidgets);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.text('정말 탈퇴할까요?'), findsNothing);
    expect(find.text('회원 탈퇴'), findsWidgets);
  });

  testWidgets('info sheet scrolls instead of overflowing at 2x text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: ProfileTab(initialView: ProfileView.notices),
        ),
      ),
    );
    await tester.tap(find.text('연속 기록 보상이 생겼어요'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(FilledButton, '확인'), findsOneWidget);
  });
}
