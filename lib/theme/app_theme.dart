import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // -------------------------------------------------------------
  // LUXURY PALETTE (Skinny Brown, Cashmere Taupe, Warm Ivory & Noir)
  // -------------------------------------------------------------
  // Skinny Warm Brown / Camel / Saddle
  static const Color luxuryBrown = Color(0xFF8C5E38);
  static const Color luxuryBrownLight = Color(0xFFA6774E);
  static const Color luxuryBrownDark = Color(0xFF6B4324);

  // Warm Gold / Bronze Accents
  static const Color bronzeGold = Color(0xFFC59B6D);
  static const Color champagne = Color(0xFFE8DAC8);

  // Status & Utility (Refined, Desaturated)
  static const Color successGreen = Color(0xFF2E7D52);
  static const Color subtleError = Color(0xFFB94A48);

  // Luxury Gradients
  static const LinearGradient brownGradient = LinearGradient(
    colors: [luxuryBrown, luxuryBrownDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkLuxuryGradient = LinearGradient(
    colors: [Color(0xFF262320), Color(0xFF181614)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    colors: [Color(0xFFD4A373), Color(0xFF9E6B38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // -------------------------------------------------------------
  // DARK LUXURY THEME (Espresso Noir & Smoked Cashmere)
  // -------------------------------------------------------------
  static ThemeData get darkTheme {
    const bgBase = Color(0xFF0F0E0D); // Deep warm espresso void
    const surfaceBase = Color(0xFF171614); // Smoked dark cashmere
    const textPrimary = Color(0xFFF7F5F2); // Warm pearl white
    const textSecondary = Color(0xFFA8A29E); // Warm taupe gray
    const borderHairline = Color(0xFF2A2824); // Delicate hairline

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgBase,
      primaryColor: bronzeGold,
      colorScheme: const ColorScheme.dark(
        primary: bronzeGold,
        secondary: luxuryBrownLight,
        surface: surfaceBase,
        error: subtleError,
        onPrimary: Color(0xFF0F0E0D),
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.6,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFD6D3CD),
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderHairline, width: 1),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // LIGHT LUXURY THEME (Warm Alabaster Ivory & Skinny Brown)
  // -------------------------------------------------------------
  static ThemeData get lightTheme {
    const bgBase = Color(0xFFF9F7F4); // Warm natural linen / alabaster
    const surfaceBase = Color(0xFFFFFFFF); // Pure silk ivory
    const textPrimary = Color(0xFF1C1917); // Deep warm espresso
    const textSecondary = Color(0xFF78716C); // Muted taupe slate
    const borderHairline = Color(0xFFE8E4DC); // Refined delicate border

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgBase,
      primaryColor: luxuryBrown,
      colorScheme: const ColorScheme.light(
        primary: luxuryBrown,
        secondary: bronzeGold,
        surface: surfaceBase,
        error: subtleError,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF1C1917),
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.6,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF44403C),
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderHairline, width: 1),
        ),
      ),
    );
  }
}
