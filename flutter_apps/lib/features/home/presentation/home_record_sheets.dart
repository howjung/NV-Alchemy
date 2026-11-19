import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/antifreeze_widgets.dart';
import '../../../core/widgets/app_screen_frame.dart';

typedef HomeMetrics = ({double height, double weight, double goal});

String formatMetric(double value) =>
    value.toStringAsFixed(value % 1 == 0 ? 0 : 1);

Future<T?> showHomeSheet<T>(BuildContext context, Widget child) =>
    showModalBottomSheet<T>(
      context: context,
      constraints: BoxConstraints(maxWidth: AppScreenFrame.figmaSize.width),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: child,
        ),
      ),
    );

class WeightRecordSheet extends StatefulWidget {
  const WeightRecordSheet({required this.weight, this.date, super.key});
  final DateTime? date;
  final double weight;

  @override
  State<WeightRecordSheet> createState() => _WeightRecordSheetState();
}

class _WeightRecordSheetState extends State<WeightRecordSheet> {
  late final _controller = TextEditingController(
    text: widget.weight.toStringAsFixed(1),
  );

  double? get _weight {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    return value != null && value >= 0.1 && value <= 500 ? value : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adjust(int amount) {
    final tenths = (((_weight ?? widget.weight) * 10).round() + amount).clamp(
      1,
      5000,
    );
    setState(() {
      _controller.text = (tenths / 10).toStringAsFixed(1);
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final weight = _weight;
    final difference = weight == null ? null : weight - 68.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetHeader('체중 기록'),
        Text(
          widget.date == null
              ? '10월 21일 수요일'
              : MaterialLocalizations.of(context).formatFullDate(widget.date!),
          style: _caption,
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _step(Icons.remove, '체중 줄이기', -1),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: TextField(
                            controller: _controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                return RegExp(r'^\d{0,3}([.,]\d?)?$')
                                        .hasMatch(newValue.text)
                                    ? newValue
                                    : oldValue;
                              }),
                            ],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onTap: () => _controller.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _controller.text.length,
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                        ),
                        const Text('kg', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  _step(Icons.add, '체중 늘리기', 1),
                ],
              ),
              const SizedBox(height: 6),
              if (widget.date == null && difference != null)
                Text(
                  '어제보다 ${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}kg',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (weight == null)
                const Text(
                  '0.1~500kg 사이의 체중을 입력해 주세요.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('아침 공복에 한 번만 재도 돼요.', style: _caption),
        const SizedBox(height: 30),
        PrimaryButton(
          label: '저장',
          onPressed: () {
            if (weight == null) return;
            Navigator.pop(context, (weight * 10).round() / 10);
          },
        ),
      ],
    );
  }

  Widget _step(IconData icon, String label, int amount) =>
      IconButton.filledTonal(
        tooltip: label,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFCDE8DF),
          foregroundColor: AppTheme.primary,
        ),
        onPressed: () => _adjust(amount),
        icon: Icon(icon),
      );
}

class HomeInfoSheet extends StatefulWidget {
  const HomeInfoSheet({required this.metrics, super.key});
  final HomeMetrics metrics;

  @override
  State<HomeInfoSheet> createState() => _HomeInfoSheetState();
}

class _HomeInfoSheetState extends State<HomeInfoSheet> {
  late HomeMetrics _draft = widget.metrics;

  Future<void> _edit(int index, String label, double value, String unit) async {
    final edited = await showDialog<double>(
      context: context,
      builder: (_) => _MetricEditor(label: label, value: value, unit: unit),
    );
    if (!mounted || edited == null) return;
    setState(() {
      _draft = switch (index) {
        0 => (height: edited, weight: _draft.weight, goal: _draft.goal),
        1 => (height: _draft.height, weight: edited, goal: _draft.goal),
        _ => (height: _draft.height, weight: _draft.weight, goal: edited),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('키', _draft.height, 'cm'),
      ('현재 체중', _draft.weight, 'kg'),
      ('목표 체중', _draft.goal, 'kg'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetHeader('내 정보'),
        const SizedBox(height: 12),
        for (var i = 0; i < fields.length; i++) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(fields[i].$1),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${formatMetric(fields[i].$2)} ${fields[i].$3}',
                  style: _value,
                ),
                const Icon(Icons.chevron_right, color: AppTheme.muted),
              ],
            ),
            onTap: () => _edit(i, fields[i].$1, fields[i].$2, fields[i].$3),
          ),
          const Divider(height: 1, color: AppTheme.border),
        ],
        const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('하루 목표 칼로리'),
          subtitle: Text('기록한 목표로 자동 계산돼요.', style: _caption),
          trailing: Text('2,442 kcal', style: _value),
        ),
        const SizedBox(height: 70),
        PrimaryButton(
          label: '저장',
          onPressed: () => Navigator.pop(context, _draft),
        ),
      ],
    );
  }
}

class _MetricEditor extends StatelessWidget {
  const _MetricEditor({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final form = GlobalKey<FormState>();
    var input = formatMetric(value);
    return AlertDialog(
      title: Text(label),
      content: Form(
        key: form,
        child: TextFormField(
          autofocus: true,
          initialValue: input,
          decoration: InputDecoration(suffixText: unit),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => input = value,
          validator: (value) {
            final number = double.tryParse((value ?? '').trim());
            return number != null &&
                    number.isFinite &&
                    number >= .1 &&
                    number <= 500
                ? null
                : '0.1~500 사이의 숫자를 입력해 주세요.';
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            if (form.currentState!.validate()) {
              final number = double.parse(input.trim());
              Navigator.pop(context, (number * 10).round() / 10);
            }
          },
          child: const Text('완료'),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.border,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      Row(
        children: [
          Expanded(child: Text(title, style: _value.copyWith(fontSize: 20))),
          IconButton(
            tooltip: '닫기',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    ],
  );
}

const _caption = TextStyle(color: AppTheme.muted, fontSize: 13);
const _value = TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold);
