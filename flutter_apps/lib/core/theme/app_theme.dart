import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primary = Color(0xFF12332A);
  static const accent = Color(0xFF1E8CA3);
  static const background = Color(0xFFF3F8F7);
  static const muted = Color(0xFF5B7068);
  static const border = Color(0xFFDCE9E6);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Noto Sans KR',
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      surface: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF9AAAA4), fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4FB6C9), width: 1.5),
      ),
    ),
  );
}
