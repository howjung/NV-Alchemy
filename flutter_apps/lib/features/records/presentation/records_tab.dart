import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/state/body_metrics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/antifreeze_widgets.dart';
import '../../../core/widgets/app_screen_frame.dart';
import '../../home/presentation/home_meal_sheet.dart';
import '../../home/presentation/home_record_sheets.dart';

class RecordsTab extends StatefulWidget {
  const RecordsTab({
    required this.onOpenShop,
    required this.mealsByDate,
    required this.onMealSaved,
    required this.onMealDeleted,
    required this.weights,
    required this.onWeightSaved,
    super.key,
  });

  final VoidCallback onOpenShop;
  final Map<DateTime, Map<String, HomeMeal>> mealsByDate;
  final void Function(DateTime, HomeMeal) onMealSaved;
  final void Function(DateTime, String) onMealDeleted;
  final Map<DateTime, double> weights;
  final void Function(DateTime, double) onWeightSaved;

  @override
  State<RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  static const _accent = Color(0xFF49B3C5);
  static const _line = Color(0xFFDCE9E6);
  static const _muted = TextStyle(color: AppTheme.muted, fontSize: 13);
  static const _bold = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  DateTime _date = DateTime(2026, 10, 21);
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  Future<void> _recordWeight() async {
    final date = _date;
    final value = await showHomeSheet<double>(
      context,
      WeightRecordSheet(weight: widget.weights[date] ?? 68.2, date: date),
    );
    if (!mounted || value == null) return;
    widget.onWeightSaved(date, value);
  }

  Future<void> _recordMeal(String type) async {
    final date = _date;
    final meal = await showHomeSheet<HomeMeal>(
      context,
      HomeMealSheet(
        initialType: type,
        meals: widget.mealsByDate[date] ?? const {},
        date: date,
      ),
    );
    if (!mounted || meal == null) return;
    widget.onMealSaved(date, meal);
  }

  Future<void> _showAiRecommendation() async {
    final openShop = await showModalBottomSheet<bool>(
      context: context,
      constraints: BoxConstraints(maxWidth: AppScreenFrame.figmaSize.width),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('✦ AI 추천', style: _bold),
                        Text(
                          '${_date.month}월 ${_date.day}일 ${_weekdays[_date.weekday - 1]}요일 기준',
                          style: _muted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 64),
                ],
              ),
              const SizedBox(height: 12),
              _aiCard(const Color(0xFFEEEDFC), [
                const Text('저녁은 단백질 위주,\n600kcal 이하가 좋아요', style: _bold),
                const SizedBox(height: 6),
                const Text('오늘 남은 칼로리와 영양소를 보고 AI가 골랐어요.', style: _muted),
              ]),
              const SizedBox(height: 12),
              _aiCard(Colors.white, [
                const Text('이렇게 계산했어요', style: _bold),
                const SizedBox(height: 6),
                for (final (label, value) in const [
                  ('남은 칼로리', '1,502 kcal'),
                  ('단백질', '53g 더 필요'),
                  ('탄수화물', '110g 남음'),
                  ('지방', '24g 남음'),
                  ('선호 식단', '밀키트 위주'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(child: Text(label, style: _muted)),
                        Text(
                          value,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: label == '단백질'
                                ? const Color(0xFF5146D9)
                                : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ]),
              const SizedBox(height: 12),
              _aiCard(Colors.white, [
                const Text('이 상품이 잘 맞아요', style: _bold),
                const SizedBox(height: 8),
                _aiProduct('곤약밥 소불고기 밀키트 2인', '520kcal · 단 31g', '92%'),
                const Divider(color: _line),
                _aiProduct('수비드 닭가슴살 샐러드', '380kcal · 단 34g', '96%'),
              ]),
              const SizedBox(height: 12),
              PrimaryButton(
                label: '✦ AI 추천 상품 보기',
                onPressed: () => Navigator.pop(context, true),
              ),
              const SizedBox(height: 10),
              const Text(
                'AI 추천은 참고용이에요. 몸 상태에 따라 식단은 달라질 수 있어요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && openShop == true) widget.onOpenShop();
  }

  Widget _aiCard(Color color, List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _aiProduct(String name, String nutrition, String match) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(nutrition, style: _muted),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(
        'AI 적합도 $match',
        style: const TextStyle(
          color: Color(0xFF5146D9),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Future<void> _pickDate() async {
    var selected = _date;
    var month = DateTime(_date.year, _date.month);
    final date = await showModalBottomSheet<DateTime>(
      context: context,
      constraints: BoxConstraints(maxWidth: AppScreenFrame.figmaSize.width),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, updateSheet) {
          final firstColumn = month.weekday - 1;
          final dayCount = DateTime(month.year, month.month + 1, 0).day;
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: '이전 달',
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => updateSheet(() {
                          month = DateTime(month.year, month.month - 1);
                        }),
                      ),
                      Expanded(
                        child: Text(
                          '${month.year}년 ${month.month}월',
                          textAlign: TextAlign.center,
                          style: _bold,
                        ),
                      ),
                      IconButton(
                        tooltip: '다음 달',
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => updateSheet(() {
                          month = DateTime(month.year, month.month + 1);
                        }),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      for (final weekday in _weekdays)
                        Expanded(
                          child: Text(
                            weekday,
                            textAlign: TextAlign.center,
                            style: _muted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (var week = 0; week < 6; week++)
                    Row(
                      children: [
                        for (var column = 0; column < 7; column++)
                          Expanded(
                            child: _calendarDay(
                              month,
                              week * 7 + column - firstColumn + 1,
                              dayCount,
                              selected,
                              (day) => updateSheet(() => selected = day),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: '확인',
                    onPressed: () => Navigator.pop(context, selected),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  bool _hasRecord(DateTime day) =>
      (widget.mealsByDate[day]?.isNotEmpty ?? false) ||
      widget.weights.containsKey(day);

  Widget _calendarDay(
    DateTime month,
    int number,
    int dayCount,
    DateTime selected,
    ValueChanged<DateTime> onSelect,
  ) {
    if (number < 1 || number > dayCount) return const SizedBox(height: 42);
    final day = DateTime(month.year, month.month, number);
    final active = DateUtils.isSameDay(day, selected);
    return Semantics(
      selected: active,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => onSelect(day),
        child: SizedBox(
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: active ? Colors.white : AppTheme.primary,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (_hasRecord(day))
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monday = _date.subtract(Duration(days: _date.weekday - 1));
    final sample = _date == DateTime(2026, 10, 21);
    final weight = widget.weights[_date];
    final bmi = weight == null ? null : weight / (1.72 * 1.72);
    final meals = widget.mealsByDate[_date] ?? const <String, HomeMeal>{};
    int total(int index) => meals.values.fold(
      0,
      (sum, meal) => sum + (int.tryParse(meal.values[index]) ?? 0),
    );
    final calories = total(1);
    final remaining = (calorieGoal - calories).clamp(0, calorieGoal);
    return SafeArea(
      bottom: false,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppTheme.primary),
        child: ListView(
          key: const PageStorageKey('records'),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_date.month}월 ${_date.day}일 ${_weekdays[_date.weekday - 1]}요일',
                        style: _muted,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '기록',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '날짜 선택',
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('${_date.year}년 ${_date.month}월', style: _bold),
                ),
                for (final offset in [-7, 7])
                  IconButton(
                    tooltip: offset < 0 ? '이전 주' : '다음 주',
                    onPressed: () => setState(
                      () => _date = _date.add(Duration(days: offset)),
                    ),
                    icon: Icon(
                      offset < 0 ? Icons.chevron_left : Icons.chevron_right,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(child: _day(monday.add(Duration(days: i)))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$calories',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '/ ${MaterialLocalizations.of(context).formatDecimal(calorieGoal)} kcal',
                    style: _muted,
                  ),
                ),
                Text(
                  '${MaterialLocalizations.of(context).formatDecimal(remaining)} 남음',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (calories / calorieGoal).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: _accent,
              backgroundColor: _line,
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 24,
              runSpacing: 6,
              children: [
                _macro('탄수화물', '${total(2)}g', const Color(0xFFF0A33B)),
                _macro('단백질', '${total(3)}g', _accent),
                _macro('지방', '${total(4)}g', const Color(0xFFDF785F)),
              ],
            ),
            if (sample) ...[
              const SizedBox(height: 12),
              Material(
                color: const Color(0xFFEEEDFC),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: _showAiRecommendation,
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5146D9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '✦ AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '저녁은 단백질 위주 600kcal 이하가 좋아요',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFF5146D9),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            for (final type in homeMealTypes) _meal(type, meals[type]),
            const SizedBox(height: 30),
            const Text(
              '체중',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: _recordWeight,
                      child: Row(
                        children: [
                          const Expanded(child: Text('오늘 체중')),
                          Text(
                            weight == null
                                ? '기록 없음'
                                : '${formatMetric(weight)} kg',
                            style: _bold,
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppTheme.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24, color: _line),
                  Row(
                    children: [
                      const Expanded(child: Text('BMI')),
                      Text(bmi?.toStringAsFixed(1) ?? '—', style: _muted),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _day(DateTime day) {
    final selected = day == _date;
    final recorded = _hasRecord(day);
    return InkWell(
      onTap: () => setState(() => _date = day),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: [
          Text(
            _weekdays[day.weekday - 1],
            style: _muted.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 3),
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppTheme.primary : Colors.transparent,
            ),
            child: Text(
              '${day.day}',
              style: _bold.copyWith(
                color: selected
                    ? Colors.white
                    : recorded
                    ? AppTheme.primary
                    : const Color(0xFF9AAAA4),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Icon(
            Icons.circle,
            size: 6,
            color: recorded ? _accent : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _macro(String label, String value, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 8, color: color),
      const SizedBox(width: 5),
      Text('$label $value', style: _muted),
    ],
  );

  Future<void> _showMealDetails(HomeMeal meal) async {
    final date = _date;
    final result = await showHomeSheet<({bool deleted, HomeMeal meal})>(
      context,
      _MealDetailsSheet(meal: meal, date: date),
    );
    if (!mounted || result == null) return;
    if (result.deleted) {
      widget.onMealDeleted(date, meal.type);
    } else {
      widget.onMealSaved(date, result.meal);
    }
  }

  Widget _meal(String label, HomeMeal? meal) {
    final values = meal?.values;
    final food = values?[0];
    final kcal = values?[1];
    final macros = values == null
        ? ''
        : '탄 ${values[2]}g · 단 ${values[3]}g · 지 ${values[4]}g';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                food == null ? Icons.radio_button_unchecked : Icons.circle,
                size: 12,
                color: food == null
                    ? const Color(0xFFB4C8C1)
                    : AppTheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: _bold.copyWith(
                  color: food == null ? AppTheme.muted : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  food == null ? '기록 없음' : '$kcal kcal',
                  style: _muted,
                ),
              ),
              IconButton(
                tooltip: '$label 식단 기록',
                onPressed: () => _recordMeal(label),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFEAF1ED),
                ),
                icon: const Icon(Icons.add, color: AppTheme.primary),
              ),
            ],
          ),
          if (food != null)
            Container(
              margin: const EdgeInsets.only(left: 5, top: 3),
              padding: const EdgeInsets.only(left: 17, top: 9),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: _line, width: 2)),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _showMealDetails(meal!),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(food, style: _bold.copyWith(fontSize: 15)),
                                const SizedBox(height: 4),
                                Text('$kcal kcal · $macros', style: _muted),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF9AAAA4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: _line),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealDetailsSheet extends StatefulWidget {
  const _MealDetailsSheet({required this.meal, required this.date});
  final HomeMeal meal;
  final DateTime date;

  @override
  State<_MealDetailsSheet> createState() => _MealDetailsSheetState();
}

class _MealDetailsSheetState extends State<_MealDetailsSheet> {
  late final _fields = [
    for (final value in widget.meal.values.skip(1))
      TextEditingController(text: value),
  ];

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '${widget.meal.type} 식단 상세',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            tooltip: '닫기',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      Text(
        MaterialLocalizations.of(context).formatFullDate(widget.date),
        style: const TextStyle(color: AppTheme.muted),
      ),
      const SizedBox(height: 20),
      Text(
        widget.meal.values[0],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      for (var i = 0; i < _fields.length; i++)
        Row(
          children: [
            Expanded(
              child: Text(
                ['칼로리', '탄수화물', '단백질', '지방'][i],
                style: const TextStyle(color: AppTheme.muted),
              ),
            ),
            SizedBox(
              width: 110,
              child: TextField(
                controller: _fields[i],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '0',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              i == 0 ? 'kcal' : 'g',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      const SizedBox(height: 20),
      PrimaryButton(
        label: '저장',
        onPressed: () => Navigator.pop(context, (
          deleted: false,
          meal: (
            type: widget.meal.type,
            values: [
              widget.meal.values[0],
              for (final field in _fields)
                (int.tryParse(field.text) ?? 0).toString(),
            ],
          ),
        )),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDF5050),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () =>
              Navigator.pop(context, (deleted: true, meal: widget.meal)),
          child: const Text(
            '식단 삭제',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );
}
