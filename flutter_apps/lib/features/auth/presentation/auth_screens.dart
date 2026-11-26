import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/backend_api.dart';
import '../../../core/state/user_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/antifreeze_widgets.dart';
import '../../../core/widgets/app_overlays.dart';
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
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        currentUserId != null ? AppRoutes.home : AppRoutes.login,
      );
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

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_submitting) return;
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email) || _password.text.isEmpty) {
      showAppToast(context, '이메일과 비밀번호를 확인해 주세요');
      return;
    }
    setState(() => _submitting = true);
    try {
      final user = await BackendApi.instance.findUserByEmail(email);
      if (!mounted) return;
      if (user == null) {
        showAppToast(context, '가입된 계정이 없어요. 회원가입을 해 주세요');
        return;
      }
      syncUserFromServer(user);
      await saveUserData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on ApiException catch (error) {
      if (mounted) showAppToast(context, error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
                    LabeledField(
                      label: '이메일',
                      hint: 'example@antifreeze.com',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      label: '비밀번호',
                      hint: '비밀번호 입력',
                      controller: _password,
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
                      label: _submitting ? '로그인 중...' : '로그인',
                      onPressed: _submitting ? () {} : _login,
                    ),
                    // 개발 중에만 보이는 지름길(디버그 빌드 전용, 릴리스에서는 사라진다).
                    if (kDebugMode)
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.home,
                          ),
                          child: const Text('개발자 · 바로 홈으로'),
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
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _next() {
    final pw = _password.text;
    final message = !_emailPattern.hasMatch(_email.text.trim())
        ? '이메일 주소를 확인해 주세요'
        : pw.length < 8 ||
              !pw.contains(RegExp(r'[A-Za-z]')) ||
              !pw.contains(RegExp(r'\d'))
        ? '비밀번호는 영문, 숫자 포함 8자 이상이에요'
        : pw != _confirm.text
        ? '비밀번호가 서로 달라요'
        : !(_terms[0] && _terms[1])
        ? '필수 약관에 동의해 주세요'
        : null;
    if (message != null) {
      showAppToast(context, message);
      return;
    }
    pendingSignUpEmail = _email.text.trim();
    Navigator.pushNamed(context, AppRoutes.onboardingProfile);
  }

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
                LabeledField(
                  label: '이메일',
                  hint: 'example@antifreeze.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: '비밀번호',
                  hint: '영문, 숫자 포함 8자 이상',
                  controller: _password,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: '비밀번호 확인',
                  hint: '한 번 더 입력',
                  controller: _confirm,
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
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
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
                PrimaryButton(label: '다음', onPressed: _next),
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
      _submitted = _emailPattern.hasMatch(email);
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
                        showAppToast(context, '비밀번호 재설정 메일을 보냈어요');
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
