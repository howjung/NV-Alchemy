import 'package:capstone/features/social/presentation/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('post detail follows the Figma 07 layout', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: PostDetailScreen(photoIndex: 0)),
    );

    expect(find.text('프로필 이름'), findsOneWidget);
    expect(find.text('오운완'), findsOneWidget);
    expect(find.text('3분 전'), findsOneWidget);
    expect(find.text('불꽃 보내기'), findsOneWidget);

    // Figma 좌표에서 상태바 59px를 뺀 값.
    final photo = tester.getRect(find.byType(AspectRatio));
    expect(photo.size, const Size(362, 362));
    expect(photo.topLeft, const Offset(20, 141));

    final pill = tester.getRect(
      find.ancestor(of: find.text('불꽃 보내기'), matching: find.byType(Container)),
    );
    expect(pill.topLeft, const Offset(272, 523));
    expect(pill.size, const Size(110, 38));
  });

  testWidgets('back button pops, menu lists the two Figma items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => const PostDetailScreen(photoIndex: 3),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('게시물 메뉴'));
    await tester.pumpAndSettle();
    expect(find.text('관심 없음'), findsOneWidget);
    expect(find.text('신고하기'), findsOneWidget);

    await tester.tap(find.text('관심 없음'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });
}
