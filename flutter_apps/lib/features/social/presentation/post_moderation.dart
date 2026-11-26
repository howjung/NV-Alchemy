import 'package:flutter/material.dart';

import '../../../core/state/moderation.dart';
import '../../../core/state/my_posts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_overlays.dart';

/// 게시물 메뉴 항목. 내 글은 삭제만, 남의 글은 관심 없음·신고·차단.
List<AppMenuItem<String>> postMenuItems({required bool mine}) => mine
    ? const [AppMenuItem('delete', '삭제', danger: true)]
    : const [
        AppMenuItem('hide', '관심 없음'),
        AppMenuItem('report', '신고하기'),
        AppMenuItem('block', '작성자 차단', danger: true),
      ];

/// 게시물 메뉴에서 고른 동작을 처리한다. 처리 후 [onDone]을 부른다
/// (상세 화면은 목록으로 돌아간다).
Future<void> handlePostMenu(
  BuildContext context, {
  required String action,
  required int postId,
  VoidCallback? onDone,
}) async {
  final author = authorOf(postId);
  switch (action) {
    case 'hide':
      hidePost(postId);
      showAppToast(context, '관심 없는 게시물로 표시했어요.');
    case 'report':
      if (reportedPosts.contains(postId)) {
        showAppToast(context, '이미 신고한 게시물이에요.');
        return;
      }
      final reason = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.white,
        constraints: const BoxConstraints(maxWidth: 402),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const _ReportSheet(),
      );
      if (reason == null || !context.mounted) return;
      reportedPosts.add(postId);
      hidePost(postId); // 신고한 글은 내 화면에서도 가린다.
      showAppToast(context, '신고가 접수되었어요.');
    case 'block':
      final ok = await showConfirmPopup(
        context,
        title: '$author님을 차단할까요?',
        message: '차단하면 이 사용자의 게시물과 댓글이 보이지 않아요. 프로필 · 차단한 사용자에서 해제할 수 있어요.',
        confirmLabel: '차단하기',
      );
      if (!ok || !context.mounted) return;
      blockUser(author);
      showAppToast(context, '$author님을 차단했어요.');
    case 'delete':
      final ok = await showConfirmPopup(
        context,
        title: '게시물을 삭제할까요?',
        message: '삭제하면 되돌릴 수 없어요.',
        confirmLabel: '삭제하기',
      );
      if (!ok || !context.mounted) return;
      deleteMyPost(postId);
      showAppToast(context, '게시물을 삭제했어요.');
    default:
      return;
  }
  onDone?.call();
}

class _ReportSheet extends StatelessWidget {
  const _ReportSheet();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '신고 사유를 선택해 주세요',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          for (final reason in reportReasons)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(reason),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.muted),
              onTap: () => Navigator.pop(context, reason),
            ),
        ],
      ),
    ),
  );
}
