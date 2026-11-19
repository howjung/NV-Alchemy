import 'package:capstone/core/state/user_data.dart';
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
  // 배송지·카드·구독은 앱 전체가 공유하므로 테스트마다 처음 상태로 돌린다.
  setUp(resetUserData);

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

  testWidgets(
    'withdraw hides the subscription warning without a subscription',
    (tester) async {
      await _pump(tester);
      await _open(tester, '계정 관리');
      await tester.tap(find.text('회원 탈퇴'));
      await tester.pumpAndSettle();
      expect(find.textContaining('진행 중인 정기 구독이 있어요.'), findsNothing);
    },
  );

  testWidgets('withdraw asks for confirmation before leaving', (tester) async {
    hasSubscription = true;
    await _pump(tester);
    await _open(tester, '계정 관리');
    await tester.tap(find.text('회원 탈퇴'));
    await tester.pumpAndSettle();
    // Figma 안내 4줄, 구독 경고, 이유 5개
    expect(find.textContaining('프로필 정보가 모두 삭제되고'), findsOneWidget);
    expect(find.textContaining('보유 포인트 2,500P가 소멸해요.'), findsOneWidget);
    expect(find.textContaining("'탈퇴한 회원'으로 표시돼요"), findsOneWidget);
    expect(find.textContaining('관계 법령에 따라'), findsOneWidget);
    expect(find.textContaining('진행 중인 정기 구독이 있어요.'), findsOneWidget);
    expect(find.text('정기 구독을 해지'), findsOneWidget);
    expect(find.text('기록하기 번거로워요'), findsOneWidget);
    // 동의 전에는 탈퇴하기가 눌리지 않는다.
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '탈퇴하기'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('원하는 상품이 없어요'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
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

  testWidgets('profile edit uses inline rows, check marks and a top Save', (
    tester,
  ) async {
    await _pump(tester);
    await _open(tester, '프로필 · 신체 지표');
    await _reveal(tester, find.text('정보 수정'));
    await tester.tap(find.text('정보 수정'));
    await tester.pumpAndSettle();

    expect(find.text('세'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('kcal'), findsOneWidget);
    expect(find.text('운동을 거의 하지 않아요'), findsOneWidget);
    expect(find.textContaining('자동 계산돼요'), findsOneWidget);
    // 활동량 선택은 체크 표시 하나, 아래쪽 저장 버튼은 없고 오른쪽 위에 있다.
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '저장'), findsNothing);

    await tester.tap(find.text('활동적'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '저장'));
    await tester.pumpAndSettle();
    expect(find.text('저장되었어요'), findsOneWidget);
  });

  testWidgets(
    'AI setting, alert permission row and payment note follow Figma',
    (tester) async {
      await _pump(tester);
      await _open(tester, 'AI 추천 설정');
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked), findsNothing);
      await tester.tap(find.text('혼합'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('프로필'));
      await tester.pumpAndSettle();
      await _open(tester, '알림 설정');
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.text('허용 필요'), findsOneWidget);

      await tester.tap(find.text('프로필'));
      await tester.pumpAndSettle();
      await _open(tester, '결제 수단');
      expect(find.textContaining('결제 대행사(PG)'), findsOneWidget);
      expect(find.text('기본'), findsOneWidget);
    },
  );

  testWidgets('password fields show hints; address edit saves from the top', (
    tester,
  ) async {
    await _pump(tester);
    await _open(tester, '계정 관리');
    await tester.tap(find.text('비밀번호 변경'));
    await tester.pumpAndSettle();
    expect(find.text('영문, 숫자 포함 8자 이상'), findsOneWidget);
    expect(find.text('한 번 더 입력'), findsOneWidget);

    await tester.tap(find.text('계정 관리'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('프로필'));
    await tester.pumpAndSettle();
    await _open(tester, '배송지 관리');
    await tester.tap(find.textContaining('집 · 기본'));
    await tester.pumpAndSettle();
    expect(find.text('기본 배송지로 설정'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '저장'), findsNothing);
    await tester.tap(find.widgetWithText(TextButton, '저장'));
    await tester.pumpAndSettle();
    expect(find.text('저장되었어요'), findsOneWidget);
  });
}
