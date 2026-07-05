import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF0277BD);

  /// Cycling accent colours for note cards — stable per note ID.
  static const List<Color> cardAccents = [
    Color(0xFF6750A4), // violet
    Color(0xFF0277BD), // ocean blue
    Color(0xFF00897B), // teal
    Color(0xFFE65100), // deep orange
    Color(0xFFAD1457), // rose
    Color(0xFF2E7D32), // forest green
  ];

  /// Returns a consistent accent colour for a given note ID.
  static Color accentForId(String id) {
    final hash = id.codeUnits.fold<int>(0, (a, b) => a + b);
    return cardAccents[hash % cardAccents.length];
  }
}
