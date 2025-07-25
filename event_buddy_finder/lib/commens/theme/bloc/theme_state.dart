// lib/core/theme/bloc/theme_state.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';

class ThemeState {
  final ThemeData themeData;
  final bool isDarkMode;

  ThemeState({
    required this.themeData,
    required this.isDarkMode,
  });

  factory ThemeState.light() => ThemeState(
        themeData: AppTheme.lightTheme,
        isDarkMode: false,
      );

  factory ThemeState.dark() => ThemeState(
        themeData: AppTheme.darkTheme,
        isDarkMode: true,
      );
}
