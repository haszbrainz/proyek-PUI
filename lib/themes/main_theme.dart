import 'package:flutter/material.dart';
import 'custom_colors.dart';

class AppTheme {
  static ThemeData get themeData => ThemeData(
    primaryColor: CustomColors.primary600,
    brightness: Brightness.light,
    scaffoldBackgroundColor: CustomColors.secondary50,
    textTheme: _textTheme,
  );

  static TextTheme get _textTheme => TextTheme(
    displayLarge: defaultTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w700),
    displayMedium: defaultTextStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
    displaySmall: defaultTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
    headlineMedium: defaultTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
    headlineSmall: defaultTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
    titleLarge: defaultTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: defaultTextStyle.copyWith(fontSize: 16),
    bodyMedium: defaultTextStyle,
    bodySmall: defaultTextStyle.copyWith(fontSize: 12),
    labelLarge: defaultTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
  );

  static TextStyle get defaultTextStyle => const TextStyle(
    fontFamily: 'VisbyRoundCF',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: CustomColors.tertiary700,
  );
}