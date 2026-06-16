import 'package:flutter/material.dart';
import 'dart:ui';

class GlassStyles {
  static BoxDecoration get glassPanelDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2687).withOpacity(0.07),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get glassInputDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      );

  static const double glassBlur = 20.0;
  static const double inputBlur = 10.0;

  static const radialBackgroundGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFFF0F4F8),
      Color(0xFFE2E8F0),
    ],
  );
}
