import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../profile/presentation/profile_tab.dart';

import '../../shopping/presentation/shopping_tab.dart';

import '../../social/presentation/social_tab.dart';

import '../../records/presentation/records_tab.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/antifreeze_widgets.dart';
import '../../../core/widgets/app_screen_frame.dart';
import 'home_detail_screens.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const MainShell();
}

class MainShell extends StatefulWidget {
  const MainShell({
    this.initialIndex = 0,
    this.initialSocialView = SocialView.crew,
    super.key,
  });
  final int initialIndex;
  final SocialView initialSocialView;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;
  bool _shoppingCatalog = true;
  int _profileOrderRequests = 0;
  bool _ordersFromProfile = false;
  @override
  Widget build(BuildContext context) => AppScreenFrame(
    figmaName: 'Antifreeze 메인',
    child: Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _index,
        children: [
          const _HomeTab(),
          const RecordsTab(),
          SocialTab(initialView: widget.initialSocialView),
          ShoppingTab(
            orderRequests: _profileOrderRequests,
            onViewChanged: (view) => setState(() {
              _shoppingCatalog = view == ShoppingView.catalog;
              if (_shoppingCatalog && _ordersFromProfile) {
                _index = 4;
                _ordersFromProfile = false;
              }
            }),
          ),
          ProfileTab(
            onOrders: () => setState(() {
              _profileOrderRequests++;
              _ordersFromProfile = true;
              _shoppingCatalog = false;
              _index = 3;
            }),
          ),
        ],
      ),
      bottomNavigationBar: _index == 3 && !_shoppingCatalog
          ? null
          : NavigationBar(
              height: 72,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFE4F2F4),
              selectedIndex: _index,
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 11,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: '홈',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: '기록',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups),
                  label: '소셜',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag),
                  label: '쇼핑',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: '프로필',
                ),
              ],
            ),
    ),
  );
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) => const CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _HomeHero()),
      SliverToBoxAdapter(child: _MealsSection()),
      SliverToBoxAdapter(child: _DashboardDetails()),
    ],
  );
}

class _HomeHero extends StatefulWidget {
  const _HomeHero();

  @override
  State<_HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<_HomeHero> {
  bool _unread = true;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 593,
    child: Stack(
      children: [
        const ColoredBox(color: Color(0xFFE3F4F4), child: SizedBox.expand()),
        Positioned(
          top: 249,
          left: 0,
          right: 0,
          bottom: 0,
          child: const ColoredBox(color: Color(0xFFB3E1E4)),
        ),
        Positioned(
          top: 242,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/images/home_wave.svg',
            height: 21,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          bottom: -4,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/images/home_shore.svg',
            height: 18,
            fit: BoxFit.fill,
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              (70.0 - MediaQuery.paddingOf(context).top).clamp(0.0, 70.0),
              12,
              0,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '10월 21일 수요일',
                    style: TextStyle(color: AppTheme.muted, fontSize: 13),
                  ),
                ),
                const _HeaderPill(icon: Icons.water_drop_outlined, label: '6'),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.points),
                  child: const _HeaderPill(label: '2,500P'),
                ),
                IconButton(
                  tooltip: '알림',
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationsScreen(
                        unread: _unread,
                        onRead: () => setState(() => _unread = false),
                      ),
                    ),
                  ),
                  icon: Badge(
                    isLabelVisible: _unread,
                    backgroundColor: AppTheme.primary,
                    child: const Icon(
                      Icons.notifications_none,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: 132,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '6', style: TextStyle(fontSize: 56)),
                    TextSpan(text: ' 일째', style: TextStyle(fontSize: 20)),
                  ],
                ),
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '연속으로 기록 중',
                style: TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        Positioned(
          top: 270,
          left: 0,
          right: 0,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/home_mascot.svg',
              width: 179,
              height: 205,
            ),
          ),
        ),
        Positioned(
          left: 52,
          right: 52,
          bottom: 15,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF5A4BFF), width: 1.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AiBadge(),
                SizedBox(height: 3),
                Text(
                  '단백질이 34g 부족해요',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '저녁에 계란이나 두부를 더해 보세요',
                  maxLines: 1,
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                Divider(height: 8),
                Text(
                  '오늘도 기록하면 7일이에요 · 금빛 테두리까지 1일',
                  maxLines: 1,
                  style: TextStyle(
                    color: Color(0xFF7D8C86),
                    fontSize: 9.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, this.icon});
  final String label;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE1ECEA)),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: AppTheme.muted),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFC),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        '✦ AI 한마디',
        style: TextStyle(
          color: Color(0xFF5146D9),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _MealsSection extends StatelessWidget {
  const _MealsSection();
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
    child: Column(
      children: [
        const Row(
          children: [
            Expanded(child: Text('오늘 식단 기록', style: _sectionTitle)),
            Text('0 / 4끼', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['아침', '점심', '저녁', '간식']
              .map(
                (meal) => InkWell(
                  onTap: () => _showMealSheet(context, meal),
                  borderRadius: BorderRadius.circular(17),
                  child: Container(
                    width: 82,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F3),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFC6DCD5)),
                          ),
                          child: const Icon(Icons.add, size: 17),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.water_drop, color: Color(0xFF48B9C9), size: 17),
              SizedBox(width: 12),
              Expanded(child: Text('체중')),
              Text('기록하기 ›', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    ),
  );

  static void _showMealSheet(BuildContext context, String meal) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('$meal 식단 기록', style: _sectionTitle),
              const SizedBox(height: 18),
              const LabeledField(label: '먹은 음식', hint: '음식 이름을 입력해 주세요'),
              const SizedBox(height: 14),
              const LabeledField(
                label: '칼로리',
                hint: '0 kcal',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: '기록하기',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
}

class _DashboardDetails extends StatelessWidget {
  const _DashboardDetails();
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(15, 8, 15, 34),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('남은 칼로리', style: _sectionTitle)),
            Text('내 정보 ›', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        SizedBox(height: 17),
        Row(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: 0,
                strokeWidth: 8,
                backgroundColor: Color(0xFFDDE9E5),
              ),
            ),
            SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '2,442', style: TextStyle(fontSize: 30)),
                      TextSpan(
                        text: '  kcal',
                        style: TextStyle(fontSize: 14, color: AppTheme.muted),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '섭취 0 · 목표 2,442 kcal',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _Macro(label: '탄수화물', value: '0 / 256g'),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _Macro(label: '단백질', value: '0 / 128g'),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _Macro(label: '지방', value: '0 / 64g'),
            ),
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricBox(label: '키', value: '172', unit: 'cm'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _MetricBox(label: '현재 체중', value: '68.2', unit: 'kg'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _MetricBox(label: '목표', value: '63', unit: 'kg'),
            ),
          ],
        ),
        SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: Text('이번 주 기록', style: _sectionTitle)),
            Text(
              '평균 1,980 kcal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Day('월', true),
            _Day('화', true),
            _Day('수', true),
            _Day('목', true),
            _Day('금', true, outlined: true),
            _Day('토', false),
            _Day('일', false),
          ],
        ),
        SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: Text('체중 변화', style: _sectionTitle)),
            Text(
              '목표까지 -5.2kg',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 14),
        SizedBox(
          height: 92,
          width: double.infinity,
          child: CustomPaint(painter: _WeightChartPainter()),
        ),
      ],
    ),
  );
}

class _Macro extends StatelessWidget {
  const _Macro({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 9),
      Container(
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFDDE9E5),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ],
  );
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;
  @override
  Widget build(BuildContext context) => Container(
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F5F3),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 11,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.muted,
                  height: 1,
                ),
              ),
            ],
          ),
          style: const TextStyle(color: AppTheme.primary),
        ),
      ],
    ),
  );
}

class _Day extends StatelessWidget {
  const _Day(this.label, this.done, {this.outlined = false});
  final String label;
  final bool done;
  final bool outlined;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
      const SizedBox(height: 8),
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: outlined
              ? Colors.white
              : done
              ? const Color(0xFF49B8C8)
              : const Color(0xFFF0F5F3),
          shape: BoxShape.circle,
          border: outlined
              ? Border.all(color: const Color(0xFFBBD9D0), width: 1.5)
              : null,
        ),
        child: Icon(
          Icons.water_drop,
          size: 17,
          color: done
              ? outlined
                    ? const Color(0xFFBBD9D0)
                    : Colors.white
              : Colors.transparent,
        ),
      ),
    ],
  );
}

class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      Paint()..color = const Color(0xFFF0F5F3),
    );
    final curve = Path()
      ..moveTo(0, 18)
      ..cubicTo(
        size.width * .28,
        26,
        size.width * .62,
        56,
        size.width * .91,
        59,
      );
    final fill = Path.from(curve)
      ..lineTo(size.width * .91, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = const Color(0xFFD8ECEB));
    canvas.drawPath(
      curve,
      Paint()
        ..color = const Color(0xFF42B4C5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.drawLine(
      Offset(0, size.height - 18),
      Offset(size.width, size.height - 18),
      Paint()
        ..color = const Color(0xFFB9D9D5)
        ..strokeWidth = 1,
    );
    final point = Offset(size.width * .91, 59);
    canvas.drawCircle(point, 5, Paint()..color = Colors.white);
    canvas.drawCircle(
      point,
      5,
      Paint()
        ..color = const Color(0xFF42B4C5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _sectionTitle = TextStyle(
  color: AppTheme.primary,
  fontSize: 18,
  fontWeight: FontWeight.w700,
);
