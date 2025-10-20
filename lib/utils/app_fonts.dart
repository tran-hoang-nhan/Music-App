import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Primary font family
  static String get primaryFont => 'Poppins';
  
  // Font utility methods for easy access
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
  
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
  
  static TextStyle roboto({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
  
  static TextStyle montserrat({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Common text styles for the app
  static TextStyle get heading1 => poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static TextStyle get heading2 => poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static TextStyle get heading3 => poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get bodyLarge => poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
  
  static TextStyle get bodyMedium => poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
  
  static TextStyle get bodySmall => poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );
  
  static TextStyle get caption => poppins(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  // Special styles for music app
  static TextStyle get songTitle => poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  
  static TextStyle get artistName => poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );
  
  static TextStyle get albumTitle => poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static TextStyle get buttonText => poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get tabLabel => poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

