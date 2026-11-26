import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/backend_api.dart';
import '../../../core/state/input_rules.dart';
import '../../../core/state/moderation.dart';
import '../../../core/state/my_posts.dart';
import '../../../core/state/body_metrics.dart';
import '../../../core/state/user_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/post_detail_screen.dart';
import '../../../core/widgets/app_overlays.dart';
import 'profile_text.dart';

const _green = AppTheme.primary;
const _muted = AppTheme.muted;
const _blue = Color(0xFF49B3C5);
const _small = TextStyle(color: _muted, fontSize: 13);
const _strong = TextStyle(color: _green, fontWeight: FontWeight.bold);
const _foodStyles = ['완제품 위주', '밀키트 위주', '혼합'];

enum ProfileView {
  metrics,
  ai,
  account,
  address,
  payment,
  alerts,
  posts,
  blocked,
  notices,
  help,
  terms,
  privacy,
  licenses,
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({this.initialView, this.onOrders, super.key});
  final ProfileView? initialView;
  final VoidCallback? onOrders;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // 값은 앱 전체가 공유하는 userProfile에 있다(저장·복원).
  String get _email => userProfile['email'] ?? 'user@antifreeze.com';
  String get _name => userProfile['name']!;
  set _name(String v) => userProfile['name'] = v;
  String get _gender => userProfile['gender']!;
  set _gender(String v) => userProfile['gender'] = v;
  String get _age => userProfile['age']!;
  set _age(String v) => userProfile['age'] = v;
  String get _height => userProfile['height']!;
  set _height(String v) => userProfile['height'] = v;
  String get _goal => userProfile['goal']!;
  set _goal(String v) => userProfile['goal'] = v;
  String get _calories => userProfile['calories']!;
  set _calories(String v) => userProfile['calories'] = v;
  String get _activity => userProfile['activity']!;
  set _activity(String v) => userProfile['activity'] = v;
  String get _food => userProfile['food']!;
  set _food(String v) => userProfile['food'] = v;
  bool _monthly = false;
  final _alerts = userAlerts;
  final _addresses = userAddresses;
  final _cards = userCards;

  void _open(ProfileView view) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => StatefulBuilder(
        builder: (context, refresh) => _detail(context, view, refresh),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.initialView case final view?) {
      return _detail(context, view, setState);
    }
    return ColoredBox(
      color: AppTheme.background,
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey('profile'),
          padding: const EdgeInsets.fromLTRB(20, 35, 20, 24),
          children: [
            const Text(
              '프로필',
              style: TextStyle(
                color: _green,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _panel([
              Material(
                type: MaterialType.transparency,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _avatar(30),
                  title: Text(_name, style: _strong.copyWith(fontSize: 20)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_email, style: _small),
                      const Text(
                        '신체 지표 · 목표 진행 보기',
                        style: TextStyle(color: AppTheme.accent, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: _muted),
                  onTap: () => _open(ProfileView.metrics),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _menu([
              _row(
                '포인트',
                () => Navigator.pushNamed(context, AppRoutes.points),
                icon: Icons.account_balance_wallet_outlined,
                value: '2,500P',
              ),
              ValueListenableBuilder<List<MyPost>>(
                valueListenable: myPosts,
                builder: (context, posts, _) => _row(
                  '게시물 관리',
                  () => _open(ProfileView.posts),
                  icon: Icons.photo_library_outlined,
                  value: posts.isEmpty ? null : '${posts.length}개',
                ),
              ),
            ]),
            const SizedBox(height: 24),
            const Text(
              '체중 변화',
              style: TextStyle(
                color: _green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _chart(),
            _group('쇼핑', [
              _row(
                '주문 · 구독 내역',
                widget.onOrders ??
                    () => Navigator.pushNamed(context, AppRoutes.orders),
                icon: Icons.receipt_long_outlined,
              ),
              _row(
                '배송지 관리',
                () => _open(ProfileView.address),
                icon: Icons.location_on_outlined,
                value: '${_addresses.length}곳',
              ),
              _row(
                '결제 수단',
                () => _open(ProfileView.payment),
                icon: Icons.credit_card,
                value: '${_cards.length}개',
              ),
            ]),
            _group('설정', [
              _row(
                '프로필 · 신체 지표',
                () => _open(ProfileView.metrics),
                icon: Icons.person_outline,
              ),
              _row(
                'AI 추천 설정',
                () => _open(ProfileView.ai),
                icon: Icons.auto_awesome_outlined,
                value: _food,
              ),
              _row(
                '알림 설정',
                () => _open(ProfileView.alerts),
                icon: Icons.notifications_none,
              ),
              _row(
                '계정 관리',
                () => _open(ProfileView.account),
                icon: Icons.manage_accounts_outlined,
              ),
              _row(
                '차단한 사용자',
                () => _open(ProfileView.blocked),
                icon: Icons.block,
              ),
            ]),
            _group('고객 지원', [
              _row(
                '공지사항',
                () => _open(ProfileView.notices),
                icon: Icons.campaign_outlined,
              ),
              _row(
                '고객센터',
                () => _open(ProfileView.help),
                icon: Icons.headset_mic_outlined,
                subtitle: '자주 묻는 질문 · 1:1 문의',
              ),
            ]),
            _group('약관 및 정보', [
              _row('서비스 이용약관', () => _open(ProfileView.terms)),
              _row('개인정보 처리방침', () => _open(ProfileView.privacy)),
              _row('오픈소스 라이선스', () => _open(ProfileView.licenses)),
              ListTile(
                title: const Text('앱 버전'),
                trailing: const Text('1.0.0', style: _small),
                onTap: () => _toast(context, '최신 버전이에요', tab: true),
              ),
            ]),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                if (await showConfirmPopup(
                      context,
                      title: '로그아웃할까요?',
                      message: '언제든 다시 로그인할 수 있어요.',
                      confirmLabel: '로그아웃',
                    ) &&
                    context.mounted) {
                  resetUserData();
                  await saveUserData();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                }
              },
              child: const Text('로그아웃'),
            ),
            const SizedBox(height: 8),
            Center(child: Text('$_email 계정으로 로그인됨', style: _small)),
          ],
        ),
      ),
    );
  }

  Widget _avatar(double radius) => CircleAvatar(
    radius: radius,
    backgroundColor: const Color(0xFFEAF1ED),
    child: Text(
      _name.characters.first,
      style: _strong.copyWith(fontSize: radius * .72),
    ),
  );

  Widget _chart() => _panel([
    _choices(
      ['주간', '월간'],
      _monthly ? '월간' : '주간',
      (value) => setState(() => _monthly = value == '월간'),
    ),
    const SizedBox(height: 9),
    Text(_monthly ? '09/22 – 10/21' : '10/15 – 10/21', style: _small),
    const SizedBox(height: 14),
    Row(
      children: [
        SizedBox(
          width: 34,
          height: 108,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final label
                  in _monthly
                      ? ['71.2', '69.7', '68.2']
                      : ['69.4', '68.8', '68.2'])
                Text(label, style: _small.copyWith(fontSize: 11)),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 108,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Divider(height: 1, color: AppTheme.border),
                    Divider(height: 1, color: AppTheme.border),
                    Divider(height: 1, color: AppTheme.border),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    right: 15,
                    top: 3,
                    bottom: 4,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SvgPicture.asset(
                        'assets/images/profile_chart_0.svg',
                        fit: BoxFit.fill,
                      ),
                      SvgPicture.asset(
                        'assets/images/profile_chart_1.svg',
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: SvgPicture.asset(
                          'assets/images/profile_chart_2.svg',
                          width: 15,
                          height: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 12),
    Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final label
              in _monthly
                  ? ['09/22', '09/29', '10/06', '10/13', '오늘']
                  : [
                      '10/15',
                      '10/16',
                      '10/17',
                      '10/18',
                      '10/19',
                      '10/20',
                      '오늘',
                    ])
            Text(label, style: _small.copyWith(fontSize: 10)),
        ],
      ),
    ),
    const SizedBox(height: 8),
    const Divider(color: AppTheme.border),
    Row(
      children: [
        Expanded(child: _stat('기간 변화', _monthly ? '-3.0kg' : '-1.2kg')),
        Expanded(child: _stat('평균 체중', _monthly ? '69.7kg' : '68.7kg')),
        Expanded(child: _stat('목표까지', '5.2kg')),
      ],
    ),
  ]);

  Widget _detail(BuildContext context, ProfileView view, StateSetter refresh) {
    return switch (view) {
      ProfileView.metrics => _metrics(context, refresh),
      ProfileView.ai => _page(context, 'AI 추천 설정', [
        const Text('선호하는 식단 방식', style: _strong),
        const SizedBox(height: 8),
        _menu([
          for (var index = 0; index < _foodStyles.length; index++)
            ListTile(
              title: Text(_foodStyles[index], style: _strong),
              subtitle: Text(
                ['도시락 · 샐러드처럼 바로 먹는 식단', '간단히 조리하는 식단', '완제품과 밀키트를 함께'][index],
                style: _small,
              ),
              trailing: _food == _foodStyles[index] ? _checkMark : null,
              onTap: () {
                setState(() => _food = _foodStyles[index]);
                refresh(() {});
                saveUserData();
              },
            ),
        ]),
        const SizedBox(height: 14),
        const Text('홈의 AI 추천과 쇼핑의 기본 카테고리가 이 설정에 맞춰 바뀌어요.', style: _small),
      ]),
      ProfileView.account => _page(context, '계정 관리', [
        _menu([
          ListTile(
            title: const Text('이메일'),
            trailing: Text(_email, style: _small),
          ),
          _row('비밀번호 변경', () => _password(context)),
        ]),
        const SizedBox(height: 16),
        _menu([_row('회원 탈퇴', () => _withdraw(context))]),
        const SizedBox(height: 10),
        const Text('탈퇴하면 기록과 포인트가 모두 삭제되고 되돌릴 수 없어요.', style: _small),
      ]),
      ProfileView.address => _page(context, '배송지 관리', [
        if (_addresses.isEmpty) _panel([const Text('등록한 배송지가 없어요.')]),
        for (var i = 0; i < _addresses.length; i++) ...[
          _menu([
            _row(
              _addresses[i][0],
              badge: i == 0 ? '기본' : null,
              () => _editAddress(context, refresh, i),
              subtitle:
                  '${_addresses[i][3]} ${_addresses[i][4]}\n${_addresses[i][1]} · ${_addresses[i][2]}',
            ),
          ]),
          const SizedBox(height: 10),
        ],
      ], trailing: _topAction('추가', () => _editAddress(context, refresh, null))),
      ProfileView.payment => _page(context, '결제 수단', [
        _menu([
          for (var i = 0; i < _cards.length; i++)
            ListTile(
              leading: const Icon(Icons.credit_card, color: _green),
              title: Text(_cards[i]),
              trailing: i == 0
                  ? const Text(
                      '기본',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          if (_cards.isEmpty) const ListTile(title: Text('등록한 결제 수단이 없어요.')),
        ]),
        const SizedBox(height: 14),
        const Text(
          '프로토타입에서는 카드사와 끝 4자리만 저장해요. 실제 앱에서는 결제 대행사(PG) 결제창에서 카드 정보를 입력하고, 앱에는 카드 번호를 저장하지 않아요.',
          style: _small,
        ),
      ], trailing: _topAction('추가', () => _addCard(context, refresh))),
      ProfileView.alerts => _page(context, '알림 설정', [
        _menu([
          for (var i = 0; i < _alerts.length; i++)
            SwitchListTile(
              title: Text(['식단 기록', '크루 활동', '배송'][i], style: _strong),
              subtitle: Text(
                ['기록을 잊지 않도록 알려드려요', '인증 현황, 불꽃, 가입 신청 소식', '주문 · 정기 배송 상태'][i],
                style: _small,
              ),
              value: _alerts[i],
              onChanged: (value) {
                refresh(() => _alerts[i] = value);
                saveUserData();
              },
            ),
        ]),
        const SizedBox(height: 10),
        const Text('끈 알림은 알림함에도 쌓이지 않아요.', style: _small),
        _group('기기 알림', [
          ListTile(
            leading: const Icon(Icons.notifications_none, color: _green),
            title: const Text('기기 알림 권한'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('허용 필요', style: _small),
                Icon(Icons.chevron_right, size: 20, color: _muted),
              ],
            ),
            onTap: () => _toast(context, '기기 설정에서 알림을 허용해 주세요'),
          ),
        ]),
        const SizedBox(height: 10),
        const Text('권한을 허용하면 앱을 닫아도 알림을 받을 수 있어요.', style: _small),
      ]),
      ProfileView.blocked => _page(context, '차단한 사용자', [
        const SizedBox(height: 12),
        if (blockedUsers.value.isEmpty)
          _panel([
            const Icon(Icons.group_outlined, color: _muted, size: 28),
            const SizedBox(height: 8),
            const Center(child: Text('차단한 사용자가 없어요.')),
          ])
        else
          _menu([
            for (final name in blockedUsers.value)
              ListTile(
                leading: _avatar(18),
                title: Text(name, style: const TextStyle(color: _green)),
                trailing: TextButton(
                  onPressed: () {
                    unblockUser(name);
                    refresh(() {});
                    _toast(context, '$name님의 차단을 해제했어요');
                  },
                  child: const Text('해제'),
                ),
              ),
          ]),
        const SizedBox(height: 12),
        const Center(
          child: Text('차단을 해제하면 그 사용자의 게시물과 댓글이 다시 보여요.', style: _small),
        ),
      ]),
      ProfileView.notices => _page(context, '공지사항', [
        _menu([
          for (final (title, date, body) in _notices)
            _row(
              title,
              () => _infoSheet(context, title, date, body),
              subtitle: date,
            ),
        ]),
      ]),
      ProfileView.posts => _managePosts(context, refresh),
      ProfileView.help => _help(context),
      ProfileView.terms => _document(context, '서비스 이용약관', terms),
      ProfileView.privacy => _document(context, '개인정보 처리방침', privacy),
      ProfileView.licenses => _document(context, '오픈소스 라이선스', licenses),
    };
  }

  Widget _metrics(BuildContext context, StateSetter refresh) {
    final gap = goalGap;
    final remaining = numText(double.parse(gap.remaining.toStringAsFixed(1)));
    // 시연 기준일(홈과 같은 10월 21일)에서 주 0.5kg 속도로 계산한다.
    final weeks = (gap.remaining / .5).ceil();
    final reach = DateTime(2026, 10, 21).add(Duration(days: weeks * 7));
    final macros = macroGoals;
    final energy = [macros.carbs * 4, macros.protein * 4, macros.fat * 9];
    final total = energy.fold(0, (a, b) => a + b);
    final kcal = calorieGoal;
    return _page(
      context,
      '프로필',
      [
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _avatar(36),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: GestureDetector(
                    onTap: () => _toast(context, '프로필 사진 변경은 준비 중이에요'),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF3F8F7),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name, style: _strong.copyWith(fontSize: 22)),
                  Text(_email, style: _small),
                  Text('만 $_age세 · $_gender · ${_height}cm', style: _small),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          '목표 진행',
          style: TextStyle(
            color: _green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 9),
        _panel([
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: gap.remaining == 0
                    ? Text('목표 달성', style: _strong.copyWith(fontSize: 26))
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${remaining}kg ',
                              style: _strong.copyWith(fontSize: 26),
                            ),
                            TextSpan(
                              text: '${gap.verb} 남음',
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Text(
                '${(goalProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: goalProgress,
            color: _blue,
            backgroundColor: AppTheme.border,
            borderRadius: BorderRadius.circular(5),
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _labelValue('시작 ', '${userProfile['startWeight']}kg'),
              _labelValue('현재 ', '${userProfile['weight']}kg'),
              _labelValue('목표 ', '${_goal}kg'),
            ],
          ),
          const Divider(color: AppTheme.border),
          if (gap.remaining > 0)
            Text.rich(
              TextSpan(
                style: _small,
                children: [
                  const TextSpan(text: '권장 속도(주 0.5kg)로 가면 약 '),
                  TextSpan(
                    text: '$weeks주 뒤 · ${reach.month}월 ${reach.day}일',
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' 전후에 도달해요.'),
                ],
              ),
            )
          else
            const Text('목표 체중에 도달했어요.', style: _small),
        ]),
        const SizedBox(height: 30),
        const Text(
          '나의 신체 지표',
          style: TextStyle(
            color: _green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 9),
        _panel([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BMI', style: _small),
              Text(bmiLabel, style: _small),
            ],
          ),
          Text(
            bmi.toStringAsFixed(1),
            style: const TextStyle(
              color: _green,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _bmiScale(),
          const SizedBox(height: 6),
          const Row(
            children: [
              Expanded(
                child: Text(
                  '저체중',
                  style: _bmiLegend,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  '정상 18.5~23',
                  style: _bmiLegend,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  '과체중 23~',
                  style: _bmiLegend,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ]),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _metricCard(
                '기초대사량',
                _thousands(bmr),
                'kcal',
                '가만히 있어도 쓰는 에너지',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                '하루 목표 칼로리',
                _thousands(kcal),
                'kcal',
                '활동량 $_activity 기준',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _metricCard(
                '하루 물 권장량',
                waterLiters.toStringAsFixed(1),
                'L',
                '체중 1kg당 30ml',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                '최근 7일 평균 섭취',
                '677',
                'kcal',
                '기록한 7일 기준 · 목표 대비\n${_thousands(677 - kcal)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          '하루 권장 영양',
          style: TextStyle(
            color: _green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 9),
        _panel([
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: i == 2 ? const Color(0xFF9AAAA4) : _blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, label, grams) in [
                (0, '탄수화물', macros.carbs),
                (1, '단백질', macros.protein),
                (2, '지방', macros.fat),
              ])
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7, right: 6),
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: i == 2
                              ? const Color(0xFF9AAAA4)
                              : _blue,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: _small),
                            Text(
                              '${grams}g',
                              style: _strong.copyWith(fontSize: 17),
                            ),
                            Text(
                              '${total == 0 ? 0 : (energy[i] * 100 / total).round()}%',
                              style: _bmiLegend,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ]),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Text(
            '모든 수치는 입력한 정보로 계산한 참고값이에요. 질환이 있거나 급격한 체중 변화를 계획한다면 전문가와 상담하세요.',
            style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        _menu([
          _row(
            '정보 수정',
            () => _editMetrics(context, refresh),
            icon: Icons.tune,
            subtitle: '닉네임 · 신체 정보 · 활동량 · 목표 칼로리',
          ),
        ]),
      ],
      trailing: TextButton(
        onPressed: () => _editMetrics(context, refresh),
        child: const Text('편집'),
      ),
    );
  }

  // 저체중·정상·과체중 3구간 눈금과 현재 BMI 위치.
  Widget _bmiScale() {
    final v = bmi;
    final idx = v < 18.5 ? 0 : (v < 23 ? 1 : 2);
    final frac = switch (idx) {
      0 => ((v - 14) / 4.5).clamp(0.0, 1.0),
      1 => (v - 18.5) / 4.5,
      _ => ((v - 23) / 9).clamp(0.0, 1.0),
    };
    return LayoutBuilder(
      builder: (context, box) => SizedBox(
        height: 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: i == idx
                            ? const Color(0x8C49B3C5)
                            : AppTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              left: (box.maxWidth * (idx + frac) / 3 - 2).clamp(
                0.0,
                box.maxWidth - 4,
              ),
              top: -4,
              child: Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editMetrics(BuildContext context, StateSetter refresh) async {
    final fields = [_name, _age, _height, _goal, _calories];
    var gender = _gender;
    var activity = _activity;
    final form = GlobalKey<FormState>();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, update) => Form(
            key: form,
            child: _page(
              context,
              '정보 수정',
              [
                _group('프로필', [
                  _inlineField(
                    '닉네임',
                    fields[0],
                    (value) => fields[0] = value,
                    check: nicknameError,
                  ),
                ]),
                _group('신체 정보', [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _choices(
                      ['남성', '여성'],
                      gender,
                      (value) => update(() => gender = value),
                    ),
                  ),
                  _inlineField(
                    '나이',
                    fields[1],
                    (value) => fields[1] = value,
                    unit: '세',
                    numeric: true,
                  ),
                  _inlineField(
                    '키',
                    fields[2],
                    (value) => fields[2] = value,
                    unit: 'cm',
                    numeric: true,
                    check: (v) => rangeError('키', v, heightRange, 'cm'),
                  ),
                  _inlineField(
                    '목표 체중',
                    fields[3],
                    (value) => fields[3] = value,
                    unit: 'kg',
                    numeric: true,
                    check: (v) => rangeError('목표 체중', v, weightRange, 'kg'),
                  ),
                ]),
                _group('활동량', [
                  for (final (item, hint) in [
                    ('비활동적', '운동을 거의 하지 않아요'),
                    ('보통 활동', '주 1~3회 가볍게 움직여요'),
                    ('활동적', '주 4~5회 꾸준히 움직여요'),
                  ])
                    ListTile(
                      title: Text(
                        item,
                        style: const TextStyle(color: _green, fontSize: 16),
                      ),
                      subtitle: Text(hint, style: _small),
                      selected: activity == item,
                      trailing: activity == item ? _checkMark : null,
                      onTap: () => update(() => activity = item),
                    ),
                ]),
                _group('목표 칼로리', [
                  _inlineField(
                    '하루 목표',
                    fields[4],
                    (value) => fields[4] = value,
                    unit: 'kcal',
                    numeric: true,
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                  child: Text(
                    '현재 체중 ${userProfile['weight']}kg 기준으로 활동량을 바꾸면 자동 계산돼요. 직접 고칠 수도 있어요.',
                    style: _small,
                  ),
                ),
              ],
              back: '프로필',
              trailing: _topAction('저장', () {
                if (form.currentState!.validate()) Navigator.pop(context, true);
              }),
            ),
          ),
        ),
      ),
    );
    if (saved != true || !mounted) return;
    if (context.mounted) _toast(context, '저장되었어요');
    // 목표 칼로리를 직접 고치지 않았고 계산 재료가 바뀌었으면 권장 칼로리로 다시 계산한다.
    final recalc =
        fields[4].trim() == _calories &&
        (fields[1].trim() != _age ||
            fields[2].trim() != _height ||
            gender != _gender ||
            activity != _activity);
    setState(() {
      _name = fields[0].trim();
      _age = fields[1].trim();
      _height = fields[2].trim();
      _goal = fields[3].trim();
      _calories = fields[4].trim();
      _gender = gender;
      _activity = activity;
      if (recalc) _calories = recommendedCalories.toString();
    });
    refresh(() {});
    unawaited(saveUserData());
    if (currentUserId != null) {
      unawaited(
        BackendApi.instance
            .updateUser(
              currentUserId!,
              nickname: _name,
              targetWeight: double.tryParse(_goal),
              dailyCalorieGoal: int.tryParse(_calories),
            )
            .catchError((_) => null),
      );
    }
  }

  Future<void> _editAddress(
    BuildContext context,
    StateSetter refresh,
    int? index,
  ) async {
    final fields = index == null
        ? ['집', '', '', '', '']
        : List<String>.of(_addresses[index]);
    var makeDefault = index == 0 || _addresses.isEmpty;
    final form = GlobalKey<FormState>();
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, update) => Form(
            key: form,
            child: _page(
              context,
              index == null ? '배송지 추가' : '배송지 수정',
              [
                const Text('배송지 이름', style: _strong),
                const SizedBox(height: 8),
                _choices(
                  ['집', '회사', '기타'],
                  fields[0],
                  (value) => update(() => fields[0] = value),
                ),
                const SizedBox(height: 12),
                _menu([
                  for (var i = 1; i < fields.length; i++)
                    _field(
                      ['', '받는 분', '연락처', '주소', '상세 주소'][i],
                      fields[i],
                      (value) => fields[i] = value,
                      required: i != 4,
                    ),
                ]),
                const SizedBox(height: 10),
                const Text('실제 앱에서는 주소 검색으로 도로명 주소를 입력해요.', style: _small),
                const SizedBox(height: 16),
                _menu([
                  SwitchListTile(
                    title: const Text('기본 배송지로 설정'),
                    value: makeDefault,
                    onChanged: (value) => update(() => makeDefault = value),
                  ),
                ]),
                if (index != null) ...[
                  const SizedBox(height: 16),
                  _menu([
                    ListTile(
                      title: const Center(
                        child: Text(
                          '배송지 삭제',
                          style: TextStyle(color: AppTheme.danger),
                        ),
                      ),
                      onTap: () async {
                        if (await showConfirmPopup(
                              context,
                              title: '배송지를 삭제할까요?',
                              message: '삭제한 배송지는 되돌릴 수 없어요.',
                              confirmLabel: '삭제하기',
                            ) &&
                            context.mounted) {
                          Navigator.pop(context, 'delete');
                        }
                      },
                    ),
                  ]),
                ],
              ],
              back: '배송지',
              trailing: _topAction('저장', () {
                if (form.currentState!.validate()) {
                  Navigator.pop(context, 'save');
                }
              }),
            ),
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    if (context.mounted) {
      _toast(context, result == 'save' ? '저장되었어요' : '배송지가 삭제되었어요');
    }
    setState(() {
      if (index != null) _addresses.removeAt(index);
      if (result == 'save') {
        _addresses.insert(
          makeDefault
              ? 0
              : (index == 0 && _addresses.isNotEmpty
                    ? 1
                    : index ?? _addresses.length),
          fields,
        );
      }
    });
    refresh(() {});
  }

  Future<void> _addCard(BuildContext context, StateSetter refresh) async {
    var issuer = '';
    var lastFour = '';
    final form = GlobalKey<FormState>();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => Form(
          key: form,
          child: _page(
            context,
            '결제 수단 추가',
            [
              _menu([
                _field('카드사', '', (value) => issuer = value),
                _field(
                  '카드 끝 4자리',
                  '',
                  (value) => lastFour = value,
                  numeric: true,
                  validator: (value) => RegExp(r'^\d{4}$').hasMatch(value ?? '')
                      ? null
                      : '숫자 4자리를 입력해 주세요.',
                ),
              ]),
            ],
            back: '결제 수단',
            action: _action('저장', () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            }),
          ),
        ),
      ),
    );
    if (saved != true || !mounted) return;
    if (context.mounted) _toast(context, '결제 수단이 추가되었어요');
    setState(() => _cards.add('${issuer.trim()} ···· $lastFour'));
    refresh(() {});
  }

  void _password(BuildContext context) {
    final form = GlobalKey<FormState>();
    var password = '';
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => Form(
          key: form,
          child: _page(context, '비밀번호 변경', [
            _menu([
              _field('현재 비밀번호', '', (_) {}, secret: true, hint: '현재 비밀번호'),
              _field(
                '새 비밀번호',
                '',
                (value) => password = value,
                secret: true,
                hint: '영문, 숫자 포함 8자 이상',
                validator: (value) =>
                    RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')
                        .hasMatch(value ?? '')
                    ? null
                    : '영문과 숫자를 포함해 8자 이상 입력해 주세요.',
              ),
              _field(
                '새 비밀번호 확인',
                '',
                (_) {},
                secret: true,
                hint: '한 번 더 입력',
                validator: (value) =>
                    value == password ? null : '새 비밀번호가 일치하지 않아요.',
              ),
            ]),
            const SizedBox(height: 12),
            const Text('다른 서비스와 같은 비밀번호는 피해 주세요.', style: _small),
            const SizedBox(height: 16),
            _action('변경하기', () {
              if (form.currentState!.validate()) {
                _toast(context, '비밀번호가 변경되었어요');
                Navigator.pop(context);
              }
            }),
          ], back: '계정 관리'),
        ),
      ),
    );
  }

  void _withdraw(BuildContext context) {
    var acknowledged = false;
    String? reason;
    final form = GlobalKey<FormState>();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, update) => Form(
            key: form,
            child: _page(
              context,
              '회원 탈퇴',
              [
                Text(
                  '$_name님, 탈퇴하기 전에\n꼭 확인해 주세요',
                  style: _strong.copyWith(fontSize: 20, height: 1.4),
                ),
                const SizedBox(height: 20),
                _panel([
                  _bullet([
                    const TextSpan(text: '식단 · 체중 기록과 프로필 정보가 '),
                    TextSpan(text: '모두 삭제', style: _strong),
                    const TextSpan(text: '되고 복구할 수 없어요.'),
                  ]),
                  _bullet([
                    const TextSpan(text: '보유 포인트 '),
                    TextSpan(text: '2,500P', style: _strong),
                    const TextSpan(text: '가 소멸해요.'),
                  ]),
                  _bullet([
                    const TextSpan(text: "크루 피드의 게시물은 '탈퇴한 회원'으로 표시돼요."),
                  ]),
                  _bullet([
                    const TextSpan(text: '주문 · 결제 기록은 관계 법령에 따라 일정 기간 보관돼요.'),
                  ]),
                ]),
                if (hasSubscription)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                        ),
                        children: [
                          const TextSpan(text: '진행 중인 정기 구독이 있어요. 먼저 '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.orders,
                              ),
                              child: const Text(
                                '정기 구독을 해지',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: '해 주세요.'),
                        ],
                      ),
                    ),
                  ),
                _group('떠나시는 이유 (선택)', [
                  for (final item in [
                    '기록하기 번거로워요',
                    '원하는 상품이 없어요',
                    '다른 앱을 쓸 거예요',
                    '개인정보가 걱정돼요',
                    '기타',
                  ])
                    ListTile(
                      minTileHeight: 52,
                      title: Text(
                        item,
                        style: const TextStyle(color: _green, fontSize: 16),
                      ),
                      selected: reason == item,
                      trailing: reason == item ? _checkMark : null,
                      onTap: () =>
                          update(() => reason = reason == item ? null : item),
                    ),
                ]),
                const SizedBox(height: 20),
                _menu([
                  CheckboxListTile(
                    value: acknowledged,
                    title: const Text(
                      '안내 사항을 모두 확인했어요',
                      style: TextStyle(color: _green, fontSize: 15),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) =>
                        update(() => acknowledged = value ?? false),
                  ),
                ]),
                const SizedBox(height: 20),
                _menu([
                  _field('비밀번호 확인', '', (_) {}, secret: true, hint: '현재 비밀번호'),
                ]),
              ],
              back: '계정 관리',
              action: _action(
                '탈퇴하기',
                acknowledged
                    ? () async {
                        if (form.currentState!.validate() &&
                            await showConfirmPopup(
                              context,
                              title: '정말 탈퇴할까요?',
                              message: '탈퇴하면 기록과 포인트가 모두 삭제되고 되돌릴 수 없어요.',
                              confirmLabel: '탈퇴하기',
                            ) &&
                            context.mounted) {
                          if (currentUserId != null) {
                            try {
                              await BackendApi.instance.deleteUser(
                                currentUserId!,
                              );
                            } on ApiException catch (error) {
                              if (context.mounted) {
                                _toast(context, error.message);
                              }
                              return;
                            }
                          }
                          resetUserData();
                          await saveUserData();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (_) => false,
                          );
                        }
                      }
                    : null,
                color: AppTheme.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 프로필 · 게시물 관리: 내가 올린 게시물의 내용·공개 범위 수정과 삭제.
  Widget _managePosts(BuildContext context, StateSetter refresh) {
    final posts = myPosts.value;
    return _page(context, '게시물 관리', [
      if (posts.isEmpty)
        _panel([
          const Icon(Icons.photo_library_outlined, color: _muted, size: 28),
          const SizedBox(height: 8),
          const Center(child: Text('올린 게시물이 없어요.')),
        ])
      else
        _menu([
          for (final post in posts)
            ListTile(
              onTap: () => Navigator.of(context)
                  .push<void>(
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(
                        photoIndex: -post.id % 15,
                        postId: post.id,
                        caption: post.caption,
                        time: '방금 전',
                        store: postStore,
                      ),
                    ),
                  )
                  .then((_) => refresh(() {})),
              title: Text(
                post.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _green, fontSize: 15),
              ),
              subtitle: Text(
                '${post.meal} · ${post.visibility}${post.crew ? ' · 크루 인증' : ''}',
                style: _small,
              ),
              trailing: AppMenu<String>(
                tooltip: '게시물 메뉴',
                width: 176,
                onSelected: (action) =>
                    _postAction(context, post, action, refresh),
                items: [
                  const AppMenuItem('edit', '내용 수정'),
                  for (final v in ['공개', '비공개', if (inCrew.value) '크루만 공개'])
                    if (v != post.visibility) AppMenuItem(v, '$v로 변경'),
                  const AppMenuItem('delete', '삭제', danger: true),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.more_horiz, color: _muted),
                ),
              ),
            ),
        ]),
      const SizedBox(height: 12),
      const Center(child: Text('삭제한 게시물은 되돌릴 수 없어요.', style: _small)),
    ]);
  }

  Future<void> _postAction(
    BuildContext context,
    MyPost post,
    String action,
    StateSetter refresh,
  ) async {
    switch (action) {
      case 'delete':
        final ok = await showConfirmPopup(
          context,
          title: '게시물을 삭제할까요?',
          message: '삭제하면 되돌릴 수 없어요.',
          confirmLabel: '삭제하기',
        );
        if (!ok || !context.mounted) return;
        deleteMyPost(post.id);
        refresh(() {});
        _toast(context, '게시물을 삭제했어요');
      case 'edit':
        final text = await _editPostText(context, post.caption);
        if (text == null || !context.mounted) return;
        updateMyPost(post.id, caption: text);
        refresh(() {});
        _toast(context, '저장되었어요');
      default: // 공개 범위 변경
        updateMyPost(post.id, visibility: action);
        refresh(() {});
        _toast(context, '공개 설정을 "$action"(으)로 바꿨어요');
    }
  }

  Future<String?> _editPostText(BuildContext context, String current) =>
      showDialog<String>(
        context: context,
        builder: (_) => _PostTextDialog(initial: current),
      );

  Widget _help(BuildContext context) {
    return _page(context, '고객센터', [
      _group('자주 묻는 질문', [
        for (final (question, answer) in _faqs)
          _row(
            question,
            () => _infoSheet(context, question, '자주 묻는 질문', answer),
          ),
      ]),
      _group('1:1 문의', [
        _row(
          '문의하기',
          icon: Icons.chat_bubble_outline,
          subtitle: '평일 10:00~18:00 · 영업일 기준 1~2일 안에 답변해요',
          () {
            final form = GlobalKey<FormState>();
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => Form(
                  key: form,
                  child: _page(
                    context,
                    '1:1 문의',
                    [
                      _menu([_field('문의 내용', '', (_) {}, lines: 5)]),
                      const SizedBox(height: 14),
                      const Text(
                        '평일 10:00~18:00 · 영업일 기준 1~2일 안에 답변해요.',
                        style: _small,
                      ),
                    ],
                    back: '고객센터',
                    action: _action('문의하기', () {
                      if (form.currentState!.validate()) {
                        _toast(context, '문의가 접수되었어요');
                        Navigator.pop(context);
                      }
                    }),
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    ]);
  }
}

Widget _document(BuildContext context, String title, List<String> lines) =>
    _page(context, title, [
      for (final line in lines)
        Padding(
          padding: EdgeInsets.only(
            top: line.startsWith('# ') ? 14 : 0,
            bottom: 6,
          ),
          child: Text(
            line.startsWith('# ') ? line.substring(2) : line,
            style: TextStyle(
              color: _green,
              height: 1.5,
              fontWeight: line.startsWith('# ')
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
    ], white: true);

Widget _page(
  BuildContext context,
  String title,
  List<Widget> children, {
  String back = '프로필',
  Widget? trailing,
  Widget? action,
  bool white = false,
}) => Scaffold(
  backgroundColor: white ? Colors.white : AppTheme.background,
  body: SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 402),
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(title, style: _strong.copyWith(fontSize: 17)),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.chevron_left, size: 20),
                      label: Text(back),
                    ),
                  ),
                  if (trailing != null)
                    Align(alignment: Alignment.centerRight, child: trailing),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: children,
              ),
            ),
            if (action != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: action,
              ),
          ],
        ),
      ),
    ),
  ),
);

Widget _panel(List<Widget> children) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  ),
);

Widget _menu(List<Widget> rows) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  clipBehavior: Clip.antiAlias,
  child: Column(
    children: [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppTheme.border,
          ),
        rows[i],
      ],
    ],
  ),
);

Widget _group(String title, List<Widget> rows) => Padding(
  padding: const EdgeInsets.only(top: 22),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: _small.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _menu(rows),
    ],
  ),
);

Widget _row(
  String title,
  VoidCallback onTap, {
  IconData? icon,
  String? value,
  String? subtitle,
  String? badge,
}) => ListTile(
  leading: icon == null ? null : Icon(icon, color: _green, size: 21),
  title: badge == null
      ? Text(title, style: const TextStyle(color: _green, fontSize: 15))
      : Row(
          children: [
            Text(title, style: const TextStyle(color: _green, fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              badge,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
  subtitle: subtitle == null ? null : Text(subtitle, style: _small),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (value != null) Text(value, style: _strong),
      const Icon(Icons.chevron_right, size: 20, color: _muted),
    ],
  ),
  onTap: onTap,
);

const _bmiLegend = TextStyle(color: _muted, fontSize: 12);

String _thousands(int v) =>
    v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

Widget _labelValue(String label, String value) => Text.rich(
  TextSpan(
    style: _small,
    children: [
      TextSpan(text: label),
      TextSpan(
        text: value,
        style: const TextStyle(color: _green, fontWeight: FontWeight.bold),
      ),
    ],
  ),
);

Widget _metricCard(String label, String value, String unit, String caption) =>
    _panel([
      Text(label, style: _bmiLegend),
      const SizedBox(height: 4),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: value, style: _strong.copyWith(fontSize: 21)),
            TextSpan(
              text: ' $unit',
              style: const TextStyle(
                color: _muted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 4),
      Text(caption, style: _bmiLegend),
    ]);

Widget _stat(String label, String value) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: _small),
    const SizedBox(height: 4),
    Text(value, style: _strong.copyWith(fontSize: 18)),
  ],
);

Widget _choices(
  List<String> labels,
  String selected,
  ValueChanged<String> change,
) => Container(
  padding: const EdgeInsets.all(2),
  decoration: BoxDecoration(
    color: const Color(0xFFEAF1ED),
    borderRadius: BorderRadius.circular(13),
  ),
  child: Row(
    children: [
      for (final label in labels)
        Expanded(
          child: Material(
            color: label == selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              onTap: () => change(label),
              borderRadius: BorderRadius.circular(11),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: label == selected ? _strong : _small,
                ),
              ),
            ),
          ),
        ),
    ],
  ),
);

Widget _field(
  String label,
  String initial,
  ValueChanged<String> change, {
  bool numeric = false,
  bool secret = false,
  bool required = true,
  int lines = 1,
  String? hint,
  FormFieldValidator<String>? validator,
}) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  child: TextFormField(
    initialValue: initial,
    obscureText: secret,
    maxLines: lines,
    keyboardType: numeric
        ? const TextInputType.numberWithOptions(decimal: true)
        : null,
    // Figma: 테두리 없이 작은 이름 아래에 값을 둔다. 입력 중에만 밑줄로 위치를 보여 준다.
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: false,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.accent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.danger),
      ),
    ),
    onChanged: change,
    validator:
        validator ??
        (value) {
          final input = value?.trim() ?? '';
          if (required && input.isEmpty) return '$label 항목을 입력해 주세요.';
          if (numeric && !(double.tryParse(input)?.isFinite ?? false)) {
            return '숫자를 입력해 주세요.';
          }
          return null;
        },
  ),
);

// 선택된 항목 오른쪽의 체크 표시(Figma).
const _checkMark = Icon(Icons.check, color: AppTheme.accent, size: 20);

// 상단 오른쪽 글자 버튼(저장·추가).
Widget _topAction(String label, VoidCallback onPressed) => TextButton(
  onPressed: onPressed,
  style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
  child: Text(label, style: const TextStyle(fontSize: 17)),
);

// 왼쪽에 이름, 오른쪽에 값과 단위를 놓는 한 줄 입력(정보 수정).
Widget _inlineField(
  String label,
  String initial,
  ValueChanged<String> change, {
  String? unit,
  bool numeric = false,
  String? Function(String input)? check,
}) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 52),
    child: Row(
      children: [
        Text(label, style: const TextStyle(color: _green, fontSize: 16)),
        Expanded(
          child: TextFormField(
            initialValue: initial,
            textAlign: TextAlign.right,
            keyboardType: numeric
                ? const TextInputType.numberWithOptions(decimal: true)
                : null,
            style: const TextStyle(color: _green, fontSize: 16),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
            ),
            onChanged: change,
            validator: (value) {
              final input = value?.trim() ?? '';
              if (input.isEmpty) return '$label 항목을 입력해 주세요.';
              if (numeric && !(double.tryParse(input)?.isFinite ?? false)) {
                return '숫자를 입력해 주세요.';
              }
              return check?.call(input);
            },
          ),
        ),
        if (unit != null) ...[
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36),
            child: Text(unit, style: _small.copyWith(fontSize: 15)),
          ),
        ],
      ],
    ),
  ),
);

// 목록 기호가 있는 안내 문장 한 줄.
Widget _bullet(List<InlineSpan> spans) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(2, 9, 12, 0),
        child: CircleAvatar(radius: 2.5, backgroundColor: _muted),
      ),
      Expanded(
        child: Text.rich(
          TextSpan(
            style: const TextStyle(color: _muted, fontSize: 15, height: 1.5),
            children: spans,
          ),
        ),
      ),
    ],
  ),
);

Widget _action(String title, VoidCallback? onPressed, {Color color = _green}) =>
    SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );

// 화면 아래에서 띄우는 거리. Figma는 화면 아래에서 131(탭 화면은 하단 탭 높이만큼 뺌).
void _toast(BuildContext context, String message, {bool tab = false}) =>
    showAppToast(context, message, bottom: tab ? 48 : 131);

const _notices = [
  (
    '연속 기록 보상이 생겼어요',
    '2026.10.13',
    '식단을 하루에 처음 기록하면 5P를 받고, 연속 기록 일수가 늘어나요. 물방울 모양의 연속 기록은 홈 상단 물방울 버튼에서 확인할 수 있어요.',
  ),
  (
    '상품 구매 포인트 적립 정책 변경 안내',
    '2026.10.10',
    '상품 구매 시 결제 금액의 1%가 포인트로 적립돼요. 적립된 포인트는 다음 주문부터 사용할 수 있어요.',
  ),
  (
    'Antifreeze 서비스를 시작해요',
    '2026.10.01',
    'Antifreeze와 함께 AI 맞춤 식단을 시작해 보세요. 식단 기록, 쇼핑, 크루까지 한곳에서 이어져요.',
  ),
];

const _faqs = [
  (
    '권장 칼로리는 어떻게 계산되나요?',
    '키, 몸무게, 나이, 성별로 기초대사량을 구하고 활동량을 곱해 하루 목표 칼로리를 계산해요. 프로필 · 신체 지표에서 정보를 바꾸면 바로 반영돼요.',
  ),
  (
    '포인트는 어떻게 모으고 쓰나요?',
    '식단을 기록하고 연속 기록 보상을 받으면 포인트가 쌓여요. 쌓인 포인트는 쇼핑에서 결제할 때 사용할 수 있어요.',
  ),
  ('연속 기록이 끊겼어요.', '하루 한 끼 이상 기록하지 않으면 연속 기록이 0일로 돌아가요. 다음 날부터 다시 쌓을 수 있어요.'),
  (
    '정기 구독을 건너뛰거나 해지하려면?',
    '쇼핑의 주문 · 구독 내역에서 다음 배송 건너뛰기나 구독 해지를 할 수 있어요. 이미 결제한 배송은 그대로 도착해요.',
  ),
  (
    '크루를 나가고 싶어요.',
    '소셜의 내 크루 화면 오른쪽 위 메뉴에서 크루 탈퇴를 선택하면 돼요. 크루장은 먼저 크루를 삭제해야 해요.',
  ),
  (
    '불쾌한 게시물을 봤어요.',
    '게시물 오른쪽 위 메뉴에서 신고하거나 작성자를 차단할 수 있어요. 차단한 사용자는 프로필 · 차단한 사용자에서 확인해요.',
  ),
];

/// 공지·FAQ 시트 (Figma Overlay/프로필 시트): 제목, 보조 줄, 구분선, 본문, "확인".
void _infoSheet(BuildContext context, String title, String sub, String body) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: const Color(0x730F1722),
      constraints: const BoxConstraints(maxWidth: 402),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(title, style: _strong.copyWith(fontSize: 18, height: 1.3)),
              const SizedBox(height: 12),
              // Figma는 #9AAAA4(흰 배경에서 2.4:1)지만 글자 대비 4.5:1을 위해 공용 보조색을 쓴다.
              Text(sub, style: _small),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 12),
              // 글자를 크게 키우거나 화면이 작아도 넘치지 않게 본문만 스크롤한다.
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    body,
                    style: const TextStyle(color: _green, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

// 게시물 내용 수정 다이얼로그. 빈 내용은 저장할 수 없다.
class _PostTextDialog extends StatefulWidget {
  const _PostTextDialog({required this.initial});

  final String initial;

  @override
  State<_PostTextDialog> createState() => _PostTextDialogState();
}

class _PostTextDialogState extends State<_PostTextDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('내용 수정'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      minLines: 3,
      maxLines: 6,
      onChanged: (_) => setState(() {}),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      TextButton(
        onPressed: _controller.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, _controller.text.trim()),
        child: const Text('저장'),
      ),
    ],
  );
}
