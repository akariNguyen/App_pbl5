import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orchid_classifier/core/theme/theme_cubit.dart';

class OrchidColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color bg;
  final Color card;
  final Color card2;
  final Color text;
  final Color muted;
  final Color border;
  final Color success;
  final Color warning;
  final Color error;

  const OrchidColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.bg,
    required this.card,
    required this.card2,
    required this.text,
    required this.muted,
    required this.border,
    required this.success,
    required this.warning,
    required this.error,
  });
}

extension OrchidContextColors on BuildContext {
  OrchidColors get orchidColors {
    final themeName = watch<ThemeCubit>().state;

    switch (themeName) {
      case 'light':
        return const OrchidColors(
          primary: Color(0xFF2D78D2),
          secondary: Color(0xFF1976D2),
          accent: Color(0xFF03A9F4),
          bg: Color(0xFFF0F4F8),
          card: Color(0xFFFFFFFF),
          card2: Color(0xFFF8FAFC),
          text: Color(0xFF1E293B),
          muted: Color(0xFF64748B),
          border: Color(0xFFE2E8F0),
          success: Color(0xFF10B981),
          warning: Color(0xFFF59E0B),
          error: Color(0xFFEF4444),
        );

      case 'pink':
        return const OrchidColors(
          primary: Color(0xFFEC4899),
          secondary: Color(0xFFD946EF),
          accent: Color(0xFFF43F5E),
          bg: Color(0xFFFDF2F8),
          card: Color(0xFFFFFFFF),
          card2: Color(0xFFFCE7F3),
          text: Color(0xFF4C1D95),
          muted: Color(0xFF9D174D),
          border: Color(0xFFFBCFE8),
          success: Color(0xFF10B981),
          warning: Color(0xFFF59E0B),
          error: Color(0xFFEF4444),
        );

      case 'red':
        return const OrchidColors(
          primary: Color(0xFFEF4444),
          secondary: Color(0xFFF97316),
          accent: Color(0xFFDC2626),
          bg: Color(0xFFFEF2F2),
          card: Color(0xFFFFFFFF),
          card2: Color(0xFFFEE2E2),
          text: Color(0xFF7F1D1D),
          muted: Color(0xFF991B1B),
          border: Color(0xFFFECACA),
          success: Color(0xFF10B981),
          warning: Color(0xFFF59E0B),
          error: Color(0xFFB91C1C),
        );

      case 'silver':
        return const OrchidColors(
          primary: Color(0xFF64748B),
          secondary: Color(0xFF475569),
          accent: Color(0xFF94A3B8),
          bg: Color(0xFF0F172A),
          card: Color(0xFF1E293B),
          card2: Color(0xFF334155),
          text: Color(0xFFF8FAFC),
          muted: Color(0xFF94A3B8),
          border: Color(0xFF475569),
          success: Color(0xFF4ADE80),
          warning: Color(0xFFFBBF24),
          error: Color(0xFFF87171),
        );

      case 'dark':
      default:
        return const OrchidColors(
          primary: Color(0xFFC76EE6),
          secondary: Color(0xFF4A90E2),
          accent: Color(0xFFFF528A),
          bg: Color(0xFF121212),
          card: Color(0xFF1E1E1E),
          card2: Color(0xFF2C2C2C),
          text: Color(0xFFF5F5F5),
          muted: Color(0xFFA0A0A0),
          border: Color(0xFF333333),
          success: Color(0xFF4ADE80),
          warning: Color(0xFFFBBF24),
          error: Color(0xFFF87171),
        );
    }
  }
}
