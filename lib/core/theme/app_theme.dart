import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color deepPurple = Color(0xFF6B5CE7);
  static const Color darkBg = Color(0xFF0D0D1A);
  static const Color cardDark = Color(0xFF1A1A2E);
  static const Color cardDarkLight = Color(0xFF252542);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFF8B8B9E);

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: accentCyan,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
        ),
        bodyLarge: TextStyle(
          fontSize: 22,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentCyan,
        surface: cardDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 22,
          color: textLight,
        ),
      ),
    );
  }

  // Gradient backgrounds
  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0D0D1A),
          Color(0xFF1A1A2E),
          Color(0xFF16213E),
        ],
      );

  static LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cardDark.withOpacity(0.8),
          cardDarkLight.withOpacity(0.6),
        ],
      );

  static LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4A90E2),
          Color(0xFF6B5CE7),
          Color(0xFF00D4FF),
        ],
      );

  static LinearGradient get callButtonGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF00C853),
          Color(0xFF00E676),
        ],
      );

  static LinearGradient get cancelButtonGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE53935),
          Color(0xFFFF5252),
        ],
      );
}

// Glassmorphism card decoration
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final bool hasGradientBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.hasGradientBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: hasGradientBorder
            ? null
            : Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cardDark.withOpacity(0.9),
                AppTheme.cardDarkLight.withOpacity(0.7),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Gradient border card
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final double borderWidth;
  final List<Color>? gradientColors;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.borderWidth = 2,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [
          AppTheme.primaryBlue,
          AppTheme.deepPurple,
          AppTheme.accentCyan,
        ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          color: AppTheme.cardDark,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
