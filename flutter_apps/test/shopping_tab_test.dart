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

    await tester.tap(find.byTooltip('장바구니'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.byTooltip('장바구니'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('수량 줄이기'));
    await tester.pumpAndSettle();
    expect(find.text('상품을 뺄까요?'), findsOneWidget);
  });
}
