import 'package:capstone/core/state/moderation.dart';
import 'package:capstone/core/state/my_posts.dart';
import 'package:capstone/core/state/user_data.dart';
import 'package:capstone/features/profile/presentation/profile_tab.dart';
import 'package:capstone/features/social/presentation/post_detail_screen.dart';
import 'package:capstone/features/social/presentation/social_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget tab) async {
  tester.view.physicalSize = const Size(402, 874);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.toString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: tab)));
}

void main() {
  setUp(resetUserData);

  testWidgets('post can be uploaded from the feed without a crew', (
    tester,
  ) async {
    await _pump(tester, const SocialTab(initialView: SocialView.feed));
    await tester.tap(find.byTooltip('게시물 올리기'));
    await tester.pumpAndSettle();

    // 크루가 없으면 "크루만 공개"는 고를 수 없다.
    await tester.tap(find.byTooltip('공개 설정'));
    await tester.pumpAndSettle();
    expect(find.text('크루만 공개'), findsNothing);
    await tester.tap(find.text('비공개').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '저녁 샐러드');
    await tester.pump();
    await tester.tap(find.text('업로드'));
    await tester.pumpAndSettle();

    final post = myPosts.value.single;
    expect(
      (post.caption, post.visibility, post.crew),
      ('저녁 샐러드', '비공개', false),
    );
    expect(find.text('게시물을 올렸어요.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('explore explains a full crew', (tester) async {
    await _pump(tester, const SocialTab(initialView: SocialView.explore));
    await tester.tap(find.text('정원 마감'));
    await tester.pump();
    expect(find.text('정원이 가득 찬 크루예요.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('one crew per user: explore blocks a second crew', (
    tester,
  ) async {
    await _pump(tester, const SocialTab(initialView: SocialView.crew));
    await tester.tap(find.text('크루 탐색하기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('크루 생성'));
    await tester.tap(find.text('크루 생성'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '내 크루');
    await tester.tap(find.widgetWithText(FilledButton, '크루 생성'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('크루 탐색'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('참가 신청').first);
    await tester.pump();
    expect(find.text('이미 크루에 가입했어요. 탈퇴한 뒤 신청할 수 있어요.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('profile post management edits visibility and deletes', (
    tester,
  ) async {
    addMyPost(caption: '아침 오트밀', meal: '아침', visibility: '공개', crew: false);
    await _pump(tester, const ProfileTab(initialView: ProfileView.posts));
    expect(find.text('아침 오트밀'), findsOneWidget);
    expect(find.text('아침 · 공개'), findsOneWidget);

    await tester.tap(find.byTooltip('게시물 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('비공개로 변경'));
    await tester.pumpAndSettle();
    expect(find.text('아침 · 비공개'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));

    await tester.tap(find.byTooltip('게시물 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();
    expect(myPosts.value, isEmpty);
    expect(find.text('올린 게시물이 없어요.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('social tab opens on the feed by default', (tester) async {
    await _pump(tester, const SocialTab());
    expect(find.byTooltip('게시물 올리기'), findsOneWidget);
    expect(find.text('크루에 가입되지 않았습니다.'), findsNothing);
  });

  testWidgets('report asks for a reason, hides the post, blocks duplicates', (
    tester,
  ) async {
    await _pump(
      tester,
      PostDetailScreen(photoIndex: 3, postId: 3, store: postStore),
    );
    await tester.tap(find.byTooltip('게시물 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('신고하기'));
    await tester.pumpAndSettle();
    expect(find.text('신고 사유를 선택해 주세요'), findsOneWidget);
    await tester.tap(find.text('스팸·광고'));
    await tester.pumpAndSettle();
    expect(reportedPosts, contains(3));
    expect(isPostVisible(3), isFalse);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('blocking an author hides posts; profile can unblock', (
    tester,
  ) async {
    await _pump(
      tester,
      PostDetailScreen(photoIndex: 3, postId: 3, store: postStore),
    );
    await tester.tap(find.byTooltip('게시물 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('작성자 차단'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('차단하기'));
    await tester.pumpAndSettle();
    expect(blockedUsers.value, ['김민지']);
    expect(isPostVisible(5), isFalse); // 같은 작성자의 다른 글도 가려진다.
    await tester.pump(const Duration(seconds: 3));

    await _pump(tester, const ProfileTab(initialView: ProfileView.blocked));
    expect(find.text('김민지'), findsOneWidget);
    await tester.tap(find.text('해제'));
    await tester.pump();
    expect(blockedUsers.value, isEmpty);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('tapping a managed post opens its detail', (tester) async {
    addMyPost(caption: '점심 닭가슴살', meal: '점심', visibility: '공개', crew: false);
    await _pump(tester, const ProfileTab(initialView: ProfileView.posts));
    await tester.tap(find.text('점심 닭가슴살'));
    await tester.pumpAndSettle();
    expect(find.text('나'), findsOneWidget); // 상세의 작성자
    expect(find.text('점심 닭가슴살'), findsOneWidget);
    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.text('게시물 관리'), findsOneWidget);
  });
}
