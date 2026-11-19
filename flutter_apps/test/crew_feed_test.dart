import 'package:capstone/features/social/presentation/social_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _joinCrew(WidgetTester tester) async {
  await tester.tap(find.text('크루 탐색하기'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('크루 생성'));
  await tester.tap(find.text('크루 생성'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, '테스트 크루');
  await tester.tap(find.widgetWithText(FilledButton, '크루 생성'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('crew feed shows Instagram-style posts with actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SocialTab())),
    );
    await _joinCrew(tester);

    // 첫 번째 크루원 게시물: 머리글, 좋아요·댓글 수, 불꽃 보내기, 캡션, 시간.
    expect(find.text('김민지'), findsOneWidget);
    expect(find.text('점심 · 2분 전 · 380 kcal'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('불꽃 보내기'), findsOneWidget);
    expect(find.textContaining('오운완 · 점심 380 kcal'), findsOneWidget);
    expect(find.text('2분 전'), findsOneWidget);

    await tester.tap(find.text('12'));
    await tester.pump();
    expect(find.text('13'), findsOneWidget);

    await tester.tap(find.text('불꽃 보내기'));
    await tester.pump();
    expect(find.text('불꽃 보냄'), findsOneWidget);
  });

  testWidgets('second sample post keeps its own counts', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SocialTab())),
    );
    await _joinCrew(tester);

    await tester.drag(
      find.byKey(const PageStorageKey('my-crew')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.text('7'));
    await tester.pump();
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('tapping a crew photo opens the detail with shared state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SocialTab())),
    );
    await _joinCrew(tester);

    await tester.tap(find.text('12'));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('게시물 상세 보기').first);
    await tester.pumpAndSettle();
    expect(find.text('오운완'), findsOneWidget);
    // 피드에서 누른 좋아요가 상세에도 그대로 보인다.
    expect(find.text('13'), findsOneWidget);
  });
}
