import 'package:capstone/features/shopping/presentation/shopping_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(402, 874);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: ShoppingTab())),
  );
}

Future<void> _openCart(WidgetTester tester) async {
  await tester.tap(find.byTooltip('장바구니'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('장바구니 보기 ›'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('category and sort use the Figma dropdown menus', (tester) async {
    await _pump(tester);

    await tester.tap(find.byTooltip('카테고리 선택'));
    await tester.pumpAndSettle();
    for (final label in ['전체 상품', '샐러드', '밀키트', '도시락', '단백질']) {
      expect(find.text(label), findsWidgets);
    }
    await tester.tap(find.text('단백질').last);
    await tester.pumpAndSettle();
    expect(find.text('상품 0개'), findsOneWidget);

    await tester.tap(find.byTooltip('정렬 선택'));
    await tester.pumpAndSettle();
    expect(find.text('낮은 가격순'), findsOneWidget);
    expect(find.text('AI 적합도순'), findsOneWidget);
    await tester.tap(find.text('낮은 가격순'));
    await tester.pumpAndSettle();
    expect(find.text('낮은 가격순'), findsOneWidget);
  });

  testWidgets('adding shows a toast, removing asks first then toasts', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('장바구니 담기').first);
    await tester.pump();
    expect(find.text('장바구니에 담았어요'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await _openCart(tester);
    await tester.tap(find.text('빼기'));
    await tester.pumpAndSettle();
    expect(find.text('상품을 뺄까요?'), findsOneWidget);
    expect(find.text('수비드 닭가슴살 샐러드'), findsWidgets);

    // 취소하면 그대로 남는다.
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.text('장바구니가 비어 있어요.'), findsNothing);

    // 확인하면 빠지고 토스트가 뜬다.
    await tester.tap(find.text('빼기'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '빼기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('장바구니가 비어 있어요.'), findsOneWidget);
    expect(find.text('장바구니에서 뺐어요'), findsOneWidget);
  });

  testWidgets('decreasing the last item to zero also asks first', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('장바구니 담기').first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await _openCart(tester);

    await tester.tap(find.byTooltip('수량 줄이기'));
    await tester.pumpAndSettle();
    expect(find.text('상품을 뺄까요?'), findsOneWidget);
  });

  testWidgets('header cart dropdown is empty first, then lists items', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.byTooltip('장바구니'));
    await tester.pumpAndSettle();
    expect(find.text('장바구니가 비어 있어요'), findsOneWidget);
    await tester.tapAt(const Offset(5, 500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('장바구니 담기').first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.tap(find.byTooltip('장바구니'));
    await tester.pumpAndSettle();
    expect(find.text('수비드 닭가슴살 샐러드'), findsWidgets);
    expect(find.text('합계 6,900원'), findsOneWidget);
    expect(find.text('장바구니 보기 ›'), findsOneWidget);
  });

  testWidgets('product sheet shows sellers and adds to cart', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('수비드 닭가슴살 샐러드').first);
    await tester.pumpAndSettle();
    expect(find.text('식단공방 · 무료배송'), findsOneWidget);
    expect(find.text('푸드랩 마켓 · 배송비 2,500원'), findsOneWidget);
    expect(find.text('9,700원'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '장바구니 담기').last);
    await tester.pumpAndSettle();
    expect(find.text('장바구니에 담았어요'), findsOneWidget);
    expect(find.text('식단공방 · 무료배송'), findsNothing);
  });

  testWidgets('point sheet follows the 500P / 100P rule and applies', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('장바구니 담기').first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await _openCart(tester);
    await tester.tap(find.text('6,900원 주문하기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('0 P'));
    await tester.pumpAndSettle();
    expect(find.text('포인트 사용'), findsWidgets);
    expect(find.text('2,500P'), findsWidgets);
    expect(find.text('500P 사용하기'), findsOneWidget);

    await tester.tap(find.byTooltip('포인트 늘리기'));
    await tester.pump();
    expect(find.text('600P 사용하기'), findsOneWidget);
    expect(find.text('1,900P'), findsOneWidget);

    // 전액 사용은 보유 포인트(2,500P)와 결제 금액 중 작은 값, 100P 단위.
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('전액 사용'),
      ),
    );
    await tester.pump();
    expect(find.text('2,500P 사용하기'), findsOneWidget);
    expect(find.text('결제 금액에서 2,500원이 빠져요.'), findsOneWidget);

    await tester.tap(find.byTooltip('포인트 줄이기'));
    await tester.pump();
    expect(find.text('2,400P 사용하기'), findsOneWidget);

    await tester.tap(find.text('2,400P 사용하기'));
    await tester.pumpAndSettle();
    expect(find.text('2400 P'), findsOneWidget);
  });

  testWidgets('checkout payment menu switches the method', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('장바구니 담기').first);
    await tester.pump(const Duration(seconds: 3));
    await _openCart(tester);
    await tester.tap(find.text('6,900원 주문하기'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byTooltip('결제 수단 선택'));
    await tester.tap(find.byTooltip('결제 수단 선택'));
    await tester.pumpAndSettle();
    expect(find.text('새 카드 등록'), findsOneWidget);
    await tester.tap(find.text('계좌이체'));
    await tester.pumpAndSettle();
    expect(find.text('계좌이체'), findsOneWidget);

    // 새 카드 등록은 선택해도 바뀌지 않는다(입력 항목 미확정).
    await tester.tap(find.byTooltip('결제 수단 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('새 카드 등록'));
    await tester.pumpAndSettle();
    expect(find.text('계좌이체'), findsOneWidget);
  });

  testWidgets('toast sits above the cart bar instead of covering it', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('장바구니 담기').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final toast = tester.getRect(find.text('장바구니에 담았어요'));
    final bar = tester.getRect(find.text('장바구니 보기'));
    expect(toast.bottom, lessThan(bar.top));
  });

  testWidgets('search suggestions fill the field and filter by words', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.text('추천 검색어'), findsOneWidget);
    for (final word in ['닭가슴살 샐러드', '곤약밥 밀키트', '그릭요거트', '현미 도시락']) {
      expect(find.text(word), findsOneWidget);
    }

    await tester.tap(find.text('곤약밥 밀키트'));
    await tester.pumpAndSettle();
    expect(find.text('추천 검색어'), findsNothing);
    expect(find.text('상품 1개'), findsOneWidget);
    expect(find.text('곤약밥 소불고기 밀키트 2인'), findsOneWidget);
  });

  testWidgets('order detail shows Figma sections; cancel refunds points', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('장바구니 담기').first);
    await tester.pump(const Duration(seconds: 3));
    await _openCart(tester);
    await tester.tap(find.text('6,900원 주문하기'));
    await tester.pumpAndSettle();

    // 포인트 2,500P 전액 사용 -> 결제 4,400원.
    await tester.tap(find.text('전액 사용'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4,400원 결제하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('주문 내역 보기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('수비드 닭가슴살 샐러드'));
    await tester.pumpAndSettle();
    expect(find.text('주문 상세'), findsOneWidget);
    expect(find.text('2026.10.21 주문 · 1개'), findsOneWidget);
    expect(find.text('배송 준비 중'), findsOneWidget);
    expect(find.text('도착 예정'), findsOneWidget);
    expect(find.text('-2,500원'), findsOneWidget);
    expect(find.text('사용한 포인트 2500P'), findsOneWidget);

    await tester.ensureVisible(find.text('주문 취소 요청'));
    await tester.tap(find.text('주문 취소 요청'));
    await tester.pumpAndSettle();
    expect(find.text('주문을 취소할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.text('주문 상세'), findsOneWidget);

    await tester.tap(find.text('주문 취소 요청'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '주문 취소'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('주문 내역이 없어요.'), findsOneWidget);
    expect(find.text('주문을 취소했어요'), findsOneWidget);
  });
}
