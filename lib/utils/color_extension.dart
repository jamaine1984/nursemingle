import 'package:flutter/material.dart';

extension ColorExtension on Color {
  // Updated withOpacity replacement
  Color withValues({double? alpha}) {
    if (alpha != null) {
      return Color.fromARGB(
        (alpha * 255).round(),
        (r * 255.0).round() & 0xff,
        (g * 255.0).round() & 0xff,
        (b * 255.0).round() & 0xff,
      );
    }
    return this;
  }
} 
