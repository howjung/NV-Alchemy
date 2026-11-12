import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/antifreeze_widgets.dart';
import '../../../core/widgets/app_screen_frame.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  Timer? _reveal;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _reveal = Timer(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _visible = true);
    });
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reveal?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScreenFrame(
    figmaName: 'SPLASH',
    child: ColoredBox(
      color: AppTheme.primary,
      child: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/splash_mascot.svg',
                width: 120,
                height: 138,
              ),
              const SizedBox(height: 20),
              const Text(
                'Antifreeze',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '내 몸에 맞춘 AI식단, 크루와 함께 꾸준하게',
                style: TextStyle(color: Color(0xFFE4F2F4), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScreenFrame(
    figmaName: 'AUTH-03 로그인',
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  (constraints.maxHeight * .08).clamp(12.0, 72.0),
                  16,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AntifreezeLogo(),
                    const SizedBox(height: 20),
                    const Text(
                      '다시 만나서 반가워요',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '로그인하고 오늘 식단을 이어서 기록해요.',
                      style: TextStyle(color: AppTheme.muted, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    const LabeledField(
                      label: '이메일',
                      hint: 'example@antifreeze.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    const LabeledField(
                      label: '비밀번호',
                      hint: '비밀번호 입력',
                      obscureText: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.passwordRecovery,
                        ),
                        child: const Text(
                          '비밀번호를 잊으셨나요?',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    PrimaryButton(
                      label: '로그인',
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.home,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    '아직 계정이 없나요?',
                    style: TextStyle(color: AppTheme.muted, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.signUp),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _terms = [false, false, false];

  @override
  Widget build(BuildContext context) => AppScreenFrame(
    figmaName: 'AUTH-02 회원가입',
    child: Column(
      children: [
        ScreenTopBar(
          title: '이메일로 가입',
          backLabel: '로그인',
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LabeledField(
                  label: '이메일',
                  hint: 'example@antifreeze.com',
                ),
                const SizedBox(height: 16),
                const LabeledField(
                  label: '비밀번호',
                  hint: '영문, 숫자 포함 8자 이상',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const LabeledField(
                  label: '비밀번호 확인',
                  hint: '한 번 더 입력',
                  obscureText: true,
                ),
                const SizedBox(height: 18),
                const Text(
                  '약관 동의',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _terms.every((checked) => checked),
                        onChanged: (value) => setState(
                          () => _terms.fillRange(
                            0,
                            _terms.length,
                            value ?? false,
                          ),
                        ),
                        title: const Text(
                          '전체 동의',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _TermRow(
                        label: '서비스 이용약관 동의',
                        checked: _terms[0],
                        onTap: () => setState(() => _terms[0] = !_terms[0]),
                        required: true,
                      ),
                      _TermRow(
                        label: '개인정보 수집 · 이용 동의',
                        checked: _terms[1],
                        onTap: () => setState(() => _terms[1] = !_terms[1]),
                        required: true,
                      ),
                      _TermRow(
                        label: '마케팅 정보 수신 동의',
                        checked: _terms[2],
                        onTap: () => setState(() => _terms[2] = !_terms[2]),
                        required: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: '다음',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.onboardingProfile),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _TermRow extends StatelessWidget {
  const _TermRow({
    required this.label,
    required this.checked,
    required this.required,
    required this.onTap,
  });
  final String label;
  final bool checked;
  final bool required;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 52,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            color: checked ? AppTheme.accent : AppTheme.border,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.primary, fontSize: 15),
            ),
          ),
          Text(
            required ? '필수' : '선택',
            style: TextStyle(
              color: required ? AppTheme.accent : const Color(0xFF9AAAA4),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ),
  );
}

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  String _email = '';
  bool _submitted = false;
  String? _error;

  void _submit() {
    final email = _email.trim();
    setState(() {
      _submitted = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
      _error = _submitted ? null : '이메일 주소를 확인해 주세요.';
    });
  }

  @override
  Widget build(BuildContext context) => AppScreenFrame(
    figmaName: 'AUTH-04 비밀번호 찾기',
    child: Column(
      children: [
        ScreenTopBar(
          title: '비밀번호 재설정',
          backLabel: '로그인',
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_submitted) ...[
                  const SizedBox(height: 44),
                  const Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFE4F2F4),
                      child: Icon(
                        Icons.check,
                        size: 38,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      '메일을 보냈어요',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '${_email.trim()} 으로 재설정 링크를 보냈어요. 메일함을 확인해 주세요.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.muted),
                    ),
                  ),
                  const SizedBox(height: 44),
                  PrimaryButton(
                    label: '로그인으로 돌아가기',
                    onPressed: () => Navigator.pop(context),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메일을 다시 보냈어요.')),
                        );
                      },
                      child: const Text('메일이 오지 않았나요?  다시 보내기'),
                    ),
                  ),
                ] else ...[
                  const Text(
                    '가입한 이메일을 입력하면 비밀번호를 다시 설정할 수 있는 링크를 보내드려요.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: '이메일',
                    hint: 'example@antifreeze.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _email = value,
                  ),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  const SizedBox(height: 20),
                  PrimaryButton(label: '재설정 링크 보내기', onPressed: _submit),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
