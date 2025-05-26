// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 앱의 기본 색상 정의 (여기서는 메인 색상과 텍스트 색상)
  static const Color primaryPurple = Color(0xFFde95ba); // 현재 AppBar 배경색
  static const Color textPurple = Color(0xFF7f4a88); // 요청하신 텍스트 색상
  static const Color lightPink = Color(0xFFffd9e8); // 카드 배경색

  // 테마 데이터 정의
  static ThemeData get lightTheme {
    return ThemeData(
      // 기본 PrimaryColor 설정 (Material Design의 주요 색상)
      primarySwatch: Colors.purple, // Flutter가 자동으로 색상 팔레트 생성

      // 앱 전체 기본 폰트 패밀리 설정
      fontFamily: 'Jua', // pubspec.yaml에 등록한 폰트 패밀리 이름

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
        backgroundColor: primaryPurple, // AppBar 배경색
        elevation: 0, // AppBar 그림자 제거
        titleTextStyle: TextStyle(
          fontFamily: 'Jua',
          color: Colors.white, // AppBar 제목 색상은 흰색으로 설정 (로고 부분에 '피움' 텍스트 없으므로 이 부분은 선택 사항)
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white), // AppBar 아이콘 색상 (알림, 메뉴)
        actionsIconTheme: IconThemeData(color: Colors.white), // actions 내 아이콘 색상
      ),

      // BottomNavigationBar의 기본 스타일 설정
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryPurple, // BottomBar 배경색
        selectedItemColor: textPurple, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey[600], // 선택되지 않은 아이템 색상
        selectedLabelStyle: const TextStyle(fontFamily: 'Jua'), // 선택된 라벨 폰트
        unselectedLabelStyle: const TextStyle(fontFamily: 'Jua'), // 선택되지 않은 라벨 폰트
        showUnselectedLabels: true, // 선택되지 않은 라벨도 항상 표시
      ),

      // 아이콘 기본 색상 설정 (선택 사항, 전반적인 아이콘 색상에 영향을 줄 수 있음)
      iconTheme: const IconThemeData(
        color: textPurple, // 앱 내 기본 아이콘 색상을 설정
      ),

      // 그 외 필요한 다른 테마 설정들을 추가할 수 있습니다.
      // 예: CardTheme, ButtonTheme 등
      cardColor: lightPink, // 카드 배경색을 AppTheme에 정의된 색상으로 설정 (Container 대신 Card 위젯을 사용시 유용)
    );
  }
}