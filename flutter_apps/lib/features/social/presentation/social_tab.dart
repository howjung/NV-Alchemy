import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';

const _ink = AppTheme.primary;
const _muted = AppTheme.muted;
const _tint = Color(0xFFEAF1ED);
const _blue = Color(0xFFE2F1F3);
const _crewName = '칼로리 컷어스';
const _crewGoal = '-5kg 감량 | 밀키트 식단 위주';
const _gutter = EdgeInsets.symmetric(horizontal: 20);

enum SocialView { crew, explore, feed }

class SocialTab extends StatefulWidget {
  const SocialTab({this.initialView = SocialView.crew, super.key});

  final SocialView initialView;

  @override
  State<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab> {
  late SocialView _view = widget.initialView;
  int? _pending;
  int? _joined;
  String? _created;
  String _description = '';
  String _query = '';
  final _posts = <String>[];
  final _members = [for (var i = 0; i < 4; i++) '프로필 이름'];
  final _requests = [false, false, false, false];

  bool get _inCrew => _created != null || _joined != null;

  void _switch(SocialView view) => setState(() {
    _view = view;
    _query = '';
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: DefaultTextStyle.merge(
      style: const TextStyle(color: _ink),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              children: [
                PopupMenuButton<SocialView>(
                  tooltip: '소셜 화면 선택',
                  onSelected: _switch,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: SocialView.crew, child: Text('크루')),
                    PopupMenuItem(value: SocialView.feed, child: Text('전체')),
                  ],
                  child: Row(
                    children: [
                      Text(
                        _view == SocialView.feed ? '전체' : '크루',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.keyboard_arrow_down, color: _muted),
                    ],
                  ),
                ),
                if (_view == SocialView.feed) ...[
                  const SizedBox(width: 26),
                  Expanded(
                    child: _search(
                      '검색',
                      (value) => setState(() => _query = value),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  if (_inCrew)
                    PopupMenuButton<String>(
                      tooltip: '크루 메뉴',
                      onSelected: _crewAction,
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'members',
                          child: Text('크루원 목록'),
                        ),
                        if (_created != null)
                          const PopupMenuItem(
                            value: 'requests',
                            child: Text('신청 중인 크루원'),
                          ),
                        PopupMenuItem(
                          value: 'leave',
                          child: Text(_created == null ? '크루 탈퇴' : '크루 삭제'),
                        ),
                      ],
                      icon: const Icon(Icons.more_horiz, color: _muted),
                    ),
                ],
              ],
            ),
          ),
          if (_view != SocialView.feed)
            Padding(
              padding: _gutter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _tint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    _segment('내 크루', SocialView.crew),
                    _segment('크루 탐색', SocialView.explore),
                  ],
                ),
              ),
            ),
          Expanded(
            child: switch (_view) {
              SocialView.feed => _feed(),
              SocialView.explore => _explore(),
              SocialView.crew => _inCrew ? _crew() : _empty(),
            },
          ),
        ],
      ),
    ),
  );

  Widget _segment(String label, SocialView view) => Expanded(
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: _view == view ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => _switch(view),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _view == view ? _ink : _muted,
                fontWeight: _view == view ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _empty() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 64),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/social_15.svg',
            width: 120,
            height: 138,
          ),
          const SizedBox(height: 14),
          const Text(
            '크루에 가입되지 않았습니다.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('크루 탐색에서 크루에 가입하세요.', style: TextStyle(color: _muted)),
          const SizedBox(height: 28),
          _button('크루 탐색하기', () => _switch(SocialView.explore), pill: true),
        ],
      ),
    ),
  );

  Widget _explore() {
    final matches = '$_crewName $_crewGoal'.contains(_query.trim());
    return ListView(
      key: const PageStorageKey('crew-explore'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      children: [
        _search('크루 이름 또는 목표 검색', (value) => setState(() => _query = value)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              if (_pending == null) return;
              setState(() {
                _joined = _pending;
                _pending = null;
              });
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('새로고침'),
          ),
        ),
        if (!matches)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: Text('검색 결과가 없어요.')),
          ),
        if (matches)
          for (var i = 0; i < 5; i++)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _crewName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _crewGoal,
                              style: TextStyle(color: _muted, fontSize: 13),
                            ),
                            Text(
                              '3/5명',
                              style: TextStyle(color: _muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _joined == i ? _tint : _blue,
                          foregroundColor: _ink,
                        ),
                        onPressed: _joined == i
                            ? () => _switch(SocialView.crew)
                            : _pending == i
                            ? null
                            : () => setState(() => _pending = i),
                        child: Text(
                          _joined == i
                              ? '가입 완료'
                              : _pending == i
                              ? '신청 대기'
                              : '참가 신청',
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 4) const Divider(height: 1, color: AppTheme.border),
              ],
            ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: _button('크루 생성', _create, icon: Icons.add, pill: true),
        ),
      ],
    );
  }

  Widget _crew() => ListView(
    key: const PageStorageKey('my-crew'),
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              _created ?? '크루 이름',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${_members.length}/5명 · ${_created == null ? '크루원' : '크루장'}',
            style: const TextStyle(color: _muted),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        _description.isEmpty ? '크루 한 줄 소개' : _description,
        style: const TextStyle(color: _muted),
      ),
      const SizedBox(height: 10),
      const Text(
        '🔥 크루와 함께 연속 5일',
        style: TextStyle(color: _muted, fontSize: 13),
      ),
      const SizedBox(height: 10),
      _button('오늘 식단 인증하기', _compose, icon: Icons.camera_alt_outlined),
      const SizedBox(height: 24),
      InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('리워드 규칙'),
            content: const Text('이번 주 크루 식단 인증 포인트는 25 / 300P예요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                '리워드 규칙',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text('이번 주 25 / 300P', style: TextStyle(color: _muted)),
            Icon(Icons.chevron_right, color: _muted),
          ],
        ),
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: 25 / 300,
        minHeight: 6,
        color: const Color(0xFF49B3C5),
        backgroundColor: AppTheme.border,
        borderRadius: BorderRadius.circular(6),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 17,
        runSpacing: 10,
        children: [
          for (var i = 0; i < _members.length; i++)
            InkWell(
              onTap: () => _crewAction('members'),
              child: Column(
                children: [
                  _avatar(26, highlighted: i < 2),
                  const SizedBox(height: 5),
                  Text(
                    _members[i],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 20),
      for (final caption in _posts) ...[
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _avatar(18),
          title: const Text('내 게시물'),
          subtitle: Text(caption),
        ),
        const Divider(),
      ],
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: _tint,
          child: Text('민지', style: TextStyle(fontSize: 12)),
        ),
        title: Text('김민지', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('점심 · 2분 전 · 380 kcal', style: TextStyle(color: _muted)),
        trailing: Icon(Icons.more_horiz, color: _muted),
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(onTap: () => _openPost(0), child: const _FoodTile(0)),
      ),
    ],
  );

  Widget _feed() => GridView.builder(
    key: const PageStorageKey('social-feed'),
    padding: const EdgeInsets.only(top: 6, bottom: 4),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    ),
    itemCount: '김민지 점심 식단'.contains(_query.trim()) ? 15 : 0,
    itemBuilder: (_, index) =>
        InkWell(onTap: () => _openPost(index), child: _FoodTile(index)),
  );

  void _openPost(int index) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => _SocialPage(
        title: '게시물',
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('김민지'),
              subtitle: Text('점심 · 2분 전 · 380 kcal'),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _FoodTile(index),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _create() async {
    final result = await Navigator.of(context)
        .push<({String name, String description})>(
          MaterialPageRoute(builder: (_) => const CreateCrewScreen()),
        );
    if (result == null || !mounted) return;
    setState(() {
      _created = result.name;
      _description = result.description;
      _view = SocialView.crew;
    });
  }

  Future<void> _compose() async {
    final caption = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const SocialComposeScreen()),
    );
    if (caption != null && mounted) setState(() => _posts.insert(0, caption));
  }

  Future<void> _crewAction(String action) async {
    if (action == 'leave') {
      final label = _created == null ? '탈퇴' : '삭제';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('크루 $label'),
          content: Text('크루를 $label하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(label),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      setState(() {
        _created = null;
        _joined = null;
        _pending = null;
        _description = '';
        _posts.clear();
        _members
          ..clear()
          ..addAll(List.filled(4, '프로필 이름'));
        _requests.fillRange(0, _requests.length, false);
        _view = SocialView.crew;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('크루를 $label했어요.')));
      return;
    }
    final requests = action == 'requests';
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => StatefulBuilder(
          builder: (context, update) => _SocialPage(
            title: requests ? '신청 중인 크루원' : '크루원 목록',
            child: ListView(
              padding: _gutter,
              children: [
                for (
                  var i = 0;
                  i < (requests ? _requests.length : _members.length);
                  i++
                )
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _avatar(18),
                    title: Text(requests ? '프로필 이름' : _members[i]),
                    trailing: requests
                        ? ActionChip(
                            label: Text(_requests[i] ? '가입 완료' : '대기 중'),
                            backgroundColor: _tint,
                            onPressed: _requests[i]
                                ? null
                                : () => update(() => _requests[i] = true),
                          )
                        : _created == null
                        ? null
                        : ActionChip(
                            label: const Text(
                              '추방하기',
                              style: TextStyle(color: Color(0xFFBD564D)),
                            ),
                            backgroundColor: const Color(0xFFFBEAE7),
                            onPressed: () => update(() => _members.removeAt(i)),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }
}

class CreateCrewScreen extends StatefulWidget {
  const CreateCrewScreen({super.key});

  @override
  State<CreateCrewScreen> createState() => _CreateCrewScreenState();
}

class _CreateCrewScreenState extends State<CreateCrewScreen> {
  final _form = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  int _capacity = 5;

  @override
  Widget build(BuildContext context) => _SocialPage(
    title: '크루 생성',
    action: _button('크루 생성', () {
      if (_form.currentState!.validate()) {
        Navigator.pop(context, (
          name: _name.trim(),
          description: _description.trim(),
        ));
      }
    }),
    child: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(
            '크루 이름 설정',
            '크루 이름을 입력하세요',
            onChanged: (value) => _name = value,
            validator: (value) =>
                (value ?? '').trim().isEmpty ? '크루 이름을 입력하세요' : null,
          ),
          _field('크루 목표 설정', '예) 5kg 감량'),
          _field(
            '크루 소개',
            '크루를 한 줄로 소개해 주세요',
            lines: 3,
            onChanged: (value) => _description = value,
          ),
          const Text('크루 인원 설정', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('최대 인원'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _capacity > 2
                      ? () => setState(() => _capacity--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$_capacity명'),
                IconButton(
                  onPressed: _capacity < 20
                      ? () => setState(() => _capacity++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SocialComposeScreen extends StatefulWidget {
  const SocialComposeScreen({super.key});

  @override
  State<SocialComposeScreen> createState() => _SocialComposeScreenState();
}

class _SocialComposeScreenState extends State<SocialComposeScreen> {
  String _visibility = '공개';
  String _caption = '';

  @override
  Widget build(BuildContext context) => _SocialPage(
    title: '새 게시물',
    action: _button(
      '업로드',
      _caption.trim().isEmpty
          ? null
          : () => Navigator.pop(context, _caption.trim()),
    ),
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            width: 138,
            height: 138,
            decoration: BoxDecoration(
              color: _tint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add, size: 48, color: _muted),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text('업로드할 사진/비디오 추가', style: TextStyle(color: _muted)),
        ),
        const SizedBox(height: 24),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('공개 설정'),
          trailing: DropdownButton<String>(
            value: _visibility,
            items: const [
              DropdownMenuItem(value: '공개', child: Text('공개')),
              DropdownMenuItem(value: '크루만', child: Text('크루만')),
            ],
            onChanged: (value) => setState(() => _visibility = value!),
          ),
        ),
        const Divider(),
        TextField(
          onChanged: (value) => setState(() => _caption = value),
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '내용을 입력하세요.',
            border: InputBorder.none,
          ),
        ),
      ],
    ),
  );
}

class _SocialPage extends StatelessWidget {
  const _SocialPage({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: _ink,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 402),
        child: Column(
          children: [
            Expanded(child: child),
            if (action != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: SizedBox(width: double.infinity, child: action),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _FoodTile extends StatelessWidget {
  const _FoodTile(this.index);

  final int index;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: SvgPicture.asset(
      'assets/images/social_$index.svg',
      fit: BoxFit.cover,
    ),
  );
}

Widget _search(String hint, ValueChanged<String> onChanged) => TextField(
  key: ValueKey(hint),
  onChanged: onChanged,
  style: const TextStyle(fontSize: 14, color: _ink),
  decoration: InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _muted, fontSize: 13),
    prefixIcon: const Icon(Icons.search, size: 20, color: _muted),
    fillColor: _tint,
    filled: true,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide.none,
    ),
  ),
);

Widget _button(
  String label,
  VoidCallback? onPressed, {
  IconData? icon,
  bool pill = false,
}) => FilledButton(
  onPressed: onPressed,
  style: FilledButton.styleFrom(
    backgroundColor: _ink,
    foregroundColor: Colors.white,
    minimumSize: const Size(160, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(pill ? 28 : 14),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  ),
);

Widget _field(
  String label,
  String hint, {
  int lines = 1,
  ValueChanged<String>? onChanged,
  FormFieldValidator<String>? validator,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 18),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextFormField(
        maxLines: lines,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(hintText: hint),
      ),
    ],
  ),
);

Widget _avatar(double radius, {bool highlighted = false}) => Container(
  padding: const EdgeInsets.all(2),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: highlighted ? const Color(0xFF49B3C5) : Colors.transparent,
      width: 2,
    ),
  ),
  child: CircleAvatar(
    radius: radius,
    backgroundColor: AppTheme.border,
    child: Icon(Icons.person, color: Colors.white, size: radius * 1.45),
  ),
);
