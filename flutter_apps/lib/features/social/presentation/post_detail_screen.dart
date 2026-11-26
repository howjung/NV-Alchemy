import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/state/moderation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_overlays.dart';
import 'post_moderation.dart';

// Figma에 없는 상태(채워진 하트, 보낸 뒤 불꽃 버튼, 댓글 시트)에 쓰는 임시 색.
const _heart = Color(0xFFD9534F);
const _soft = Color(0xFFEDF3EF);

class PostComment {
  const PostComment(this.author, this.text);

  final String author;
  final String text;
}

class _PostState {
  _PostState({this.likes = 12, List<PostComment>? comments})
    : comments =
          comments ??
          [
            const PostComment('프로필 이름', '오늘도 화이팅!'),
            const PostComment('프로필 이름', '식단 맛있어 보여요'),
          ];

  bool liked = false;
  int likes;
  bool flameSent = false;
  final List<PostComment> comments;
}

/// 게시물별 좋아요·불꽃·댓글 상태. 서버가 없어 앱 실행 중에만 유지된다.
/// PRD: 좋아요는 게시물당 사용자 1회 토글, 불꽃 보내기는 게시물당 1회(제안값, N13).
///
/// 게시물 번호가 0 이상이면 Figma 샘플 값(좋아요 12, 댓글 2)으로 시작하고,
/// 음수(사용자가 새로 올린 게시물)는 빈 상태로 시작한다.
class PostInteractionStore extends ChangeNotifier {
  final _posts = <int, _PostState>{};

  _PostState _of(int post) => _posts.putIfAbsent(
    post,
    () => post < 0 ? _PostState(likes: 0, comments: []) : _PostState(),
  );

  /// 샘플 게시물의 처음 값을 정한다. 화면이 그려지기 전에 부른다.
  void seed(
    int post, {
    required int likes,
    required List<PostComment> comments,
  }) => _posts[post] = _PostState(likes: likes, comments: [...comments]);

  bool isLiked(int post) => _of(post).liked;
  int likeCount(int post) => _of(post).likes;
  bool isFlameSent(int post) => _of(post).flameSent;
  List<PostComment> comments(int post) => List.unmodifiable(_of(post).comments);

  void clear() {
    _posts.clear();
    notifyListeners();
  }

  void toggleLike(int post) {
    final state = _of(post);
    state.liked = !state.liked;
    state.likes += state.liked ? 1 : -1;
    notifyListeners();
  }

  void sendFlame(int post) {
    final state = _of(post);
    if (state.flameSent) return;
    state.flameSent = true;
    notifyListeners();
  }

  void addComment(int post, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _of(post).comments.add(PostComment('나', trimmed));
    notifyListeners();
  }
}

/// 소셜 탭과 프로필 · 게시물 관리가 함께 쓰는 좋아요·댓글 상태.
/// Figma 크루 피드의 두 번째 게시물(좋아요 7, 댓글 3)로 시작한다.
final postStore = PostInteractionStore()
  ..seed(1, likes: 7, comments: _seedComments);

const _seedComments = [
  PostComment('프로필 이름', '단백질 챙기기 대단해요'),
  PostComment('프로필 이름', '저도 따라 해볼래요'),
  PostComment('프로필 이름', '내일도 같이 인증해요'),
];

/// 처음 상태로 되돌린다(테스트·회원 탈퇴 후).
void resetPostStore() => postStore
  ..clear()
  ..seed(1, likes: 7, comments: _seedComments);

/// 소셜 07 게시물 상세.
class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({
    required this.photoIndex,
    required this.store,
    this.postId,
    this.caption = '오운완',
    this.time = '3분 전',
    super.key,
  });

  final int photoIndex;
  final String caption;
  final String time;
  final PostInteractionStore store;

  /// 좋아요·댓글 상태를 찾는 번호. 없으면 [photoIndex]를 쓴다.
  final int? postId;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 402),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              SizedBox(
                height: 66,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '뒤로',
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      constraints: const BoxConstraints.tightFor(
                        width: 44,
                        height: 44,
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // 메뉴 오른쪽 끝을 버튼 오른쪽 끝에, 위쪽을 버튼 안쪽에 맞춘다.
                    AppMenu<String>(
                      tooltip: '게시물 메뉴',
                      offset: const Offset(-88, -14),
                      width: 164,
                      items: postMenuItems(mine: (postId ?? photoIndex) < 0),
                      onSelected: (action) => handlePostMenu(
                        context,
                        action: action,
                        postId: postId ?? photoIndex,
                        onDone: () => Navigator.maybePop(context),
                      ),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.more_horiz, color: AppTheme.muted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.border,
                      child: Icon(Icons.person, color: Colors.white, size: 35),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      authorOf(postId ?? photoIndex),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SvgPicture.asset(
                    'assets/images/social_$photoIndex.svg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 행 높이 44(터치 영역) 안에서 불꽃 버튼(38)이 Figma 위치에 오도록 17.
              const SizedBox(height: 17),
              PostActionRow(store: store, postId: postId ?? photoIndex),
              const SizedBox(height: 12),
              Text(
                caption,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 좋아요·댓글·불꽃 보내기 행. 게시물 상세와 크루 피드가 함께 쓴다.
class PostActionRow extends StatelessWidget {
  const PostActionRow({required this.store, required this.postId, super.key});

  final PostInteractionStore store;
  final int postId;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => _ActionRow(
      liked: store.isLiked(postId),
      likes: store.likeCount(postId),
      comments: store.comments(postId).length,
      flameSent: store.isFlameSent(postId),
      onLike: () => store.toggleLike(postId),
      onComment: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        constraints: const BoxConstraints(maxWidth: 402),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _CommentsSheet(post: postId, store: store),
      ),
      onFlame: () {
        store.sendFlame(postId);
        showAppToast(context, '불꽃을 보냈어요.');
      },
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.liked,
    required this.likes,
    required this.comments,
    required this.flameSent,
    required this.onLike,
    required this.onComment,
    required this.onFlame,
  });

  final bool liked;
  final int likes;
  final int comments;
  final bool flameSent;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onFlame;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: Row(
      children: [
        const SizedBox(width: 2),
        _CountButton(
          label: liked ? '좋아요 취소' : '좋아요',
          selected: liked,
          count: likes,
          onTap: onLike,
          icon: liked
              ? const SizedBox(
                  width: 17.8,
                  height: 16.6,
                  child: FittedBox(child: Icon(Icons.favorite, color: _heart)),
                )
              : SvgPicture.asset('assets/images/social_like.svg'),
        ),
        const SizedBox(width: 14),
        _CountButton(
          label: '댓글 보기',
          count: comments,
          onTap: onComment,
          icon: SvgPicture.asset('assets/images/social_comment.svg'),
        ),
        const Spacer(),
        Semantics(
          button: true,
          enabled: !flameSent,
          label: flameSent ? '불꽃 보냄' : '불꽃 보내기',
          excludeSemantics: true,
          child: Material(
            key: const Key('flame-button'),
            color: flameSent ? _soft : Colors.white,
            shape: const StadiumBorder(
              side: BorderSide(color: AppTheme.border),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: flameSent ? null : onFlame,
              child: SizedBox(
                width: 110,
                height: 38,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.6),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/social_flame.svg',
                        width: 10.8,
                        height: 15.75,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          flameSent ? '불꽃 보냄' : '불꽃 보내기',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _CountButton extends StatelessWidget {
  const _CountButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final Widget icon;
  final int count;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '$label, $count',
    excludeSemantics: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 7),
              Text(
                '$count',
                style: const TextStyle(color: AppTheme.primary, fontSize: 15),
              ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.post, required this.store});

  final int post;
  final PostInteractionStore store;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.store.addComment(widget.post, _controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .6,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '댓글',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.store,
              builder: (context, _) {
                final comments = widget.store.comments(widget.post);
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  itemCount: comments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.border,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comments[i].author,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              comments[i].text,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      hintText: '댓글을 입력하세요.',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => TextButton(
                    onPressed: value.text.trim().isEmpty ? null : _submit,
                    child: const Text(
                      '등록',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
