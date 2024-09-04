// utils/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({
    this.primaryColor =  const Color.fromRGBO(255, 193, 7, 1),
    this.secondaryColor = const Color.fromRGBO(33, 150, 243, 1),
    this.neutralColor = const Color.fromRGBO(0, 188, 212, 1),
  });

  final Color primaryColor, secondaryColor, neutralColor;

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
    );
  }

  @override
  ThemeExtension<AppTheme> copyWith({
    MaterialColor? primaryColor,
    MaterialColor? secondaryColor,
    MaterialColor? neutralColor,
  }) {
    return AppTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      neutralColor: neutralColor ?? this.neutralColor,
    );
  }

  @override
  AppTheme lerp(covariant ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      neutralColor:Color.lerp(neutralColor, other.neutralColor, t)!,
    );
  }

  ThemeData _base() {
    final primaryTextTheme = GoogleFonts.montserratTextTheme();
    final secondaryTextTheme = GoogleFonts.poppinsTextTheme();
    final TextTheme = primaryTextTheme.copyWith(
      
    );
    return ThemeData(
      textTheme: TextTheme,
    );
  }
}