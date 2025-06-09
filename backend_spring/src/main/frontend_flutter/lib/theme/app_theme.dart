// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 앱의 기본 색상 정의 (여기서는 메인 색상과 텍스트 색상)
  static const Color primaryPurple = Color(0xFFde95ba);
  static const Color textPurple = Color(0xFF7f4a88);
  static const Color lightPink = Color(0xFFffd9e8);

  // 테마 데이터 정의
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.purple,

      // 앱 전체 기본 폰트 패밀리 설정
      fontFamily: 'Jua',

      // 앱 전체의 기본 텍스트 스타일 설정
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPurple),
        bodyMedium: TextStyle(color: textPurple),
        bodySmall: TextStyle(color: textPurple),
        displayLarge: TextStyle(color: textPurple),
        displayMedium: TextStyle(color: textPurple),
        displaySmall: TextStyle(color: textPurple),
        headlineLarge: TextStyle(color: textPurple),
        headlineMedium: TextStyle(color: textPurple),
        headlineSmall: TextStyle(color: textPurple),
        titleLarge: TextStyle(color: textPurple),
        titleMedium: TextStyle(color: textPurple),
        titleSmall: TextStyle(color: textPurple),
        labelLarge: TextStyle(color: textPurple),
        labelMedium: TextStyle(color: textPurple),
        labelSmall: TextStyle(color: textPurple),
      ),

      // AppBar의 기본 스타일 설정
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPurple,
        elevation: 0, // AppBar 그림자 제거
        titleTextStyle: TextStyle(
          fontFamily: 'Jua',
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),

      // BottomNavigationBar의 기본 스타일 설정
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryPurple,
        selectedItemColor: textPurple,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontFamily: 'Jua'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Jua'),
        showUnselectedLabels: true, // 선택되지 않은 라벨도 항상 표시
      ),

      // 아이콘 기본 색상 설정
      iconTheme: const IconThemeData(
        color: textPurple,
      ),


      cardColor: lightPink,
    );
  }
}