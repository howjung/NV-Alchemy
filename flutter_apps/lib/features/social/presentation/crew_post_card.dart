import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_overlays.dart';
import 'post_detail_screen.dart';
import 'post_moderation.dart';

/// 크루 메인의 피드 게시물 한 개 (Figma SOC-03). 인스타그램 피드처럼
/// 머리글, 사진, 좋아요·댓글·불꽃 보내기, 캡션, 시간 순서로 쌓인다.
class CrewPostCard extends StatelessWidget {
  const CrewPostCard({
    required this.postId,
    required this.photoIndex,
    required this.author,
    required this.shortName,
    required this.meta,
    required this.caption,
    required this.time,
    required this.store,
    required this.onOpen,
    super.key,
  });

  final int postId;
  final int photoIndex;
  final String author;

  /// 아바타 안과 캡션 앞에 쓰는 짧은 이름 (예: 김민지 → 민지).
  final String shortName;
  final String meta;
  final String caption;
  final String time;
  final PostInteractionStore store;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFEAF1ED),
            child: Text(
              shortName,
              style: const TextStyle(fontSize: 12, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  meta,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          AppMenu<String>(
            tooltip: '게시물 메뉴',
            width: 164,
            items: postMenuItems(mine: postId < 0),
            onSelected: (action) =>
                handlePostMenu(context, action: action, postId: postId),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.more_horiz, color: AppTheme.muted),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 362 / 300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SvgPicture.asset(
                'assets/images/social_$photoIndex.svg',
                fit: BoxFit.cover,
              ),
              Semantics(
                button: true,
                label: '게시물 상세 보기',
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(onTap: onOpen),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 4),
      PostActionRow(store: store, postId: postId),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$shortName  ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: caption),
          ],
        ),
        style: const TextStyle(color: AppTheme.primary, fontSize: 14),
      ),
      const SizedBox(height: 4),
      Text(time, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
    ],
  );
}
