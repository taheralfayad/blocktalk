import 'package:flutter/material.dart';

class AppColors {
  static const LinearGradient backgroundColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 255, 255, 255), // Light Steel Blue
      Color.fromARGB(255, 255, 255, 255), // Light Blue
    ],
  );
  static const Color blockColor = Color(0xFFE1E8ED);
  static const Color navigationBarColor = Color(0xFF34495E); // Dark Gray
  static const Color primaryTextColor = Color(0xFF2C3E50);
  static const Color secondaryTextColor = Color(0xFF5A6C7D);
  static const Color buttonTextColor = Color(0xFFFFFFFF); // White
  static const Color primaryButtonColor = Color(0xFF1E3A5F); 
  static const Color secondaryButtonColor = Color(0xFF52C47A); // Dark Gray
}