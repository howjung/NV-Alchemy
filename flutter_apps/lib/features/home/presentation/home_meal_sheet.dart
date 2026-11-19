import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

const homeMealTypes = ['아침', '점심', '저녁', '간식'];
const _labels = ['음식명', '칼로리', '탄수화물', '단백질', '지방'];
const _units = ['', 'kcal', 'g', 'g', 'g'];

typedef HomeMeal = ({String type, List<String> values});

class HomeMealSheet extends StatefulWidget {
  const HomeMealSheet({
    required this.initialType,
    required this.meals,
    this.date,
    super.key,
  });

  final DateTime? date;
  final String initialType;
  final Map<String, HomeMeal> meals;

  @override
  State<HomeMealSheet> createState() => _HomeMealSheetState();
}

class _HomeMealSheetState extends State<HomeMealSheet> {
  late String _type = widget.initialType;
  late final _fields = List.generate(_labels.length, (index) {
    return TextEditingController(text: widget.meals[_type]?.values[index]);
  });

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  void _selectType(String type) {
    if (type == _type) return;
    setState(() {
      final values = widget.meals[type]?.values;
      for (var i = 0; i < _fields.length; i++) {
        _fields[i].text = values?[i] ?? '';
      }
      _type = type;
    });
  }

  void _save() {
    Navigator.pop<HomeMeal>(context, (
      type: _type,
      values: [
        _fields.first.text.trim(),
        for (final field in _fields.skip(1))
          (int.tryParse(field.text) ?? 0).toString(),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final today = widget.date ?? DateTime.now();
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][today.weekday - 1];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    '식단 기록',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${today.month}월 ${today.day}일 $weekday요일',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _fields.first.text.trim().isEmpty ? null : _save,
              child: const Text('저장'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFDDEAE6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              for (final type in homeMealTypes)
                Expanded(
                  child: Semantics(
                    selected: type == _type,
                    button: true,
                    child: Material(
                      color: type == _type ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _selectType(type),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(type, textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MealSheetRow(
          icon: Icons.photo_camera_outlined,
          title: '사진',
          subtitle: '찍은 음식을 사진으로 남겨 두세요',
        ),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _labels.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 14, endIndent: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Text(_labels[i]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _fields[i],
                          textAlign: TextAlign.end,
                          keyboardType: i == 0
                              ? TextInputType.text
                              : TextInputType.number,
                          inputFormatters: i == 0
                              ? null
                              : [FilteringTextInputFormatter.digitsOnly],
                          onChanged: i == 0 ? (_) => setState(() {}) : null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            hintText: i == 0 ? '예) 닭가슴살 샐러드' : '0',
                            suffixText: _units[i],
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MealSheetRow(icon: Icons.search, title: '음식 DB에서 찾기'),
      ],
    );
  }
}

class _MealSheetRow extends StatelessWidget {
  const _MealSheetRow({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F5F3),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
            ],
          ),
        ),
        if (subtitle == null)
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
      ],
    ),
  );
}
