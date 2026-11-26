import 'package:capstone/features/social/presentation/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(PostInteractionStore store) =>
    MaterialApp(home: PostDetailScreen(photoIndex: 0, store: store));

void main() {
  testWidgets('post detail follows the Figma 07 layout', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = PostInteractionStore();
    addTearDown(store.dispose);

    await tester.pumpWidget(_app(store));

    expect(find.text('김민지'), findsOneWidget);
    expect(find.text('오운완'), findsOneWidget);
    expect(find.text('3분 전'), findsOneWidget);
    expect(find.text('불꽃 보내기'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // Figma 좌표에서 상태바 59px를 뺀 값.
    final photo = tester.getRect(find.byType(AspectRatio));
    expect(photo.size, const Size(362, 362));
    expect(photo.topLeft, const Offset(20, 141));

    final pill = tester.getRect(find.byKey(const Key('flame-button')));
    expect(pill.topLeft, const Offset(272, 523));
    expect(pill.size, const Size(110, 38));
  });

  testWidgets('like toggles once per user and updates the count', (
    tester,
  ) async {
    final store = PostInteractionStore();
    addTearDown(store.dispose);
    await tester.pumpWidget(_app(store));

    await tester.tap(find.bySemanticsLabel('좋아요, 12'));
    await tester.pump();
    expect(find.text('13'), findsOneWidget);
    expect(store.isLiked(0), isTrue);

    await tester.tap(find.bySemanticsLabel('좋아요 취소, 13'));
    await tester.pump();
    expect(find.text('12'), findsOneWidget);
    expect(store.isLiked(0), isFalse);
  });

  testWidgets('flame can be sent only once per post', (tester) async {
    final store = PostInteractionStore();
    addTearDown(store.dispose);
    await tester.pumpWidget(_app(store));

    await tester.tap(find.text('불꽃 보내기'));
    await tester.pump();
    expect(find.text('불꽃 보냄'), findsOneWidget);
    expect(find.text('불꽃을 보냈어요.'), findsOneWidget);
    expect(store.isFlameSent(0), isTrue);

    // 이미 보낸 뒤에는 눌러도 다시 보내지지 않는다.
    await tester.tap(find.text('불꽃 보냄'));
    await tester.pump();
    expect(find.text('불꽃 보냄'), findsOneWidget);
  });

  testWidgets('comments can be read and added, count follows', (tester) async {
    final store = PostInteractionStore();
    addTearDown(store.dispose);
    await tester.pumpWidget(_app(store));

    await tester.tap(find.bySemanticsLabel('댓글 보기, 2'));
    await tester.pumpAndSettle();
    expect(find.text('오늘도 화이팅!'), findsOneWidget);

    // 빈 입력은 등록할 수 없다.
    final submit = find.widgetWithText(TextButton, '등록');
    expect(tester.widget<TextButton>(submit).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  파이팅  ');
    await tester.pump();
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('파이팅'), findsOneWidget);
    expect(find.text('나'), findsOneWidget);
    expect(store.comments(0).length, 3);

    // 닫으면 댓글 수가 3으로 보인다.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('댓글 보기, 3'), findsOneWidget);
  });

  testWidgets('state survives closing and reopening the post', (tester) async {
    final store = PostInteractionStore();
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(photoIndex: 3, store: store),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('좋아요, 12'));
    await tester.pump();

    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('13'), findsOneWidget);
  });

  testWidgets('back button pops, menu lists the two Figma items', (
    tester,
  ) async {
    final store = PostInteractionStore();
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(photoIndex: 3, store: store),
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
    // 관심 없음을 누르면 상세가 닫히고 목록으로 돌아간다.
    expect(find.text('open'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
