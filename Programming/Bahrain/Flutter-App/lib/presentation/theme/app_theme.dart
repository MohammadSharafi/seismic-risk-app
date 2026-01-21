import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB), // Blue-600
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB), // gray-50
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE5E7EB), // gray-200
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF111827)), // gray-900
        titleTextStyle: TextStyle(
          color: Color(0xFF111827),
          fontSize: 20, // text-xl = 20px (for "Virtual Hospital" header)
          fontWeight: FontWeight.w600, // font-semibold
          height: 1.5, // line-height: 1.5
          letterSpacing: 0, // no letter spacing
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF111827), // gray-900
          fontSize: 24.0, // text-2xl
          height: 1.5, // line-height: 1.5
        ),
        displayMedium: TextStyle(
          color: Color(0xFF111827),
          fontSize: 20.0, // text-xl
          height: 1.5,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF111827),
          fontSize: 18.0, // text-lg
          height: 1.5,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF111827),
          fontSize: 18.0, // text-lg
          height: 1.5,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF111827),
          fontSize: 16.0, // text-base
          height: 1.5,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF111827),
          fontSize: 16.0, // text-base
          height: 1.5,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF111827),
          fontSize: 16.0, // text-base
          height: 1.5,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF111827),
          fontSize: 14.0, // text-sm
          height: 1.5,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF111827),
          fontSize: 12.0, // text-xs
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF374151), // gray-700
          fontSize: 16.0, // text-base
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF374151),
          fontSize: 14.0, // text-sm
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF6B7280), // gray-500
          fontSize: 12.0, // text-xs
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: Color(0xFF111827),
          fontSize: 16.0, // text-base
          height: 1.5,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14.0, // text-sm
          height: 1.5,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12.0, // text-xs
          height: 1.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6), // gray-100
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)), // gray-300
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB), // blue-600
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // px-4 py-2 (reduced)
          minimumSize: const Size(0, 36), // h-9 = 36px (reduced from default)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14.0, // text-sm = 14px
            fontWeight: FontWeight.w500, // font-medium
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // px-4 py-2
          minimumSize: const Size(0, 36), // h-9 = 36px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: Color(0xFFD1D5DB)), // gray-300
          textStyle: const TextStyle(
            fontSize: 14.0, // text-sm = 14px
            fontWeight: FontWeight.w500, // font-medium
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // px-3 py-1.5
          minimumSize: const Size(0, 32), // h-8 = 32px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14.0, // text-sm = 14px
            fontWeight: FontWeight.w500, // font-medium
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE5E7EB)), // gray-200
        ),
      ),
    );
  }

  // Color constants matching React app
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  static const Color purple50 = Color(0xFFF5F3FF);
  static const Color purple100 = Color(0xFFE9D5FF);
  static const Color purple200 = Color(0xFFD8B4FE);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple700 = Color(0xFF7E22CE);
  static const Color purple800 = Color(0xFF6B21A8);
  static const Color purple900 = Color(0xFF581C87);

  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);

  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);

  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color orange800 = Color(0xFF9A3412);
}
