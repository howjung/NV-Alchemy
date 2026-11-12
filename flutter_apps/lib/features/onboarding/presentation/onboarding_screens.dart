import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/antifreeze_widgets.dart';
import '../../../core/widgets/app_screen_frame.dart';

class ProfileOnboardingScreen extends StatefulWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  State<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  int _gender = 0;
  DateTime? _birthday;

  Future<void> _pickBirthday() async {
    var selected = _birthday ?? DateTime(2001, 1, 1);
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      constraints: BoxConstraints(maxWidth: AppScreenFrame.figmaSize.width),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const Text(
                  '생년월일',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('완료'),
                ),
              ],
            ),
            Flexible(
              child: SizedBox(
                height: 180,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  dateOrder: DatePickerDateOrder.ymd,
                  initialDateTime: selected,
                  minimumDate: DateTime(1925, 10, 14),
                  maximumDate: DateTime(2016, 10, 13),
                  onDateTimeChanged: (date) => selected = date,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '1925년 10월 14일 ~ 2016년 10월 13일 중에서 고를 수 있어요.',
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) setState(() => _birthday = result);
  }

  @override
  Widget build(BuildContext context) => AppScreenFrame(
    figmaName: 'ONB-01 프로필 정보',
    child: Column(
      children: [
        ScreenTopBar(
          title: '',
          step: '1 / 3',
          backLabel: '가입',
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '프로필 정보',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '앱에서 사용할 정보를 알려주세요.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 14),
                ),
                const SizedBox(height: 26),
                const LabeledField(label: '닉네임', hint: '사용할 닉네임'),
                const SizedBox(height: 18),
                const Text(
                  '생년월일',
                  style: TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickBirthday,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.expand_more),
                    ),
                    child: Text(switch (_birthday) {
                      final date? =>
                        '${date.year}년 ${date.month}월 ${date.day}일',
                      null => '선택',
                    }),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '성별',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceButton(
                        label: '남성',
                        selected: _gender == 0,
                        onTap: () => setState(() => _gender = 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ChoiceButton(
                        label: '여성',
                        selected: _gender == 1,
                        onTap: () => setState(() => _gender = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  '닉네임은 크루 피드와 댓글에 보여요. 생년월일과 성별은 권장 칼로리 계산에만 쓰이고 다른 사람에게 보이지 않아요.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: '다음',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.onboardingBodyGoal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      constraints: BoxConstraints(minHeight: subtitle == null ? 48 : 72),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE4F2F4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? const Color(0xFF4FB6C9) : AppTheme.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, fontSize: 11),
            ),
        ],
      ),
    ),
  );
}

class BodyGoalOnboardingScreen extends StatefulWidget {
  const BodyGoalOnboardingScreen({super.key});

  @override
  State<BodyGoalOnboardingScreen> createState() =>
      _BodyGoalOnboardingScreenState();
}

class _BodyGoalOnboardingScreenState extends State<BodyGoalOnboardingScreen> {
  int _activity = 1;
  final _height = TextEditingController(text: '175');
  final _current = TextEditingController(text: '74');
  final _goal = TextEditingController(text: '68');

  @override
  void dispose() {
    _height.dispose();
    _current.dispose();
    _goal.dispose();
    super.dispose();
  }

  String get _goalChange {
    final current = double.tryParse(_current.text);
    final goal = double.tryParse(_goal.text);
    if (current == null ||
        goal == null ||
        !current.isFinite ||
        !goal.isFinite) {
      return '—';
    }
    final difference = goal - current;
    if (difference == 0) return '체중 유지';
    final amount = difference.abs().toStringAsFixed(
      difference % 1 == 0 ? 0 : 1,
    );
    return difference < 0 ? '-${amount}kg 감량' : '+${amount}kg 증량';
  }

  @override
  Widget build(BuildContext context) => AppScreenFrame(
    figmaName: 'ONB-02 신체 정보와 목표',
    child: Column(
      children: [
        ScreenTopBar(
          title: '',
          step: '2 / 3',
          backLabel: '이전',
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '신체 정보와 목표',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    _AiBadge(),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '입력한 정보로 권장 칼로리와 맞춤 식단을 계산해요.',
                        style: TextStyle(color: AppTheme.muted, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                LabeledField(
                  label: '키',
                  hint: '',
                  controller: _height,
                  suffix: 'cm',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: '현재 체중',
                  hint: '',
                  controller: _current,
                  suffix: 'kg',
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: '목표 체중',
                  hint: '',
                  controller: _goal,
                  suffix: 'kg',
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text(
                      '목표 변화',
                      style: TextStyle(color: AppTheme.muted, fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      label: Text(
                        _goalChange,
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: const Color(0xFFE4F2F4),
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '활동량',
                  style: TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i != 0) const SizedBox(width: 8),
                      Expanded(
                        child: _ChoiceButton(
                          label: ['비활동적', '보통 활동', '활동적'][i],
                          subtitle: ['운동 거의 안 함', '주 1~3회 운동', '주 4~5회 운동'][i],
                          selected: _activity == i,
                          onTap: () => setState(() => _activity = i),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: '다음',
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (_) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFEEEDFC),
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Text(
      '✦ AI',
      style: TextStyle(
        color: Color(0xFF5146D9),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
