import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_text.dart';

const _green = AppTheme.primary;
const _muted = AppTheme.muted;
const _blue = Color(0xFF49B3C5);
const _small = TextStyle(color: _muted, fontSize: 13);
const _strong = TextStyle(color: _green, fontWeight: FontWeight.bold);
const _email = 'user@antifreeze.com';
const _foodStyles = ['완제품 위주', '밀키트 위주', '혼합'];

enum ProfileView {
  metrics,
  ai,
  account,
  address,
  payment,
  alerts,
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
  String _name = '홍길동';
  String _gender = '남성';
  String _age = '25';
  String _height = '175';
  String _goal = '68';
  String _calories = '2442';
  String _activity = '보통 활동';
  String _food = '밀키트 위주';
  bool _monthly = false;
  final _alerts = [true, true, true];
  final _addresses = <List<String>>[
    ['집', '홍길동', '010-1234-5678', '서울특별시 강남구 테헤란로 123', '101동 1001호'],
  ];
  final _cards = ['신한카드 ···· 1234'];

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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _avatar(30),
                title: Text(_name, style: _strong.copyWith(fontSize: 20)),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_email, style: _small),
                    Text(
                      '신체 지표 · 목표 진행 보기',
                      style: TextStyle(color: AppTheme.accent, fontSize: 12),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right, color: _muted),
                onTap: () => _open(ProfileView.metrics),
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
              const ListTile(
                title: Text('앱 버전'),
                trailing: Text('1.0.0', style: _small),
              ),
            ]),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                if (await _confirm(context, '로그아웃', '로그아웃하시겠어요?') &&
                    context.mounted) {
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
            const Center(child: Text('$_email 계정으로 로그인됨', style: _small)),
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
              trailing: Icon(
                _food == _foodStyles[index]
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: AppTheme.accent,
              ),
              onTap: () {
                setState(() => _food = _foodStyles[index]);
                refresh(() {});
              },
            ),
        ]),
        const SizedBox(height: 14),
        const Text('홈의 AI 추천과 쇼핑의 기본 카테고리가 이 설정에 맞춰 바뀌어요.', style: _small),
      ]),
      ProfileView.account => _page(context, '계정 관리', [
        _menu([
          const ListTile(
            title: Text('이메일'),
            trailing: Text(_email, style: _small),
          ),
          _row('비밀번호 변경', () => _password(context)),
        ]),
        const SizedBox(height: 16),
        _menu([_row('회원 탈퇴', () => _withdraw(context))]),
        const SizedBox(height: 10),
        const Text('탈퇴하면 기록과 포인트가 모두 삭제되고 되돌릴 수 없어요.', style: _small),
      ]),
      ProfileView.address => _page(
        context,
        '배송지 관리',
        [
          if (_addresses.isEmpty) _panel([const Text('등록한 배송지가 없어요.')]),
          for (var i = 0; i < _addresses.length; i++) ...[
            _menu([
              _row(
                '${_addresses[i][0]}${i == 0 ? ' · 기본' : ''}',
                () => _editAddress(context, refresh, i),
                subtitle:
                    '${_addresses[i][3]} ${_addresses[i][4]}\n${_addresses[i][1]} · ${_addresses[i][2]}',
              ),
            ]),
            const SizedBox(height: 10),
          ],
        ],
        trailing: TextButton(
          onPressed: () => _editAddress(context, refresh, null),
          child: const Text('추가'),
        ),
      ),
      ProfileView.payment => _page(
        context,
        '결제 수단',
        [
          _menu([
            for (var i = 0; i < _cards.length; i++)
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: Text(_cards[i]),
                trailing: i == 0 ? const Text('기본', style: _small) : null,
              ),
            if (_cards.isEmpty) const ListTile(title: Text('등록한 결제 수단이 없어요.')),
          ]),
          const SizedBox(height: 14),
          const Text('프로토타입에서는 카드사와 끝 4자리만 저장해요.', style: _small),
        ],
        trailing: TextButton(
          onPressed: () => _addCard(context, refresh),
          child: const Text('추가'),
        ),
      ),
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
              onChanged: (value) => refresh(() => _alerts[i] = value),
            ),
        ]),
        const SizedBox(height: 10),
        const Text('끈 알림은 알림함에도 쌓이지 않아요.', style: _small),
        _group('기기 알림', [
          const ListTile(
            title: Text('기기 알림 권한'),
            trailing: Text('허용 필요', style: _small),
          ),
        ]),
        const SizedBox(height: 10),
        const Text('권한을 허용하면 앱을 닫아도 알림을 받을 수 있어요.', style: _small),
      ]),
      ProfileView.blocked => _page(context, '차단한 사용자', [
        const SizedBox(height: 28),
        _panel([const Center(child: Text('차단한 사용자가 없어요.'))]),
        const SizedBox(height: 12),
        const Center(
          child: Text('차단을 해제하면 그 사용자의 게시물과 댓글이 다시 보여요.', style: _small),
        ),
      ]),
      ProfileView.notices => _page(context, '공지사항', [
        _menu([
          _row(
            '연속 기록 보상이 생겼어요',
            () => _message(
              context,
              '연속 기록 보상이 생겼어요',
              '식단을 하루에 처음 기록하면 5P를 받고, 연속 기록 일수가 늘어나요.',
            ),
            subtitle: '2026.10.21',
          ),
          _row(
            '상품 구매 포인트 적립 정책 변경',
            () => _message(
              context,
              '상품 구매 포인트 적립 정책 변경',
              '상품 구매 후 포인트 내역을 확인할 수 있어요.',
            ),
            subtitle: '안내',
          ),
          _row(
            'Antifreeze 서비스를 시작해요',
            () => _message(
              context,
              'Antifreeze 서비스를 시작해요',
              '식단을 기록하고 크루와 함께 꾸준히 이어가세요.',
            ),
            subtitle: '안내',
          ),
        ]),
      ]),
      ProfileView.help => _help(context),
      ProfileView.terms => _document(context, '서비스 이용약관', terms),
      ProfileView.privacy => _document(context, '개인정보 처리방침', privacy),
      ProfileView.licenses => _document(context, '오픈소스 라이선스', licenses),
    };
  }

  Widget _metrics(BuildContext context, StateSetter refresh) => _page(
    context,
    '프로필',
    [
      Row(
        children: [
          _avatar(36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name, style: _strong.copyWith(fontSize: 22)),
                const Text(_email, style: _small),
                Text(
                  '만 $_age세 · $_gender · $_height'
                  'cm',
                  style: _small,
                ),
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
          children: [
            Expanded(
              child: Text(
                '${(74 - (double.tryParse(_goal) ?? 68)).abs().toStringAsFixed(1)}kg 남음',
                style: _strong.copyWith(fontSize: 24),
              ),
            ),
            const Text(
              '35%',
              style: TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: .35,
          color: _blue,
          backgroundColor: AppTheme.border,
          borderRadius: BorderRadius.circular(5),
          minHeight: 6,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('시작 77.3kg', style: _small),
            const Text('현재 74kg', style: _small),
            Text(
              '목표 $_goal'
              'kg',
              style: _small,
            ),
          ],
        ),
        const Divider(color: AppTheme.border),
        const Text(
          '권장 속도(주 0.5kg)로 가면 약 12주 뒤 · 1월 5일 전후에 도달해요.',
          style: _small,
        ),
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('BMI', style: _small),
            Text('과체중', style: _small),
          ],
        ),
        const Text(
          '24.2',
          style: TextStyle(
            color: _green,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: .55,
          color: const Color(0xFF99D6E1),
          backgroundColor: AppTheme.border,
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('저체중', style: _small),
            Text('정상 18.5~23', style: _small),
            Text('과체중 23~', style: _small),
          ],
        ),
      ]),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child: _panel([_stat('기초대사량', '1,714 kcal')])),
          const SizedBox(width: 10),
          Expanded(child: _panel([_stat('하루 목표 칼로리', '$_calories kcal')])),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child: _panel([_stat('하루 물 권장량', '2.2 L')])),
          const SizedBox(width: 10),
          Expanded(child: _panel([_stat('최근 7일 평균 섭취', '677 kcal')])),
        ],
      ),
      _group('하루 권장 영양', [
        const ListTile(title: Text('탄수화물'), trailing: Text('256g')),
        const ListTile(title: Text('단백질'), trailing: Text('128g')),
        const ListTile(title: Text('지방'), trailing: Text('64g')),
      ]),
      const SizedBox(height: 12),
      const Text('모든 수치는 입력한 정보로 계산한 참고값이에요.', style: _small),
      const SizedBox(height: 14),
      _menu([
        _row(
          '정보 수정',
          () => _editMetrics(context, refresh),
          subtitle: '닉네임 · 신체 정보 · 활동량 · 목표 칼로리',
        ),
      ]),
    ],
    trailing: TextButton(
      onPressed: () => _editMetrics(context, refresh),
      child: const Text('편집'),
    ),
  );

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
                  _field('닉네임', fields[0], (value) => fields[0] = value),
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
                  for (var i = 1; i <= 3; i++)
                    _field(
                      ['', '나이', '키', '목표 체중'][i],
                      fields[i],
                      (value) => fields[i] = value,
                      numeric: true,
                    ),
                ]),
                _group('활동량', [
                  for (final item in ['비활동적', '보통 활동', '활동적'])
                    ListTile(
                      title: Text(item),
                      trailing: Icon(
                        activity == item
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: AppTheme.accent,
                      ),
                      onTap: () => update(() => activity = item),
                    ),
                ]),
                _group('목표 칼로리', [
                  _field(
                    '하루 목표',
                    fields[4],
                    (value) => fields[4] = value,
                    numeric: true,
                  ),
                ]),
              ],
              back: '프로필',
              action: _action('저장', () {
                if (form.currentState!.validate()) Navigator.pop(context, true);
              }),
            ),
          ),
        ),
      ),
    );
    if (saved != true || !mounted) return;
    setState(() {
      _name = fields[0].trim();
      _age = fields[1].trim();
      _height = fields[2].trim();
      _goal = fields[3].trim();
      _calories = fields[4].trim();
      _gender = gender;
      _activity = activity;
    });
    refresh(() {});
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
                SwitchListTile(
                  title: const Text('기본 배송지로 설정'),
                  value: makeDefault,
                  onChanged: (value) => update(() => makeDefault = value),
                ),
                if (index != null)
                  TextButton(
                    onPressed: () async {
                      if (await _confirm(
                            context,
                            '배송지 삭제',
                            '이 배송지를 삭제하시겠어요?',
                          ) &&
                          context.mounted) {
                        Navigator.pop(context, 'delete');
                      }
                    },
                    child: const Text('배송지 삭제'),
                  ),
              ],
              back: '배송지',
              action: _action('저장', () {
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
              _field('현재 비밀번호', '', (_) {}, secret: true),
              _field(
                '새 비밀번호',
                '',
                (value) => password = value,
                secret: true,
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
                validator: (value) =>
                    value == password ? null : '새 비밀번호가 일치하지 않아요.',
              ),
            ]),
            const SizedBox(height: 12),
            const Text('다른 서비스와 같은 비밀번호는 피해 주세요.', style: _small),
            const SizedBox(height: 16),
            _action('변경하기', () {
              if (form.currentState!.validate()) {
                _message(context, '비밀번호 변경', '데모에서는 입력 형식만 확인할 수 있어요.');
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
                  style: _strong.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 14),
                _panel([
                  const Text(
                    '식단·체중 기록과 포인트가 삭제되고 복구할 수 없어요. 진행 중인 정기 구독은 먼저 해지해 주세요.',
                  ),
                ]),
                _group('떠나시는 이유 (선택)', [
                  for (final item in [
                    '기록하기 번거로워요',
                    '원하는 상품이 없어요',
                    '다른 앱을 쓸 거예요',
                    '개인정보가 걱정돼요',
                    '기타',
                  ])
                    ListTile(
                      title: Text(item),
                      trailing: Icon(
                        reason == item
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      onTap: () =>
                          update(() => reason = reason == item ? null : item),
                    ),
                ]),
                CheckboxListTile(
                  value: acknowledged,
                  title: const Text('안내 사항을 모두 확인했어요'),
                  onChanged: (value) =>
                      update(() => acknowledged = value ?? false),
                ),
                _field('비밀번호 확인', '', (_) {}, secret: true),
              ],
              back: '계정 관리',
              action: _action(
                '탈퇴하기',
                acknowledged
                    ? () {
                        if (form.currentState!.validate()) {
                          _message(context, '회원 탈퇴', '데모에서는 계정을 삭제할 수 없어요.');
                        }
                      }
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _help(BuildContext context) {
    const questions = [
      ('권장 칼로리는 어떻게 계산되나요?', '입력한 신체 정보와 활동량을 기준으로 계산해요.'),
      ('포인트는 어떻게 모으고 쓰나요?', '식단 기록과 크루 활동으로 모아 쇼핑에서 사용할 수 있어요.'),
      ('연속 기록이 끊겼어요.', '오늘 식단을 기록하면 다시 시작할 수 있어요.'),
      ('정기 구독을 건너뛰거나 해지하려면?', '주문 · 구독 내역에서 정기 구독을 선택해 주세요.'),
      ('크루를 나가고 싶어요.', '내 크루의 더보기 메뉴에서 탈퇴할 수 있어요.'),
      ('불쾌한 게시물을 봤어요.', '게시물 메뉴에서 신고 옵션을 확인해 주세요.'),
    ];
    return _page(context, '고객센터', [
      _group('자주 묻는 질문', [
        for (final (question, answer) in questions)
          _row(question, () => _message(context, question, answer)),
      ]),
      _group('1:1 문의', [
        _row('문의하기', () {
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
                      _message(context, '1:1 문의', '데모에서는 문의를 전송할 수 없어요.');
                    }
                  }),
                ),
              ),
            ),
          );
        }),
      ]),
    ]);
  }
}

Widget _document(BuildContext context, String title, List<String> lines) =>
    _page(context, title, [
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            line,
            style: TextStyle(
              color: _green,
              height: 1.5,
              fontWeight: RegExp(r'^(제\d+조|\d+\.)').hasMatch(line)
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
}) => ListTile(
  leading: icon == null ? null : Icon(icon, color: _green, size: 21),
  title: Text(title, style: const TextStyle(color: _green, fontSize: 15)),
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
  FormFieldValidator<String>? validator,
}) => Padding(
  padding: const EdgeInsets.all(10),
  child: TextFormField(
    initialValue: initial,
    obscureText: secret,
    maxLines: lines,
    keyboardType: numeric
        ? const TextInputType.numberWithOptions(decimal: true)
        : null,
    decoration: InputDecoration(labelText: label),
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

Widget _action(String title, VoidCallback? onPressed) => SizedBox(
  width: double.infinity,
  height: 50,
  child: FilledButton(
    style: FilledButton.styleFrom(
      backgroundColor: _green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    onPressed: onPressed,
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  ),
);

Future<bool> _confirm(BuildContext context, String title, String text) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인'),
          ),
        ],
      ),
    ) ??
    false;

void _message(BuildContext context, String title, String text) =>
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _strong.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              Text(text, style: _small),
              const SizedBox(height: 20),
              _action('닫기', () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
