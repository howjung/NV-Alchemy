import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_screen_frame.dart';

const _title = TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold);
const _detail = TextStyle(color: AppTheme.muted, fontSize: 13);
const _alerts = [
  ('오늘', '식단 기록으로 5P를 받았어요', '오늘 아침 식단을 기록했어요', '오전 8:12'),
  ('오늘', '7일 연속 기록! 금빛 테두리를 받았어요', '성장 보상에서 확인해 보세요', '오전 8:12'),
  ('어제', '기록이 끊겨 물방울이 얼었어요', '오늘 식단을 기록하면 다시 녹아요', '어제'),
  ('어제', '칼로리 컷어스 크루에 가입됐어요', '크루장이 신청을 수락했어요', '어제'),
  ('이전', '오늘 식단을 아직 기록하지 않았어요', '저녁 전에 한 끼만 담아도 돼요', '10월 19일'),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    this.unread = true,
    this.empty = false,
    this.onRead,
    super.key,
  });

  final bool unread;
  final bool empty;
  final VoidCallback? onRead;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late bool _unread = widget.unread;

  @override
  Widget build(BuildContext context) => _DetailPage(
    title: '알림',
    action: widget.empty
        ? null
        : TextButton(
            onPressed: _unread
                ? () {
                    setState(() => _unread = false);
                    widget.onRead?.call();
                  }
                : null,
            child: const Text('모두 읽음'),
          ),
    children: widget.empty
        ? [
            const SizedBox(height: 155),
            Center(
              child: SvgPicture.asset(
                'assets/images/notifications_mascot.svg',
                width: 120,
                height: 138,
              ),
            ),
            const SizedBox(height: 12),
            const Center(child: Text('아직 알림이 없어요', style: _title)),
            const SizedBox(height: 8),
            const Center(child: Text('식단을 기록하면 여기에서 알려 드려요.', style: _detail)),
          ]
        : [
            for (var i = 0; i < _alerts.length; i++) ...[
              if (i == 0 || _alerts[i].$1 != _alerts[i - 1].$1)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 8 : 22, bottom: 8),
                  child: Text(
                    _alerts[i].$1,
                    style: _detail.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/images/home_alert_$i.svg',
                      width: 44,
                      height: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _alerts[i].$2,
                            style: _title.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(_alerts[i].$3, style: _detail),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _alerts[i].$4,
                          style: _detail.copyWith(fontSize: 11),
                        ),
                        if (_unread && i < 2) ...[
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.circle,
                            size: 9,
                            color: Color(0xFF49B3C5),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.border),
            ],
          ],
  );
}

class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => _DetailPage(
    title: '포인트',
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(minHeight: 128),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 포인트',
                    style: TextStyle(color: Color(0xFFBADDD8), fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '2,500P',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF214B41),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '이번 달 +120P',
                style: TextStyle(
                  color: Color(0xFFC5E6EA),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      const Text('내역', style: _title),
      const SizedBox(height: 13),
      for (final (day, spent) in [
        (21, false),
        (20, false),
        (19, true),
        (19, false),
        (18, false),
        (17, false),
        (16, false),
      ]) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spent ? '쇼핑 결제에 사용' : '식단 기록', style: _title),
                    const SizedBox(height: 3),
                    Text('10월 $day일', style: _detail),
                  ],
                ),
              ),
              Text(
                spent ? '-500P' : '+5P',
                style: _title.copyWith(
                  color: spent ? AppTheme.muted : AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),
      ],
    ],
  );
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.title, required this.children, this.action});

  final String title;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) => AppScreenFrame(
    figmaName: title,
    child: ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: (70.0 - MediaQuery.paddingOf(context).top).clamp(
                0.0,
                70.0,
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: '뒤로',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                ),
                Expanded(
                  child: Text(title, style: _title.copyWith(fontSize: 26)),
                ),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: action,
                  ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: children,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
