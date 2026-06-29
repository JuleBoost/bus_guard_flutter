import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemphisTheme {
  // Classic Memphis Color Palette
  static const Color primaryPink = Color(0xFFE8879F);
  static const Color secondaryTeal = Color(0xFF4DB8A8);
  static const Color accentYellow = Color(0xFFF5D76E);
  static const Color warmBackground = Color(0xFFFAF8F5);
  static const Color crispSurface = Color(0xFFFFFEF7);
  static const Color darkText = Color(0xFF1A1A2E);

  // Borders
  static final Border memphisBorder = Border.all(color: darkText, width: 3.0);

  // Hard Offset Shadows
  static const List<BoxShadow> memphisShadow = [
    BoxShadow(
      color: darkText,
      offset: Offset(4.0, 4.0),
      blurRadius: 0.0,
      spreadRadius: 0.0,
    ),
  ];

  static const List<BoxShadow> memphisSmallShadow = [
    BoxShadow(
      color: darkText,
      offset: Offset(2.0, 2.0),
      blurRadius: 0.0,
      spreadRadius: 0.0,
    ),
  ];

  // Global Material Theme Definition
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: warmBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        primary: primaryPink,
        secondary: secondaryTeal,
        tertiary: accentYellow,
        surface: crispSurface,
        background: warmBackground,
        onPrimary: darkText,
        onSecondary: darkText,
        onTertiary: darkText,
        onSurface: darkText,
        onBackground: darkText,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: crispSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkText),
        titleTextStyle: GoogleFonts.poppins(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // Helper widget for Memphis styled containers
  static Widget buildContainer({
    required Widget child,
    Color bgColor = crispSurface,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    double borderRadius = 12.0,
    bool smallShadow = false,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: memphisBorder,
        boxShadow: smallShadow ? memphisSmallShadow : memphisShadow,
      ),
      child: child,
    );
  }

  // Helper widget for Memphis styled buttons
  static Widget buildButton({
    required Widget child,
    required VoidCallback onPressed,
    Color bgColor = primaryPink,
    bool isSmall = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: darkText,
        elevation: 0,
        padding: isSmall ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: darkText, width: 3.0),
        ),
      ),
      child: child,
    );
  }
}
