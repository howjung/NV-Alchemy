import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class RecordsTab extends StatefulWidget {
  const RecordsTab({super.key});

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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  @override
  Widget build(BuildContext context) {
    final monday = _date.subtract(Duration(days: _date.weekday - 1));
    final sample = _date == DateTime(2026, 10, 21);
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
                  sample ? '940' : '0',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(child: Text('/ 2,442 kcal', style: _muted)),
                Text(
                  sample ? '1,502 남음' : '2,442 남음',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: sample ? 940 / 2442 : 0,
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
                _macro('탄수화물', sample ? '110g' : '0g', const Color(0xFFF0A33B)),
                _macro('단백질', sample ? '53g' : '0g', _accent),
                _macro('지방', sample ? '24g' : '0g', const Color(0xFFDF785F)),
              ],
            ),
            if (sample) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFC),
                  borderRadius: BorderRadius.circular(15),
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
            ],
            const SizedBox(height: 12),
            _meal(
              '아침',
              sample ? '그릭 요거트 & 사과' : null,
              '320',
              '탄 40g · 단 18g · 지 6g',
            ),
            _meal(
              '점심',
              sample ? '현미곤약밥 & 소불고기' : null,
              '620',
              '탄 70g · 단 35g · 지 18g',
            ),
            _meal('저녁', null, '', ''),
            _meal('간식', null, '', ''),
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
                  Row(
                    children: [
                      const Expanded(child: Text('오늘 체중')),
                      Text(sample ? '68.2 kg' : '기록 없음', style: _bold),
                      const Icon(Icons.chevron_right, color: AppTheme.muted),
                    ],
                  ),
                  const Divider(height: 24, color: _line),
                  Row(
                    children: [
                      const Expanded(child: Text('BMI')),
                      Text(sample ? '23.1 · 정상' : '—', style: _muted),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('저장하면 홈 그래프와 프로필 통계에 바로 반영돼요.', style: _muted),
          ],
        ),
      ),
    );
  }

  Widget _day(DateTime day) {
    final selected = day == _date;
    final recorded =
        day.year == 2026 && day.month == 10 && day.day >= 19 && day.day <= 21;
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

  Widget _meal(String label, String? food, String kcal, String macros) {
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
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFEAF1ED),
                child: const Icon(Icons.add, color: AppTheme.primary),
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
                      const Icon(Icons.chevron_right, color: Color(0xFF9AAAA4)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: _line),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
