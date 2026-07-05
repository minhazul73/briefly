import 'package:flutter/material.dart';

/// Shared motion constants — keep every animation within these bounds.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Curve curve = Curves.easeOutCubic;
}
