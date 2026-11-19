import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_overlays.dart';

/// 소셜 07 게시물 상세. Figma에서 눌리는 곳은 뒤로 가기와 게시물 메뉴뿐이다.
class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({required this.photoIndex, super.key});

  final int photoIndex;

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
                    const AppMenu<String>(
                      tooltip: '게시물 메뉴',
                      offset: Offset(-88, -14),
                      items: [
                        AppMenuItem('hide', '관심 없음'),
                        AppMenuItem('report', '신고하기'),
                      ],
                      child: SizedBox(
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
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.border,
                      child: Icon(Icons.person, color: Colors.white, size: 35),
                    ),
                    SizedBox(width: 14),
                    Text(
                      '프로필 이름',
                      style: TextStyle(
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
              const SizedBox(height: 20),
              const _ActionRow(),
              const SizedBox(height: 15),
              const Text(
                '오운완',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '3분 전',
                style: TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  static const _count = TextStyle(color: AppTheme.primary, fontSize: 15);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: Row(
      children: [
        const SizedBox(width: 2),
        SvgPicture.asset('assets/images/social_like.svg'),
        const SizedBox(width: 7),
        const Text('12', style: _count),
        const SizedBox(width: 16),
        SvgPicture.asset('assets/images/social_comment.svg'),
        const SizedBox(width: 7),
        const Text('2', style: _count),
        const Spacer(),
        Container(
          width: 110,
          height: 38,
          padding: const EdgeInsets.only(left: 20.6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/social_flame.svg',
                width: 10.8,
                height: 15.75,
              ),
              const SizedBox(width: 5),
              const Flexible(
                child: Text(
                  '불꽃 보내기',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
