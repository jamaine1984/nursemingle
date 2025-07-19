import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - LIGHT BLUE THEME (Modern & Fresh)
  static const Color primary = Color(0xFF42A5F5); // Light Blue
  static const Color primaryLight = Color(0xFF90CAF9); // Light variant
  static const Color primaryVariant = Color(0xFF1E88E5); // Medium Blue
  static const Color secondary = Color(0xFF81D4FA); // Very Light Blue
  static const Color secondaryVariant = Color(0xFF29B6F6); // Light Cyan Blue
  
  // Background colors - Light Blue Tinted
  static const Color background = Color(0xFFF8FBFF); // Very light blue tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F9FF); // Light blue surface
  static const Color card = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color text = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status colors - Blue tinted
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFED8936);
  static const Color info = Color(0xFF42A5F5); // Light blue info
  
  // Interactive colors - Light Blue Theme
  static const Color accent = Color(0xFF81D4FA); // Very Light Blue
  static const Color highlight = Color(0xFFE3F2FD); // Light blue highlight
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color hover = Color(0xFFE1F5FE); // Light blue hover
  
  // Additional colors for compatibility
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color stethoscopeGray = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE3F2FD); // Light blue divider
  static const Color border = Color(0xFFE3F2FD); // Light blue border
  static const Color shadow = Color(0xFF000000);
  
  // Card and component colors
  static const Color cardShadow = Color(0x1042A5F5); // Light blue shadow
  static const Color inputBackground = Color(0xFFF8FBFF); // Light blue input bg
  static const Color buttonShadow = Color(0x3042A5F5); // Blue button shadow
  
  // Gradient colors - Light Blue theme
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)], // Light to medium blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF81D4FA), Color(0xFF29B6F6)], // Very light to light blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FBFF), Color(0xFFE3F2FD)], // Light blue background
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Modern UI colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color navigationBackground = Color(0xFFFFFFFF);
  static const Color tabIndicator = Color(0xFF42A5F5);
  static const Color iconSelected = Color(0xFF42A5F5);
  static const Color iconUnselected = Color(0xFF9CA3AF);
} 
