import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores do Caderno de Rascunhos / Nanquim (LICÀRT)
  static const Color papel = Color(0xFFFFFFFF);
  static const Color papel2 = Color(0xFFF2F0EB); // Fundo quente artesanal
  static const Color tinta = Color(0xFF0D0D0D); // Nanquim preto profundo
  static const Color tintaHover = Color(0xFF2B2B2B);
  static const Color tintaSuave = Color(0xFF5C5A56); // Cinza nanquim suave
  static const Color linha = Color(0xFFD9D6CF); // Linha divisória fina
  static const Color respingo = Color(0xFFD42A1C); // Vermelho carimbo / respingo
  static const Color sobreRespingo = Color(0xFFFFFFFF);

  // Aliases para compatibilidade
  static const Color primaryColor = tinta;
  static const Color primaryLight = tintaHover;
  static const Color goldAccent = respingo;
  static const Color secondaryColor = tintaSuave;
  static const Color backgroundColor = papel;
  static const Color surfaceColor = papel;
  static const Color textPrimary = tinta;
  static const Color textSecondary = tintaSuave;
  static const Color successColor = Color(0xFF2E7D32);

  // Tipografia
  static TextStyle displayFont({
    double fontSize = 40,
    FontWeight fontWeight = FontWeight.w400,
    Color color = tinta,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.permanentMarker(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle sansFont({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = tinta,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.archivo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.archivoTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: papel,
      primaryColor: tinta,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tinta,
        primary: tinta,
        secondary: respingo,
        surface: papel,
        onSurface: tinta,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.permanentMarker(
          color: tinta,
          fontWeight: FontWeight.w400,
          fontSize: 48,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.archivo(
          color: tinta,
          fontWeight: FontWeight.w800,
          fontSize: 28,
        ),
        titleLarge: GoogleFonts.archivo(
          color: tinta,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        bodyLarge: GoogleFonts.archivo(
          color: tinta,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.archivo(
          color: tintaSuave,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.archivo(
          color: tinta,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: papel,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: tinta),
        titleTextStyle: GoogleFonts.permanentMarker(
          color: tinta,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        shape: const Border(
          bottom: BorderSide(color: linha, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tinta,
          foregroundColor: papel,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: GoogleFonts.archivo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tinta,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: tinta, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: GoogleFonts.archivo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: papel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: linha, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: papel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: tinta, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: linha, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: tinta, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: respingo, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: linha,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
