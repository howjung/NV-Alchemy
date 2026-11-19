import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_overlays.dart';

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

const _sellers = <({String name, String shipping, int extra})>[
  (name: '식단공방', shipping: '무료배송', extra: 0),
  (name: '오늘한끼', shipping: '무료배송', extra: 1000),
  (name: '푸드랩 마켓', shipping: '배송비 2,500원', extra: 2800),
];

const _suggestions = ['닭가슴살 샐러드', '곤약밥 밀키트', '그릭요거트', '현미 도시락'];

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
  final _orders =
      <({Map<int, int> items, int total, int points, String payment})>[];
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
  String _payment = '등록한 카드 ···· 1234';

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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

  Future<void> _confirmRemove(int index) async {
    final confirmed = await showConfirmPopup(
      context,
      title: '상품을 뺄까요?',
      message: _products[index].name,
      confirmLabel: '빼기',
    );
    if (!confirmed || !mounted) return;
    _change(index, 0);
    _toast('장바구니에서 뺐어요');
  }

  // 장바구니 바(담은 상품이 있을 때)를 가리지 않도록 그 위에 띄운다.
  void _toast(String message, {double width = 160}) {
    // 앱 화면 폭(창 폭이 아니라 이 탭이 실제로 차지하는 폭) 기준으로 가운데에 둔다.
    final side = ((context.size?.width ?? 402) - width) / 2;
    final bottom = _view == ShoppingView.catalog && _count > 0 ? 80.0 : 24.0;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(side, 0, side, bottom),
          duration: const Duration(seconds: 2),
          backgroundColor: _green,
          shape: const StadiumBorder(),
        ),
      );
  }

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
            _query
                .trim()
                .split(RegExp(r'\s+'))
                .every(
                  '${_products[index].name} ${_products[index].category}'
                      .contains,
                ))
          index,
    ];
    if (_sort == '낮은 가격순') {
      visible.sort((a, b) => _products[a].price.compareTo(_products[b].price));
    } else if (_sort == 'AI 적합도순') {
      visible.sort((a, b) => _products[b].score.compareTo(_products[a].score));
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
                        AppMenu<String>(
                          tooltip: '장바구니',
                          width: _cart.isEmpty ? 240 : 310,
                          offset: Offset(_cart.isEmpty ? -200 : -270, 0),
                          selected: 'view',
                          items: [
                            if (_cart.isEmpty)
                              const AppMenuItem('empty', '장바구니가 비어 있어요')
                            else ...[
                              for (final item in _cart.entries)
                                AppMenuItem('item', _products[item.key].name),
                              AppMenuItem('total', '합계 ${_won(_subtotal)}'),
                              const AppMenuItem('view', '장바구니 보기 ›'),
                            ],
                          ],
                          onSelected: (value) {
                            if (value != 'empty') _open(ShoppingView.cart);
                          },
                          child: IgnorePointer(
                            child: IconButton.outlined(
                              onPressed: () {},
                              icon: Badge(
                                isLabelVisible: _count > 0,
                                label: Text('$_count'),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: _green,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, box) => RawAutocomplete<String>(
                        optionsBuilder: (value) =>
                            value.text.isEmpty ? _suggestions : const [],
                        onSelected: (value) => setState(() => _query = value),
                        fieldViewBuilder:
                            (context, controller, focusNode, onSubmitted) =>
                                TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onChanged: (value) =>
                                      setState(() => _query = value),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: _muted,
                                    ),
                                    hintText: '밀키트, 도시락, 샐러드 검색',
                                    fillColor: _chip,
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                        optionsViewBuilder: (context, onSelected, options) =>
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Material(
                                  color: Colors.white,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: AppTheme.border,
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: box.maxWidth,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            16,
                                            12,
                                            16,
                                            4,
                                          ),
                                          child: Text(
                                            '추천 검색어',
                                            style: _caption,
                                          ),
                                        ),
                                        for (final option in options)
                                          InkWell(
                                            onTap: () => onSelected(option),
                                            child: Container(
                                              height: 44,
                                              alignment: Alignment.centerLeft,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: Text(
                                                option,
                                                style: const TextStyle(
                                                  color: _green,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 6),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
                  AppMenu<String>(
                    tooltip: '카테고리 선택',
                    width: 362,
                    selected: _category,
                    items: [
                      for (final value in [
                        '전체 상품',
                        ..._products.map((product) => product.category),
                      ])
                        AppMenuItem(value, value),
                    ],
                    onSelected: (value) => setState(() => _category = value),
                    child: _panel([_menuLabel(_category, bold: true)]),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '상품 ${visible.length}개',
                          style: const TextStyle(color: _muted),
                        ),
                      ),
                      AppMenu<String>(
                        tooltip: '정렬 선택',
                        width: 160,
                        selected: _sort,
                        items: const [
                          AppMenuItem('AI 추천순', 'AI 추천순'),
                          AppMenuItem('낮은 가격순', '낮은 가격순'),
                          AppMenuItem('AI 적합도순', 'AI 적합도순'),
                        ],
                        onSelected: (value) => setState(() => _sort = value),
                        child: _menuLabel(
                          _sort,
                          color: _sort == 'AI 추천순' ? _ai : null,
                          bold: _sort == 'AI 추천순',
                          fill: false,
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
      Semantics(
        button: true,
        hint: '상품 상세 보기',
        child: InkWell(
          onTap: () => _productSheet(index),
          child: Row(
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
                      children: [
                        _tag(product.category),
                        _tag('AI 추천', ai: true),
                      ],
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
        ),
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
            child: _button('장바구니 담기', () {
              _change(index, (_cart[index] ?? 0) + 1);
              _toast('장바구니에 담았어요');
            }),
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
                            (value) => value <= 0
                                ? _confirmRemove(item.key)
                                : _change(item.key, value),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _confirmRemove(item.key),
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
        AppMenu<String>(
          tooltip: '배송지 선택',
          width: 362,
          selected: 'saved',
          items: const [
            AppMenuItem('saved', '홍길동 · 경기도 성남시 수정구 ○○로 123'),
            AppMenuItem('new', '새 배송지 추가'),
          ],
          child: _panel([
            _pair('홍길동', '기본', strong: true),
            const SizedBox(height: 6),
            const Text(
              '경기도 성남시 수정구 ○○로 123\n101동 1001호 · 010-0000-1234',
              style: _caption,
            ),
          ]),
        ),
      ),
      AppMenu<String>(
        tooltip: '배송 요청사항 선택',
        width: 362,
        selected: _delivery,
        items: [
          for (final value in [
            '문 앞에 놓아 주세요',
            '경비실에 맡겨 주세요',
            '직접 받을게요',
            '배송 전에 연락 주세요',
          ])
            AppMenuItem(value, value),
        ],
        onSelected: (value) => setState(() => _delivery = value),
        child: _panel([_menuLabel(_delivery)]),
      ),
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
      _section(
        '결제 수단',
        AppMenu<String>(
          tooltip: '결제 수단 선택',
          width: 362,
          selected: _payment,
          items: [
            for (final value in ['등록한 카드 ···· 1234', '새 카드 등록', '계좌이체'])
              AppMenuItem(value, value),
          ],
          // 새 카드 등록은 입력 항목이 정해지기 전(PRD N9)이라 선택만 닫는다.
          onSelected: (value) {
            if (value != '새 카드 등록') setState(() => _payment = value);
          },
          child: _panel([_menuLabel(_payment)]),
        ),
      ),
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
      Material(
        type: MaterialType.transparency,
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _agreed,
          onChanged: (value) => setState(() => _agreed = value ?? false),
          title: const Text('주문 내용을 확인했고 결제에 동의해요.'),
        ),
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
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 402),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PointSheet(
        balance: _balance,
        limit: _pointLimit,
        initial: _points > 0 ? _points : (_pointLimit >= 500 ? 500 : 0),
      ),
    );
    if (mounted && value != null) setState(() => _points = value);
  }

  Future<void> _productSheet(int index) {
    final product = _products[index];
    final sellers = _sellers.take(index == 3 ? 2 : 3).toList();
    return showModalBottomSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 402),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  color: _green,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${product.category} · ${product.nutrition}',
                style: _caption,
              ),
              const SizedBox(height: 8),
              Text(
                'AI 적합도 ${product.score}%',
                style: const TextStyle(
                  color: _ai,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              for (final seller in sellers)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: _pair(
                    '${seller.name} · ${seller.shipping}',
                    _won(product.price + seller.extra),
                    strong: true,
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _chip,
                        foregroundColor: _green,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _subscriptionPage(index);
                      },
                      child: const Text('정기 배송'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _change(index, (_cart[index] ?? 0) + 1);
                        _toast('장바구니에 담았어요');
                      },
                      child: const FittedBox(
                        child: Text('장바구니 담기', style: _bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _placeOrder() => setState(() {
    _orders.insert(0, (
      items: Map.of(_cart),
      total: _subtotal - _points,
      points: _points,
      payment: _payment,
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
            Text(_orders.first.payment, style: _caption),
          ]),
        const SizedBox(height: 18),
        _button('주문 내역 보기', () => _open(ShoppingView.orders)),
        TextButton(
          onPressed: () => _open(ShoppingView.catalog),
          child: const Text('쇼핑 계속하기'),
        ),
      ]);

  Widget _history() => _page(
    '주문 · 구독 내역',
    '쇼핑',
    () => _open(ShoppingView.catalog),
    [
      _section(
        '정기 구독',
        _panel([
          if (_subscription case final index?)
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_products[index].name),
                subtitle: Text('$_cycle $_day요일 · $_quantity개 · 건너뛰기 $_skips회'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _subscriptionPage(index, managing: true),
              ),
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
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_orderName(order.items)),
                subtitle: const Text('결제 완료'),
                trailing: Text(_won(order.total), style: _bold),
                onTap: () => _detail(order),
              ),
            ),
        ]),
      ),
    ],
  );

  // 예시 주문일(앱의 기준 날짜)과 도착 예정일. 서버 연동 전 고정값.
  void _detail(
    ({Map<int, int> items, int total, int points, String payment}) order,
  ) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: _mint,
        body: _page('주문 상세', '내역', () => Navigator.pop(context), [
          _panel([
            Text(
              _orderName(order.items),
              style: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '2026.10.21 주문 · ${order.items.values.fold(0, (a, b) => a + b)}개',
              style: _caption,
            ),
          ]),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '배송 상태',
                    style: TextStyle(
                      color: _green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  '배송 준비 중',
                  style: TextStyle(
                    color: Color(0xFF2B8A9C),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _panel([
            _steps(0),
            const Divider(height: 28, color: AppTheme.border),
            _timeline('2026.10.21', '주문 완료'),
            const SizedBox(height: 10),
            _timeline('10.22 (목)', '도착 예정'),
          ]),
          const SizedBox(height: 12),
          _section(
            '배송지',
            _panel([const Text('경기도 성남시 수정구 ○○로 123\n101동 1001호 (홍길동)')]),
          ),
          _section(
            '결제 정보',
            _panel([
              _pair('상품 금액', _won(order.total + order.points)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text('포인트 사용', style: TextStyle(color: _muted)),
                  ),
                  Text(
                    '-${_won(order.points)}',
                    style: const TextStyle(
                      color: Color(0xFF2B8A9C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppTheme.border),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(child: Text('결제 금액', style: _bold)),
                  Text(
                    _won(order.total),
                    style: const TextStyle(
                      color: _green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(order.payment, style: _caption),
              const SizedBox(height: 4),
              Text('사용한 포인트 ${order.points}P', style: _caption),
            ]),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 56,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB54E45),
                side: const BorderSide(color: Color(0xFFE3B7B2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _cancelOrder(context, order),
              child: const Text('주문 취소 요청', style: _bold),
            ),
          ),
          const SizedBox(height: 14),
          const Text('신선식품은 상품에 문제가 있을 때만 환불할 수 있어요.', style: _caption),
          const SizedBox(height: 6),
          const Text('주문을 취소하면 사용한 포인트는 되돌려 드려요.', style: _caption),
        ]),
      ),
    ),
  );

  Future<void> _cancelOrder(
    BuildContext detailContext,
    ({Map<int, int> items, int total, int points, String payment}) order,
  ) async {
    final confirmed = await showConfirmPopup(
      detailContext,
      title: '주문을 취소할까요?',
      message: '사용한 포인트는 되돌려 드려요.',
      confirmLabel: '주문 취소',
    );
    if (!confirmed || !mounted || !detailContext.mounted) return;
    setState(() {
      _orders.remove(order);
      _balance += order.points;
    });
    Navigator.pop(detailContext);
    _toast('주문을 취소했어요');
  }

  Future<void> _subscriptionPage(int index, {bool managing = false}) async {
    final product = _products[index];
    var cycle = managing ? _cycle : '매주';
    var day = managing ? _day : '월';
    var quantity = managing ? _quantity : 1;
    var skips = managing ? _skips : 0;
    var firstDate = '10월 26일 (월)';
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
                if (managing)
                  _panel([_pair('다음 배송', '다음 $day요일', strong: true)])
                else
                  AppMenu<String>(
                    tooltip: '첫 배송일 선택',
                    width: 362,
                    selected: firstDate,
                    items: [
                      for (final value in [
                        '10월 26일 (월)',
                        '10월 28일 (수)',
                        '11월 2일 (월)',
                      ])
                        AppMenuItem(value, value),
                    ],
                    onSelected: (value) => update(() => firstDate = value),
                    child: _panel([
                      Row(
                        children: [
                          const Text('첫 배송일', style: TextStyle(color: _muted)),
                          const Spacer(),
                          Text(firstDate, style: _bold),
                          const Icon(Icons.keyboard_arrow_down, color: _muted),
                        ],
                      ),
                    ]),
                  ),
                if (managing) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      update(() => skips++);
                      _toast('다음 배송 1회를 건너뛰어요', width: 200);
                    },
                    child: Text('다음 배송 1회 건너뛰기 · $skips회'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showConfirmPopup(
                        context,
                        title: '구독을 해지할까요?',
                        message: '다음 배송부터 받을 수 없어요.\n이미 결제한 배송은 그대로 도착해요.',
                        confirmLabel: '해지하기',
                        cancelLabel: '유지하기',
                      );
                      if (confirmed && context.mounted) {
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
    Text(
      value,
      textAlign: TextAlign.end,
      style: strong ? _bold : const TextStyle(color: _muted),
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

Widget _menuLabel(
  String text, {
  Color? color,
  bool bold = false,
  bool fill = true,
}) {
  final label = Text(
    text,
    style: TextStyle(color: color, fontWeight: bold ? FontWeight.w700 : null),
  );
  return Padding(
    padding: EdgeInsets.symmetric(vertical: fill ? 0 : 10),
    child: Row(
      mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (fill) Expanded(child: label) else label,
        const Icon(Icons.keyboard_arrow_down, color: _muted),
      ],
    ),
  );
}

Widget _steps(int current) => LayoutBuilder(
  builder: (context, box) {
    final w = box.maxWidth;
    const labels = ['주문 완료', '배송 시작', '배송 완료'];
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          for (var i = 0; i < 2; i++)
            Positioned(
              left: w / 6 + i * w / 3,
              top: 5,
              width: w / 3,
              height: 4,
              child: ColoredBox(color: i < current ? _cyan : AppTheme.border),
            ),
          for (var i = 0; i < 3; i++)
            Positioned(
              left: i * w / 3,
              top: 0,
              width: w / 3,
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= current ? _cyan : Colors.white,
                      border: Border.all(color: _cyan, width: 2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: i <= current ? _green : _muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  },
);

Widget _timeline(String date, String label) => Row(
  children: [
    SizedBox(width: 84, child: Text(date, style: _caption)),
    Text(label, style: const TextStyle(color: _green)),
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

class _PointSheet extends StatefulWidget {
  const _PointSheet({
    required this.balance,
    required this.limit,
    required this.initial,
  });
  final int balance;
  final int limit;
  final int initial;

  @override
  State<_PointSheet> createState() => _PointSheetState();
}

class _PointSheetState extends State<_PointSheet> {
  late int _value = widget.initial;

  // 사용 가능한 값: 0(사용 안 함) 또는 500P 이상 100P 단위, 최대 limit.
  int _fit(int value) {
    if (widget.limit < 500 || value <= 0) return 0;
    if (value < 500) return 500;
    return value > widget.limit ? widget.limit : value;
  }

  void _set(int value) => setState(() => _value = _fit(value));

  String _p(int value) => _won(value).replaceFirst('원', 'P');

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  '포인트 사용',
                  style: TextStyle(
                    color: _green,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: '닫기',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: _green),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('보유 포인트', style: _caption)),
              Text(_p(widget.balance), style: _bold),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            decoration: BoxDecoration(
              color: _chip.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _round(
                  Icons.remove,
                  '포인트 줄이기',
                  _value > 0
                      ? () => _set(_value <= 500 ? 0 : _value - 100)
                      : null,
                ),
                Expanded(
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: '$_value',
                        style: const TextStyle(
                          color: _green,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                        children: const [
                          TextSpan(
                            text: '  P',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _round(
                  Icons.add,
                  '포인트 늘리기',
                  _value < widget.limit
                      ? () => _set(_value < 500 ? 500 : _value + 100)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _quick('+500', () => _set(_value + 500)),
              const SizedBox(width: 8),
              _quick('+1,000', () => _set(_value + 1000)),
              const SizedBox(width: 8),
              _quick('전액 사용', () => _set(widget.limit)),
            ],
          ),
          const Divider(height: 32, color: AppTheme.border),
          Row(
            children: [
              const Expanded(child: Text('사용 후 남는 포인트', style: _caption)),
              Text(_p(widget.balance - _value), style: _bold),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '결제 금액에서 ${_won(_value)}이 빠져요.',
            style: const TextStyle(color: Color(0xFF11836C), fontSize: 13),
          ),
          const SizedBox(height: 18),
          const Text('500P부터 100P 단위로 쓸 수 있고, 결제 금액까지 사용해요.', style: _caption),
          const SizedBox(height: 4),
          const Text('주문을 취소하면 사용한 포인트는 되돌려 드려요.', style: _caption),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: _button(
              _value == 0 ? '사용 안 함' : '${_p(_value)} 사용하기',
              () => Navigator.pop(context, _value),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _round(IconData icon, String tooltip, VoidCallback? onPressed) =>
      IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          fixedSize: const Size(44, 44),
          backgroundColor: _chip,
          foregroundColor: _green,
        ),
        icon: Icon(icon),
      );

  Widget _quick(String label, VoidCallback onPressed) => Expanded(
    child: SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: widget.limit < 500 ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _chip,
          foregroundColor: _green,
          padding: EdgeInsets.zero,
        ),
        child: Text(label, style: _bold),
      ),
    ),
  );
}
