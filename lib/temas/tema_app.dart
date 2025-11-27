import 'package:flutter/material.dart';

class TemaApp {
  static final ThemeData temaDatos = ThemeData(
    primaryColor: Color(0xFF2E7D32),
    primaryColorDark: Color(0xFF005005),
    primaryColorLight: Color(0xFF60AD5E),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2E7D32),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF2E7D32)),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
    
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade700,
      ),
    ),
  );
}