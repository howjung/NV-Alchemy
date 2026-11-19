import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/state/moderation.dart';
import '../../../core/state/my_posts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_overlays.dart';
import 'crew_post_card.dart';
import 'post_detail_screen.dart';

const _ink = AppTheme.primary;
const _muted = AppTheme.muted;
const _tint = Color(0xFFEAF1ED);
const _blue = Color(0xFFE2F1F3);
// 크루 탐색 샘플(이름, 목표, 현재/최대 인원). 마지막 크루는 정원이 찼다.
const _crews = [
  (name: '칼로리 컷어스', goal: '-5kg 감량 | 밀키트 식단 위주', now: 3, max: 5),
  (name: '아침 단백질 클럽', goal: '근육 증가 | 완제품 식단 위주', now: 2, max: 6),
  (name: '직장인 도시락 크루', goal: '-3kg 감량 | 도시락 식단 위주', now: 4, max: 5),
  (name: '야식 끊기 챌린지', goal: '체중 유지 | 혼합 식단', now: 1, max: 4),
  (name: '주말 밀프렙 모임', goal: '-4kg 감량 | 밀키트 식단 위주', now: 4, max: 4),
];
const _gutter = EdgeInsets.symmetric(horizontal: 20);

// 크루 피드 샘플 게시물 (Figma SOC-03).
const _crewSamples = [
  (meta: '점심 · 2분 전 · 380 kcal', caption: '오운완 · 점심 380 kcal', time: '2분 전'),
  (
    meta: '저녁 · 1시간 전 · 410 kcal',
    caption: '단백질 채우기 성공 · 저녁 410 kcal',
    time: '1시간 전',
  ),
];

enum SocialView { crew, explore, feed }

class SocialTab extends StatefulWidget {
  const SocialTab({this.initialView = SocialView.feed, super.key});

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
  int _capacity = 5;
  String _query = '';
  final _members = <String>['나']; // 내가 만든 크루의 크루원
  final _requests = [false, false, false, false];
  final _postStore = postStore;

  @override
  void initState() {
    super.initState();
    myPosts.addListener(_onPosts);
    hiddenPosts.addListener(_onPosts);
    blockedUsers.addListener(_onPosts);
  }

  void _onPosts() => setState(() {});

  @override
  void dispose() {
    myPosts.removeListener(_onPosts);
    hiddenPosts.removeListener(_onPosts);
    blockedUsers.removeListener(_onPosts);
    super.dispose();
  }

  bool get _inCrew => _created != null || _joined != null;

  // 크루 소속이 바뀔 때마다 프로필 등 다른 화면이 볼 수 있게 알린다.
  void _setCrew(VoidCallback change) {
    setState(change);
    inCrew.value = _inCrew;
  }

  List<String> get _memberNames => _created != null
      ? _members
      : ['나', for (var i = 1; i < _crewSize.now; i++) '프로필 이름'];

  String get _crewTitle => _created ?? _crews[_joined ?? 0].name;
  ({int now, int max}) get _crewSize => _created != null
      ? (now: _members.length, max: _capacity)
      : (now: _crews[_joined ?? 0].now, max: _crews[_joined ?? 0].max);

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
                AppMenu<SocialView>(
                  tooltip: '소셜 화면 선택',
                  offset: const Offset(-8, 0),
                  onSelected: _switch,
                  selected: _view == SocialView.feed
                      ? SocialView.feed
                      : SocialView.crew,
                  items: const [
                    AppMenuItem(SocialView.feed, '전체'),
                    AppMenuItem(SocialView.crew, '크루'),
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
                  IconButton(
                    tooltip: '게시물 올리기',
                    onPressed: _compose,
                    icon: const Icon(Icons.add_box_outlined, color: _ink),
                  ),
                ] else ...[
                  const Spacer(),
                  if (_inCrew)
                    AppMenu<String>(
                      tooltip: '크루 메뉴',
                      onSelected: _crewAction,
                      width: _created == null ? 148 : 176,
                      items: _created == null
                          ? const [
                              AppMenuItem('leave', '크루 탈퇴하기', danger: true),
                            ]
                          : const [
                              AppMenuItem('requests', '신청 중인 크루원'),
                              AppMenuItem('members', '크루원 목록'),
                              AppMenuItem('leave', '크루 삭제', danger: true),
                            ],
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.more_horiz, color: _muted),
                      ),
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
    child: Semantics(
      button: true,
      selected: _view == view,
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
                  fontWeight: _view == view
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
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
    final query = _query.trim();
    final shown = [
      for (var i = 0; i < _crews.length; i++)
        if ('${_crews[i].name} ${_crews[i].goal}'.contains(query)) i,
    ];
    return ListView(
      key: const PageStorageKey('crew-explore'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      children: [
        _search('크루 이름 또는 목표 검색', (value) => setState(() => _query = value)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _refreshExplore,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('새로고침'),
          ),
        ),
        if (shown.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: Text('검색 결과가 없어요.')),
          ),
        for (final (n, i) in shown.indexed)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _crews[i].name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _crews[i].goal,
                            style: const TextStyle(color: _muted, fontSize: 13),
                          ),
                          Text(
                            '${_crews[i].now}/${_crews[i].max}명',
                            style: const TextStyle(color: _muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _joined == i ? _tint : _blue,
                        foregroundColor: _ink,
                      ),
                      onPressed: () => _apply(i),
                      child: Text(_applyLabel(i)),
                    ),
                  ],
                ),
              ),
              if (n < shown.length - 1)
                const Divider(height: 1, color: AppTheme.border),
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

  String _applyLabel(int i) {
    if (_joined == i) return '가입 완료';
    if (_pending == i) return '신청 대기';
    if (_crews[i].now >= _crews[i].max) return '정원 마감';
    return '참가 신청';
  }

  // 1인 1크루, 정원 마감이면 사유를 알려 준다(PRD 4.5 크루 탐색).
  void _apply(int i) {
    if (_joined == i) return _switch(SocialView.crew);
    if (_pending == i) return;
    if (_inCrew) {
      showAppToast(context, '이미 크루에 가입했어요. 탈퇴한 뒤 신청할 수 있어요.');
    } else if (_crews[i].now >= _crews[i].max) {
      showAppToast(context, '정원이 가득 찬 크루예요.');
    } else {
      setState(() => _pending = i); // 다른 크루에 신청 중이었다면 옮겨 신청한다.
    }
  }

  void _refreshExplore() {
    if (_pending == null) {
      showAppToast(context, '목록을 새로 불러왔어요.');
      return;
    }
    // 서버가 없어 크루장의 수락을 새로고침 때 받은 것으로 흉내 낸다(임시).
    _setCrew(() {
      _joined = _pending;
      _pending = null;
    });
    showAppToast(context, '크루장이 가입을 수락했어요.');
  }

  Widget _crew() => ListView(
    key: const PageStorageKey('my-crew'),
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              _crewTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${_crewSize.now}/${_crewSize.max}명 · ${_created == null ? '크루원' : '크루장'}',
            style: const TextStyle(color: _muted),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        _created != null
            ? (_description.isEmpty ? '크루 한 줄 소개' : _description)
            : _crews[_joined ?? 0].goal,
        style: const TextStyle(color: _muted),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          ExcludeSemantics(
            child: SvgPicture.asset(
              'assets/images/social_flame.svg',
              width: 12,
              height: 17.5,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '크루와 함께 연속 5일',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _button(
        '오늘 식단 인증하기',
        () => _compose(crew: true),
        icon: Icons.camera_alt_outlined,
      ),
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
          for (var i = 0; i < _crewSize.now; i++)
            InkWell(
              onTap: () => _crewAction('members'),
              child: Column(
                children: [
                  _avatar(26, highlighted: i < 2),
                  const SizedBox(height: 5),
                  Text(
                    _created != null ? _members[i] : (i == 0 ? '나' : '프로필 이름'),
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
      // 내가 올린 게시물이 맨 위, 그다음 크루원 게시물.
      for (final post in myPosts.value.where((p) => p.crew)) ...[
        CrewPostCard(
          postId: post.id,
          photoIndex: -post.id % 15,
          author: '나',
          shortName: '나',
          meta: '${post.meal} · 방금 · ${post.visibility}',
          caption: post.caption,
          time: '방금 전',
          store: _postStore,
          onOpen: () => _openPost(
            -post.id % 15,
            postId: post.id,
            caption: post.caption,
            time: '방금 전',
          ),
        ),
        const SizedBox(height: 28),
      ],
      for (final (i, post) in _crewSamples.indexed)
        if (isPostVisible(i)) ...[
          CrewPostCard(
            postId: i,
            photoIndex: i,
            author: '김민지',
            shortName: '민지',
            meta: post.meta,
            caption: post.caption,
            time: post.time,
            store: _postStore,
            onOpen: () => _openPost(i),
          ),
          const SizedBox(height: 28),
        ],
    ],
  );

  Widget _feed() {
    final query = _query.trim();
    // 내가 올린 글이 맨 앞, 그다음 샘플 피드. 비공개·크루만 공개 글도 내게는 보인다.
    final mine = [
      for (final p in myPosts.value)
        if (p.caption.contains(query) || query.isEmpty) p,
    ];
    final samples = [
      if ('김민지 점심 식단'.contains(query))
        for (var i = 0; i < 15; i++)
          if (isPostVisible(i)) i,
    ];
    return GridView.builder(
      key: const PageStorageKey('social-feed'),
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: mine.length + samples.length,
      itemBuilder: (_, index) {
        if (index < mine.length) {
          final post = mine[index];
          final photo = -post.id % 15;
          return _tappableTile(
            photo,
            () => _openPost(
              photo,
              postId: post.id,
              caption: post.caption,
              time: '방금 전',
            ),
          );
        }
        final sample = samples[index - mine.length];
        return _tappableTile(sample, () => _openPost(sample));
      },
    );
  }

  // 이미지가 InkWell을 가리지 않도록 탭 영역을 이미지 위에 겹친다.
  Widget _tappableTile(int index, VoidCallback onTap) => Stack(
    children: [
      _FoodTile(index),
      Positioned.fill(
        child: Semantics(
          button: true,
          label: '식단 게시물 보기',
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: onTap),
          ),
        ),
      ),
    ],
  );

  void _openPost(
    int photoIndex, {
    int? postId,
    String caption = '오운완',
    String time = '3분 전',
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => PostDetailScreen(
        photoIndex: photoIndex,
        postId: postId,
        caption: caption,
        time: time,
        store: _postStore,
      ),
    ),
  );

  Future<void> _create() async {
    if (_inCrew) {
      showAppToast(context, '이미 크루에 가입했어요. 탈퇴한 뒤 만들 수 있어요.');
      return;
    }
    final result = await Navigator.of(context)
        .push<({String name, String goal, String description, int capacity})>(
          MaterialPageRoute(builder: (_) => const CreateCrewScreen()),
        );
    if (result == null || !mounted) return;
    _setCrew(() {
      _created = result.name;
      _description = result.description.isEmpty
          ? result.goal
          : result.description;
      _capacity = result.capacity;
      _members
        ..clear()
        ..add('나');
      _pending = null;
      _view = SocialView.crew;
    });
  }

  // 크루 인증이면 크루 글로, 전체 피드에서 올리면 크루와 무관한 글로 저장한다.
  Future<void> _compose({bool crew = false}) async {
    final result = await Navigator.of(context)
        .push<({String caption, String meal, String visibility})>(
          MaterialPageRoute(
            builder: (_) => SocialComposeScreen(inCrew: _inCrew, forCrew: crew),
          ),
        );
    if (result == null || !mounted) return;
    addMyPost(
      caption: result.caption,
      meal: result.meal,
      visibility: result.visibility,
      crew: crew,
    );
    showAppToast(context, '게시물을 올렸어요.');
  }

  Future<void> _crewAction(String action) async {
    if (action == 'leave') {
      final label = _created == null ? '탈퇴' : '삭제';
      final confirmed = await showConfirmPopup(
        context,
        title: _created == null ? '크루를 탈퇴하시겠습니까?' : '크루를 삭제 하시겠습니까?',
        message: _created == null ? null : '삭제할 경우 되돌릴 수 없습니다.',
        confirmLabel: '$label하기',
      );
      if (!confirmed || !mounted) return;
      detachCrewPosts();
      _setCrew(() {
        _created = null;
        _joined = null;
        _pending = null;
        _description = '';
        _members
          ..clear()
          ..add('나');
        _requests.fillRange(0, _requests.length, false);
        _view = SocialView.crew;
      });
      showAppToast(context, '크루를 $label했어요.');
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
                  i < (requests ? _requests.length : _memberNames.length);
                  i++
                )
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _avatar(18),
                    title: Text(requests ? '프로필 이름' : _memberNames[i]),
                    trailing: requests
                        ? ActionChip(
                            label: Text(_requests[i] ? '가입 완료' : '대기 중'),
                            backgroundColor: _tint,
                            onPressed: _requests[i]
                                ? null
                                : () {
                                    // 최대 인원을 넘겨 수락할 수 없다.
                                    if (_members.length >= _capacity) {
                                      showAppToast(context, '정원이 가득 찼어요.');
                                      return;
                                    }
                                    update(() {
                                      _requests[i] = true;
                                      _members.add('프로필 이름');
                                    });
                                  },
                          )
                        : _created == null
                        ? null
                        : ActionChip(
                            label: const Text(
                              '추방하기',
                              style: TextStyle(color: Color(0xFFBD564D)),
                            ),
                            backgroundColor: const Color(0xFFFBEAE7),
                            onPressed: () async {
                              final confirmed = await showConfirmPopup(
                                context,
                                title: '크루원을 추방하시겠습니까?',
                                confirmLabel: '추방하기',
                              );
                              if (confirmed && context.mounted) {
                                update(() => _members.removeAt(i));
                              }
                            },
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
  String _goal = '';
  String _description = '';
  int _capacity = 5;

  @override
  Widget build(BuildContext context) => _SocialPage(
    title: '크루 생성',
    action: _button('크루 생성', () {
      if (_form.currentState!.validate()) {
        Navigator.pop(context, (
          name: _name.trim(),
          goal: _goal.trim(),
          description: _description.trim(),
          capacity: _capacity,
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
          _field('크루 목표 설정', '예) 5kg 감량', onChanged: (value) => _goal = value),
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
            trailing: AppMenu<int>(
              tooltip: '최대 인원',
              width: 110,
              selected: _capacity,
              onSelected: (value) => setState(() => _capacity = value),
              items: [for (var n = 2; n <= 20; n++) AppMenuItem(n, '$n명')],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$_capacity명', style: const TextStyle(fontSize: 16)),
                    const Icon(Icons.keyboard_arrow_down, color: _muted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class SocialComposeScreen extends StatefulWidget {
  const SocialComposeScreen({
    this.inCrew = false,
    this.forCrew = false,
    super.key,
  });

  /// 크루에 가입했는지. 아니면 "크루만 공개"를 고를 수 없다.
  final bool inCrew;

  /// 크루 식단 인증으로 올리는지(전체 피드에서 올리면 false).
  final bool forCrew;

  @override
  State<SocialComposeScreen> createState() => _SocialComposeScreenState();
}

class _SocialComposeScreenState extends State<SocialComposeScreen> {
  String _visibility = '공개';
  String _meal = meals[1];
  String _caption = '';

  Widget _picker<T>({
    required String title,
    required String tooltip,
    required T selected,
    required String label,
    required List<AppMenuItem<T>> items,
    required ValueChanged<T> onSelected,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    trailing: AppMenu<T>(
      tooltip: tooltip,
      width: 164,
      selected: selected,
      onSelected: onSelected,
      items: items,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const Icon(Icons.keyboard_arrow_down, color: _muted),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => _SocialPage(
    title: widget.forCrew ? '식단 인증' : '새 게시물',
    action: _button(
      '업로드',
      _caption.trim().isEmpty
          ? null
          : () => Navigator.pop(context, (
              caption: _caption.trim(),
              meal: _meal,
              visibility: _visibility,
            )),
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
          child: Text('업로드할 사진 추가', style: TextStyle(color: _muted)),
        ),
        const SizedBox(height: 24),
        _picker<String>(
          title: '끼니',
          tooltip: '끼니',
          selected: _meal,
          label: _meal,
          items: [for (final m in meals) AppMenuItem(m, m)],
          onSelected: (value) => setState(() => _meal = value),
        ),
        const Divider(),
        _picker<String>(
          title: '공개 설정',
          tooltip: '공개 설정',
          selected: _visibility,
          label: _visibility,
          items: [
            const AppMenuItem('공개', '공개'),
            const AppMenuItem('비공개', '비공개'),
            if (widget.inCrew) const AppMenuItem('크루만 공개', '크루만 공개'),
          ],
          onSelected: (value) => setState(() => _visibility = value),
        ),
        if (!widget.inCrew)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              '크루에 가입하면 "크루만 공개"를 고를 수 있어요.',
              style: TextStyle(color: _muted, fontSize: 12),
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
