import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';

const _green = AppTheme.primary;
const _muted = AppTheme.muted;
const _mint = AppTheme.background;
const _chip = Color(0xFFEAF1ED);
const _ai = Color(0xFF5146D9);
const _cyan = Color(0xFF49B3C5);
const _bold = TextStyle(fontWeight: FontWeight.w700);
const _caption = TextStyle(color: _muted, fontSize: 12);

typedef _Product = ({
  String name,
  String category,
  String nutrition,
  int price,
  int score,
});

const _products = <_Product>[
  (
    name: '수비드 닭가슴살 샐러드',
    category: '샐러드',
    nutrition: '380kcal · 탄 22g · 단 34g · 지 9g',
    price: 6900,
    score: 96,
  ),
  (
    name: '곤약밥 소불고기 밀키트 2인',
    category: '밀키트',
    nutrition: '520kcal · 탄 58g · 단 31g · 지 14g',
    price: 12500,
    score: 92,
  ),
  (
    name: '현미 닭가슴살 도시락',
    category: '도시락',
    nutrition: '560kcal · 탄 62g · 단 36g · 지 12g',
    price: 5900,
    score: 90,
  ),
  (
    name: '프로틴 그릭요거트 6개입',
    category: '단백질',
    nutrition: '120kcal · 탄 9g · 단 15g · 지 3g',
    price: 8900,
    score: 84,
  ),
];

String _won(int value) =>
    '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}원';

enum ShoppingView { catalog, cart, checkout, complete, orders }

class ShoppingTab extends StatefulWidget {
  const ShoppingTab({
    this.initialView = ShoppingView.catalog,
    this.orderRequests = 0,
    this.onViewChanged,
    super.key,
  });
  final ShoppingView initialView;
  final int orderRequests;
  final ValueChanged<ShoppingView>? onViewChanged;

  @override
  State<ShoppingTab> createState() => _ShoppingTabState();
}

class _ShoppingTabState extends State<ShoppingTab> {
  final _cart = <int, int>{};
  final _compared = <int>{};
  final _favorites = <int>{};
  final _orders = <({Map<int, int> items, int total, int points})>[];
  late ShoppingView _view = widget.initialView;
  String _query = '';
  String _category = '전체 상품';
  String _sort = 'AI 추천순';
  bool _fit = true;
  bool _agreed = false;
  int _points = 0;
  int _balance = 2500;
  int? _subscription;
  String _cycle = '매주';
  String _day = '월';
  int _quantity = 1;
  int _skips = 0;
  String _delivery = '문 앞에 놓아 주세요';

  @override
  void didUpdateWidget(covariant ShoppingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orderRequests != oldWidget.orderRequests) {
      _view = ShoppingView.orders;
    }
  }

  int get _count => _cart.values.fold(0, (total, value) => total + value);
  int get _subtotal => _cart.entries.fold(
    0,
    (total, item) => total + _products[item.key].price * item.value,
  );
  int get _pointLimit =>
      (_subtotal < _balance ? _subtotal : _balance) ~/ 100 * 100;

  void _open(ShoppingView view) {
    setState(() => _view = view);
    widget.onViewChanged?.call(view);
  }

  void _change(int index, int quantity) => setState(() {
    if (quantity <= 0) {
      _cart.remove(index);
    } else {
      _cart[index] = quantity;
    }
    if (_points > _pointLimit) _points = _pointLimit;
  });

  @override
  Widget build(BuildContext context) {
    if (_view == ShoppingView.catalog) return _catalog();
    return switch (_view) {
      ShoppingView.cart => _cartPage(),
      ShoppingView.checkout => _checkout(),
      ShoppingView.complete => _complete(),
      ShoppingView.orders => _history(),
      ShoppingView.catalog => _catalog(),
    };
  }

  Widget _catalog() {
    final visible = [
      for (var index = 0; index < _products.length; index++)
        if ((_category == '전체 상품' || _category == _products[index].category) &&
            (!_fit || _products[index].score >= 90) &&
            '${_products[index].name} ${_products[index].category}'.contains(
              _query.trim(),
            ))
          index,
    ];
    if (_sort == '낮은 가격순') {
      visible.sort((a, b) => _products[a].price.compareTo(_products[b].price));
    }
    return ColoredBox(
      color: _mint,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '쇼핑',
                            style: TextStyle(
                              color: _green,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton.outlined(
                          tooltip: '장바구니',
                          onPressed: () => _open(ShoppingView.cart),
                          icon: Badge(
                            isLabelVisible: _count > 0,
                            label: Text('$_count'),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: _green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: _muted),
                        hintText: '밀키트, 도시락, 샐러드 검색',
                        fillColor: _chip,
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                key: const PageStorageKey('shopping-catalog'),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                children: [
                  _panel([
                    Row(
                      children: [
                        _tag('AI', ai: true),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text('10월 21일 기준, 오늘 남은 칼로리', style: _caption),
                        ),
                        const Text('점심·저녁·간식', style: _caption),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          '1,502',
                          style: TextStyle(
                            color: _green,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text('kcal', style: TextStyle(color: _muted)),
                        Spacer(),
                        Text('3끼 기준', style: _caption),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(child: _Macro('탄수화물', '110g 남음', .45)),
                        SizedBox(width: 15),
                        Expanded(child: _Macro('단백질', '53g 더 필요', .30)),
                        SizedBox(width: 15),
                        Expanded(child: _Macro('지방', '24g 남음', .62)),
                      ],
                    ),
                    const Divider(color: AppTheme.border),
                    Row(
                      children: [
                        const Expanded(child: Text('내 식단에 맞는 상품만 보기')),
                        Switch(
                          value: _fit,
                          activeThumbColor: Colors.white,
                          activeTrackColor: _cyan,
                          onChanged: (value) => setState(() => _fit = value),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 12),
                  const Text('카테고리 선택', style: _caption),
                  const SizedBox(height: 5),
                  _panel([
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category,
                        isExpanded: true,
                        isDense: true,
                        items:
                            [
                                  '전체 상품',
                                  ..._products.map(
                                    (product) => product.category,
                                  ),
                                ]
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value, style: _bold),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => _category = value!),
                      ),
                    ),
                  ]),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '상품 ${visible.length}개',
                          style: const TextStyle(color: _muted),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sort,
                          items: const [
                            DropdownMenuItem(
                              value: 'AI 추천순',
                              child: Text(
                                'AI 추천순',
                                style: TextStyle(
                                  color: _ai,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: '낮은 가격순',
                              child: Text('낮은 가격순'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _sort = value!),
                        ),
                      ),
                    ],
                  ),
                  for (final index in visible) ...[
                    _productCard(index),
                    const SizedBox(height: 10),
                  ],
                  if (visible.isEmpty)
                    const Center(
                      child: Text('조건에 맞는 상품이 없어요.', style: _caption),
                    ),
                  const SizedBox(height: 12),
                  const Center(child: Text('가격은 예시 데이터예요.', style: _caption)),
                  TextButton(
                    onPressed: () => _open(ShoppingView.orders),
                    child: const Text('주문 · 구독 내역'),
                  ),
                ],
              ),
            ),
            if (_count > 0)
              ColoredBox(
                color: _green,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '장바구니 $_count개\n${_won(_subtotal)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _green,
                        ),
                        onPressed: () => _open(ShoppingView.cart),
                        child: const Text('장바구니 보기'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(int index) {
    final product = _products[index];
    final expanded = _compared.contains(index);
    return _panel([
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _thumb(index, 92),
              Positioned(
                left: 3,
                top: 3,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() {
                      if (!_favorites.add(index)) _favorites.remove(index);
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        _favorites.contains(index)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 15,
                        color: _muted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [_tag(product.category), _tag('AI 추천', ai: true)],
                ),
                const SizedBox(height: 5),
                Text(product.name, style: _bold),
                Text(product.nutrition, style: _caption),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'AI 적합도 ${product.score}%',
                      style: const TextStyle(
                        color: _ai,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _bar(product.score / 100, _ai)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      const Text('최저가 (배송비 포함)', style: _caption),
      Row(
        children: [
          Expanded(
            child: Text(
              _won(product.price),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              if (!_compared.add(index)) _compared.remove(index);
            }),
            child: Text(
              '가격 비교 ${index == 3 ? 2 : 3}곳 ${expanded ? '▴' : '▾'}',
              style: _caption,
            ),
          ),
        ],
      ),
      if (expanded)
        for (var i = 0; i < (index == 3 ? 2 : 3); i++) ...[
          const Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _pair(
              ['식단공방\n무료배송', '오늘한끼\n무료배송', '푸드랩 마켓\n배송비 2,500원'][i],
              _won(product.price + [0, 1000, 2800][i]),
              strong: true,
            ),
          ),
        ],
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _subscriptionPage(index),
              child: const Text('정기 배송'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _button(
              '장바구니 담기',
              () => _change(index, (_cart[index] ?? 0) + 1),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _cartPage() => _page(
    '장바구니',
    '쇼핑',
    () => _open(ShoppingView.catalog),
    [
      if (_cart.isEmpty) _panel([const Center(child: Text('장바구니가 비어 있어요.'))]),
      for (final item in _cart.entries) ...[
        _panel([
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumb(item.key, 72),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pair(
                      _products[item.key].name,
                      _won(_products[item.key].price * item.value),
                      strong: true,
                    ),
                    Text(
                      '식단공방 · ${_won(_products[item.key].price)}',
                      style: _caption,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _stepper(
                            item.value,
                            (value) => _change(item.key, value),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _change(item.key, 0),
                          child: const Text(
                            '빼기',
                            style: TextStyle(color: Color(0xFFB54E45)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
        const SizedBox(height: 10),
      ],
      _panel([
        _pair('상품 금액', _won(_subtotal)),
        const SizedBox(height: 10),
        _pair('배송비', '무료'),
        const Divider(color: AppTheme.border),
        _pair('결제 예정 금액', _won(_subtotal), strong: true),
      ]),
      const SizedBox(height: 16),
      const Center(child: Text('포인트는 다음 화면(주문/결제)에서 사용해요.', style: _caption)),
    ],
    action: _button(
      '${_won(_subtotal)} 주문하기',
      _cart.isEmpty
          ? null
          : () {
              _agreed = false;
              _open(ShoppingView.checkout);
            },
    ),
  );

  Widget _checkout() => _page(
    '주문/결제',
    '장바구니',
    () => _open(ShoppingView.cart),
    [
      _section(
        '주문 상품',
        _panel([
          for (final item in _cart.entries) ...[
            _pair(
              _products[item.key].name,
              '${item.value}개 · ${_won(_products[item.key].price * item.value)}',
            ),
            const Divider(color: AppTheme.border),
          ],
          const Text('판매처 식단공방 · 무료배송', style: _caption),
        ]),
      ),
      _section(
        '배송지',
        _panel([
          _pair('홍길동', '기본', strong: true),
          const SizedBox(height: 6),
          const Text(
            '경기도 성남시 수정구 ○○로 123\n101동 1001호 · 010-0000-1234',
            style: _caption,
          ),
        ]),
      ),
      _panel([
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _delivery,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: '문 앞에 놓아 주세요',
                child: Text('문 앞에 놓아 주세요'),
              ),
              DropdownMenuItem(value: '직접 받을게요', child: Text('직접 받을게요')),
            ],
            onChanged: (value) => setState(() => _delivery = value!),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      _section(
        '포인트 사용',
        _panel([
          _pair('보유 포인트', _won(_balance).replaceFirst('원', 'P'), strong: true),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _pickPoints,
                  child: Text('$_points P'),
                ),
              ),
              _button(
                '전액 사용',
                _pointLimit < 500
                    ? null
                    : () => setState(() => _points = _pointLimit),
              ),
            ],
          ),
          const Text('500P부터 100P 단위로 사용할 수 있어요. (1P = 1원)', style: _caption),
        ]),
      ),
      _section('결제 수단', _panel([const Text('등록한 카드 ···· 1234')])),
      _section(
        '결제 금액',
        _panel([
          _pair('상품 금액', _won(_subtotal)),
          _pair('배송비', '무료'),
          _pair('포인트 사용', '-${_won(_points)}'),
          const Divider(color: AppTheme.border),
          _pair('최종 결제 금액', _won(_subtotal - _points), strong: true),
        ]),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: _agreed,
        onChanged: (value) => setState(() => _agreed = value ?? false),
        title: const Text('주문 내용을 확인했고 결제에 동의해요.'),
      ),
    ],
    action: _button(
      '${_won(_subtotal - _points)} 결제하기',
      !_agreed || _cart.isEmpty ? null : _placeOrder,
    ),
  );

  Future<void> _pickPoints() async {
    final value = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('포인트 사용', style: _bold)),
            for (final value in [
              0,
              for (var points = 500; points <= _pointLimit; points += 100)
                points,
            ])
              ListTile(
                title: Text(value == 0 ? '사용 안 함' : '$value P'),
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (mounted && value != null) setState(() => _points = value);
  }

  void _placeOrder() => setState(() {
    _orders.insert(0, (
      items: Map.of(_cart),
      total: _subtotal - _points,
      points: _points,
    ));
    _balance -= _points;
    _cart.clear();
    _points = 0;
    _view = ShoppingView.complete;
  });

  String _orderName(Map<int, int> items) {
    final first = _products[items.keys.first].name;
    return items.length == 1 ? first : '$first 외 ${items.length - 1}개';
  }

  Widget _complete() =>
      _page('주문 완료', '쇼핑', () => _open(ShoppingView.catalog), [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle, color: Color(0xFF11836C), size: 56),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _orders.isEmpty ? '완료된 주문이 없어요' : '주문이 완료됐어요',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 14),
        if (_orders.isNotEmpty)
          _panel([
            _pair('주문 상품', _orderName(_orders.first.items)),
            const Divider(color: AppTheme.border),
            _pair('사용 포인트', '${_orders.first.points}P'),
            _pair('결제 금액', _won(_orders.first.total), strong: true),
            const Text('등록한 카드 ···· 1234', style: _caption),
          ]),
        const SizedBox(height: 18),
        _button('주문 내역 보기', () => _open(ShoppingView.orders)),
        TextButton(
          onPressed: () => _open(ShoppingView.catalog),
          child: const Text('쇼핑 계속하기'),
        ),
      ]);

  Widget _history() =>
      _page('주문 · 구독 내역', '쇼핑', () => _open(ShoppingView.catalog), [
        _section(
          '정기 구독',
          _panel([
            if (_subscription case final index?)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_products[index].name),
                subtitle: Text('$_cycle $_day요일 · $_quantity개 · 건너뛰기 $_skips회'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _subscriptionPage(index, managing: true),
              )
            else
              const Text('진행 중인 정기 구독이 없어요.', style: _caption),
          ]),
        ),
        _section(
          '주문 내역',
          _panel([
            if (_orders.isEmpty) const Text('주문 내역이 없어요.', style: _caption),
            for (final order in _orders)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_orderName(order.items)),
                subtitle: const Text('결제 완료'),
                trailing: Text(_won(order.total), style: _bold),
                onTap: () => _detail(order.items, order.total, order.points),
              ),
          ]),
        ),
      ]);

  void _detail(Map<int, int> items, int total, int points) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: _mint,
            body: _page('주문 상세', '내역', () => Navigator.pop(context), [
              _section(
                '주문 상품',
                _panel([
                  for (final item in items.entries)
                    _pair(_products[item.key].name, '${item.value}개'),
                ]),
              ),
              _section(
                '배송 상태',
                _panel([
                  const Text('배송 준비 중', style: _bold),
                  const Text('주문 완료 → 배송 시작 → 배송 완료', style: _caption),
                ]),
              ),
              _section(
                '배송지',
                _panel([const Text('경기도 성남시 수정구 ○○로 123\n101동 1001호 (홍길동)')]),
              ),
              _section(
                '결제 정보',
                _panel([
                  _pair('상품 금액', _won(total + points)),
                  _pair('포인트 사용', '-${_won(points)}'),
                  _pair('결제 금액', _won(total), strong: true),
                ]),
              ),
            ]),
          ),
        ),
      );

  Future<void> _subscriptionPage(int index, {bool managing = false}) async {
    final product = _products[index];
    var cycle = managing ? _cycle : '매주';
    var day = managing ? _day : '월';
    var quantity = managing ? _quantity : 1;
    var skips = managing ? _skips : 0;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, update) => Scaffold(
            backgroundColor: _mint,
            body: _page(
              managing ? '정기 구독' : '정기 배송 신청',
              managing ? '내역' : '쇼핑',
              () => Navigator.pop(context),
              [
                _panel([
                  Row(
                    children: [
                      _thumb(index, 68),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: _bold),
                            Text(
                              '식단공방 · 회당 ${_won(product.price)}',
                              style: _caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 16),
                _section(
                  '배송 주기',
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final value in ['매주', '2주마다', '4주마다'])
                        ChoiceChip(
                          label: Text(value),
                          selected: value == cycle,
                          onSelected: (_) => update(() => cycle = value),
                        ),
                    ],
                  ),
                ),
                _section(
                  '배송 요일',
                  Wrap(
                    spacing: 4,
                    children: [
                      for (final value in ['월', '화', '수', '목', '금', '토', '일'])
                        ChoiceChip(
                          label: Text(value),
                          selected: value == day,
                          onSelected: (_) => update(() => day = value),
                        ),
                    ],
                  ),
                ),
                _panel([
                  Row(
                    children: [
                      const Expanded(child: Text('수량')),
                      _stepper(
                        quantity,
                        (value) => update(() => quantity = value),
                        minimum: 1,
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 10),
                _panel([
                  _pair(
                    managing ? '다음 배송' : '첫 배송일',
                    '다음 $day요일',
                    strong: true,
                  ),
                ]),
                if (managing) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => update(() => skips++),
                    child: Text('다음 배송 1회 건너뛰기 · $skips회'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('구독 해지'),
                          content: const Text('정기 배송 구독을 해지하시겠어요?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('유지하기'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text('구독 해지'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        Navigator.pop(context, false);
                      }
                    },
                    child: const Text('구독 해지'),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('언제든 건너뛰거나 해지할 수 있어요.', style: _caption),
              ],
              action: _button(
                managing ? '변경 내용 저장' : '정기 배송 시작하기',
                () => Navigator.pop(context, true),
              ),
            ),
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _subscription = result ? index : null;
      _cycle = cycle;
      _day = day;
      _quantity = quantity;
      _skips = skips;
    });
    _open(ShoppingView.orders);
  }
}

Widget _page(
  String title,
  String back,
  VoidCallback onBack,
  List<Widget> children, {
  Widget? action,
}) => ColoredBox(
  color: _mint,
  child: SafeArea(
    bottom: false,
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
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: _green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      label: Text(back),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                key: ValueKey(title),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: children,
              ),
            ),
            if (action != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(width: double.infinity, child: action),
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);

Widget _section(String title, Widget child) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            color: _green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child,
    ],
  ),
);

Widget _panel(List<Widget> children) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  ),
);

Widget _pair(String label, String value, {bool strong = false}) => Row(
  children: [
    Expanded(
      child: Text(
        label,
        style: strong ? _bold : const TextStyle(color: _muted),
      ),
    ),
    const SizedBox(width: 8),
    Flexible(
      child: Text(
        value,
        textAlign: TextAlign.end,
        style: strong ? _bold : const TextStyle(color: _muted),
      ),
    ),
  ],
);

Widget _tag(String label, {bool ai = false}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  decoration: BoxDecoration(
    color: ai ? const Color(0xFFEEEDFC) : _chip,
    borderRadius: BorderRadius.circular(5),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (ai) ...[
        SvgPicture.asset('assets/images/shop_4.svg', width: 11, height: 11),
        const SizedBox(width: 3),
      ],
      Text(
        label,
        style: TextStyle(
          color: ai ? _ai : _muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
);

Widget _thumb(int index, double size) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    color: const [
      Color(0xFFE2F1F3),
      Color(0xFFF3EDDD),
      Color(0xFFEAF1ED),
      Color(0xFFE2F1F3),
    ][index],
    borderRadius: BorderRadius.circular(15),
  ),
  alignment: Alignment.center,
  child: SvgPicture.asset(
    'assets/images/shop_$index.svg',
    width: index == 1 ? 34 : 36,
    height: const [31.0, 24.0, 26.0, 31.0][index],
  ),
);

Widget _button(String label, VoidCallback? onPressed) => FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor: _green,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 48),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  onPressed: onPressed,
  child: Text(label, textAlign: TextAlign.center, style: _bold),
);

Widget _stepper(int quantity, ValueChanged<int> onChanged, {int minimum = 0}) =>
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: '수량 줄이기',
          onPressed: quantity > minimum ? () => onChanged(quantity - 1) : null,
          icon: const Icon(Icons.remove, size: 18),
        ),
        Text('$quantity', style: _bold),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: '수량 늘리기',
          onPressed: () => onChanged(quantity + 1),
          icon: const Icon(Icons.add, size: 18),
        ),
      ],
    );

Widget _bar(double value, Color color) => LinearProgressIndicator(
  value: value,
  minHeight: 5,
  borderRadius: BorderRadius.circular(4),
  color: color,
  backgroundColor: AppTheme.border,
);

class _Macro extends StatelessWidget {
  const _Macro(this.label, this.amount, this.progress);
  final String label;
  final String amount;
  final double progress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _caption),
      const SizedBox(height: 5),
      _bar(progress, _cyan),
      const SizedBox(height: 5),
      Text(
        amount,
        style: const TextStyle(
          color: _green,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
