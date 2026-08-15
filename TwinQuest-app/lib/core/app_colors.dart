import 'package:flutter/material.dart';

class AppColors {
  // Minimal Warm Beige & Deep Espresso Palette
  static const primary = Color(0xFF4A2E22); // Rich Deep Espresso Brown
  static const primaryDark = Color(0xFF382117); // Dark Mocha
  static const primaryLight = Color(0xFF6B4536); // Medium Warm Espresso
  static const secondary = Color(0xFF8C6B58); // Muted Warm Taupe
  static const accentPink = Color(0xFFB8A292); // Muted Sand Taupe

  // Signal State Proximity Accents (Subtle & Muted)
  static const blue = Color(0xFF5A758E); // Soft Slate Blue (Far)
  static const blueSoft = Color(0xFFE8EEF4); // Soft Blue Tint
  static const orange = Color(0xFF9E7762); // Soft Muted Bronze (Warm)
  static const orangeSoft = Color(0xFFF5EFEA); // Soft Linen Tint
  static const green = Color(0xFF507B58); // Muted Sage Forest Green (Touch)
  static const greenSoft = Color(0xFFEAF2EB); // Soft Green Tint
  static const red = Color(0xFFB84A39); // Muted Rust Red Alert
  static const amber = Color(0xFFD8C4B2); // Soft Muted Linen Sand (NOT bright orange!)
  static const peach = Color(0xFFF5E6D8); // Soft Warm Linen Peach

  // Light Theme Palette (Warm Linen Cream & Deep Brown)
  static const background = Color(0xFFFAF6F0); // Warm Linen Cream
  static const surface = Color(0xFFFFFFFF); // Clean Surface
  static const surfaceSoft = Color(0xFFF5EFE6); // Soft Linen Container
  static const border = Color(0xFFE6DCCF); // Warm Sand Border
  static const borderHighlight = Color(0xFFD6C6B4);
  static const text = Color(0xFF2A1810); // Deep Espresso Text
  static const textSoft = Color(0xFF6E5A4F); // Muted Warm Taupe
  static const muted = Color(0xFFA39288); // Soft Warm Ash

  // Dark Theme Palette (Deep Muted Charcoal Obsidian — Zero Bright Orange!)
  static const darkBackground = Color(0xFF12100F); // Deep Charcoal Obsidian
  static const darkSurface = Color(0xFF1E1A18); // Dark Charcoal Card
  static const darkSurfaceSoft = Color(0xFF2B2522);
  static const darkBorder = Color(0xFF332A25);
  static const darkBorderHighlight = Color(0xFF473B35);
  static const darkText = Color(0xFFF5EFEA); // Soft Linen Cream White
  static const darkTextSoft = Color(0xFFB5A69B);
  static const darkMuted = Color(0xFF7D7067);

  // Universal Colors
  static const dark = Color(0xFF2A1810);
  static const white = Colors.white;

  // Minimal Unified Gradients
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF4A2E22), Color(0xFF5A382A), Color(0xFF8C6B58)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF4A2E22), Color(0xFF5A382A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF3D2E27), Color(0xFF2B1F1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [Color(0xFF5A453A), Color(0xFF3D2E27)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const greenGradient = LinearGradient(
    colors: [Color(0xFF507B58), Color(0xFF3E6044)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const blueGradient = LinearGradient(
    colors: [Color(0xFF5A758E), Color(0xFF435A70)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGlassGradient = LinearGradient(
    colors: [Color(0x99FFFFFF), Color(0x33FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkCardGlassGradient = LinearGradient(
    colors: [Color(0x991E1A18), Color(0x331E1A18)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
