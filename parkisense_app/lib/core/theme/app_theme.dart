import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';



class AppColors {

  static const primaryBlue = Color(0xFF2E75B6);

  static const primaryDarkNavy = Color(0xFF1F3864);

  static const secondaryBlue = Color(0xFF2E75B6);

  static const dangerRed = Color(0xFFC00000);

  static const successGreen = Color(0xFF375623);

  static const background = Color(0xFFF7FBFF);

  static const textDark = Color(0xFF1F3864);

  static const textLight = Color(0xFF64748B);

  static const borderGrey = Color(0xFFDDE7F2);

  

  // Dark mode colors

  static const darkBackground = Color(0xFF121212);

  static const darkSurface = Color(0xFF1E1E1E);

  static const darkCard = Color(0xFF2C2C2C);

  static const darkText = Color(0xFFE0E0E0);

  static const darkTextSecondary = Color(0xFFA0A0A0);

  static const darkBorder = Color(0xFF3C3C3C);

}



class AppTheme {

  static ThemeData get lightTheme {

    return ThemeData(

      scaffoldBackgroundColor: AppColors.background,

      primaryColor: AppColors.primaryBlue,

      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primaryBlue),

      textTheme: GoogleFonts.poppinsTextTheme(

        ThemeData.light().textTheme,

      ).copyWith(

        displayLarge: GoogleFonts.poppins(

          fontSize: 32,

          fontWeight: FontWeight.bold,

          color: AppColors.textDark,

        ),

        displayMedium: GoogleFonts.poppins(

          fontSize: 28,

          fontWeight: FontWeight.bold,

          color: AppColors.textDark,

        ),

        displaySmall: GoogleFonts.poppins(

          fontSize: 24,

          fontWeight: FontWeight.bold,

          color: AppColors.textDark,

        ),

        headlineLarge: GoogleFonts.poppins(

          fontSize: 22,

          fontWeight: FontWeight.w600,

          color: AppColors.textDark,

        ),

        headlineMedium: GoogleFonts.poppins(

          fontSize: 20,

          fontWeight: FontWeight.w600,

          color: AppColors.textDark,

        ),

        headlineSmall: GoogleFonts.poppins(

          fontSize: 18,

          fontWeight: FontWeight.w600,

          color: AppColors.textDark,

        ),

        titleLarge: GoogleFonts.poppins(

          fontSize: 18,

          fontWeight: FontWeight.w600,

          color: AppColors.textDark,

        ),

        titleMedium: GoogleFonts.poppins(

          fontSize: 16,

          fontWeight: FontWeight.w500,

          color: AppColors.textDark,

        ),

        titleSmall: GoogleFonts.poppins(

          fontSize: 14,

          fontWeight: FontWeight.w500,

          color: AppColors.textDark,

        ),

        bodyLarge: GoogleFonts.poppins(

          fontSize: 16,

          fontWeight: FontWeight.normal,

          color: AppColors.textDark,

        ),

        bodyMedium: GoogleFonts.poppins(

          fontSize: 14,

          fontWeight: FontWeight.normal,

          color: AppColors.textDark,

        ),

        bodySmall: GoogleFonts.poppins(

          fontSize: 12,

          fontWeight: FontWeight.normal,

          color: AppColors.textLight,

        ),

      ),

      inputDecorationTheme: InputDecorationTheme(

        filled: true,

        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.borderGrey),

        ),

        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.borderGrey),

        ),

        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),

        ),

      ),

      elevatedButtonTheme: ElevatedButtonThemeData(

        style: ElevatedButton.styleFrom(

          backgroundColor: AppColors.primaryBlue,

          foregroundColor: Colors.white,

          minimumSize: const Size.fromHeight(52),

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          elevation: 0,

          textStyle: GoogleFonts.poppins(

            fontSize: 16,

            fontWeight: FontWeight.w600,

          ),

        ),

      ),

      appBarTheme: AppBarTheme(

        backgroundColor: Colors.white,

        foregroundColor: AppColors.textDark,

        elevation: 0,

        centerTitle: false,

        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),

      cardTheme: CardThemeData(

        color: Colors.white,

        elevation: 2,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(16),

        ),

      ),

      iconTheme: const IconThemeData(

        color: AppColors.textDark,

      ),

    );

  }



  static ThemeData get darkTheme {

    return ThemeData(

      scaffoldBackgroundColor: AppColors.darkBackground,

      primaryColor: AppColors.primaryBlue,

      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primaryBlue),

      inputDecorationTheme: InputDecorationTheme(

        filled: true,

        fillColor: AppColors.darkCard,

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.darkBorder),

        ),

        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.darkBorder),

        ),

        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),

        ),

      ),

      elevatedButtonTheme: ElevatedButtonThemeData(

        style: ElevatedButton.styleFrom(

          backgroundColor: AppColors.primaryBlue,

          foregroundColor: Colors.white,

          minimumSize: const Size.fromHeight(52),

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          elevation: 0,

          textStyle: GoogleFonts.poppins(

            fontSize: 16,

            fontWeight: FontWeight.w600,

          ),

        ),

      ),

      appBarTheme: AppBarTheme(

        backgroundColor: AppColors.darkSurface,

        foregroundColor: AppColors.darkText,

        elevation: 0,

        centerTitle: false,

        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),

      cardTheme: CardThemeData(

        color: AppColors.darkCard,

        elevation: 2,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(16),

        ),

      ),

      iconTheme: const IconThemeData(

        color: AppColors.darkText,

      ),

      textTheme: GoogleFonts.poppinsTextTheme(

        ThemeData.dark().textTheme,

      ).copyWith(

        bodyLarge: GoogleFonts.poppins(color: AppColors.darkText),

        bodyMedium: GoogleFonts.poppins(color: AppColors.darkText),

        bodySmall: GoogleFonts.poppins(color: AppColors.darkTextSecondary),

        titleLarge: GoogleFonts.poppins(color: AppColors.darkText),

        titleMedium: GoogleFonts.poppins(color: AppColors.darkText),

        titleSmall: GoogleFonts.poppins(color: AppColors.darkText),

      ),

    );

  }

}