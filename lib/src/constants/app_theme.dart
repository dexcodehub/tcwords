import 'package:flutter/material.dart';
import 'package:tcword/src/constants/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primarySwatch: AppColors.primarySwatch,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueAccent,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.5),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      backgroundColor: Colors.blueAccent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 5,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
      bodyLarge: TextStyle(
        fontSize: 20,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 18,
        color: Colors.black87,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.orangeAccent,
    ),
  );
}