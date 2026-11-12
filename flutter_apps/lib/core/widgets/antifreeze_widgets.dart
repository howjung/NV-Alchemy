import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AntifreezeLogo extends StatelessWidget {
  const AntifreezeLogo({this.width = 50, super.key});

  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/antifreeze_character.png',
    width: width,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.suffix,
    this.onChanged,
    super.key,
  });

  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        height: 52,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint, suffixText: suffix),
        ),
      ),
    ],
  );
}

class ScreenTopBar extends StatelessWidget {
  const ScreenTopBar({
    required this.title,
    this.step,
    this.onBack,
    this.backLabel = '뒤로',
    super.key,
  });

  final String title;
  final String? step;
  final VoidCallback? onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 115,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 62, 10, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.chevron_left, size: 22),
                label: Text(backLabel),
              ),
            ),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (step != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  step!,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
