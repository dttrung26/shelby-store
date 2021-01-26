import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const primaryColor = Color(0xFF0065F6);
const colorLight = Color(0xFFF2F2F7);

const primaryColorDark = Color(0xFF009BFF);
const colorLightDart = Color(0xFF2B2C2C);
const colorBackgroundDart = Color(0xFF1F1F1F);

class ColorsConfig {
  static ThemeData getTheme(context, bool isDarkTheme) {
    if (!isDarkTheme) {
      return ThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        accentColor: Colors.black87,
        primaryColorLight: Colors.white,
        backgroundColor: colorLight,
        cardColor: Colors.grey.shade100,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
        ),
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Roboto',
              displayColor: Colors.black87,
              bodyColor: Colors.black87,
            ),
        primaryTextTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Roboto',
              displayColor: Colors.black87,
              bodyColor: Colors.black87,
            ),
        accentTextTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Roboto',
              displayColor: Colors.white,
              bodyColor: Colors.white,
            ),
        accentIconTheme: const IconThemeData(
          color: primaryColor,
        ),
        primaryIconTheme: const IconThemeData(
          color: Colors.black87,
        ),
      );
    }
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
//      accentColorBrightness: Brightness.dark,
      accentColor: const Color(0xFFDDDDDD),
      primaryColor: primaryColorDark,
      primaryColorLight: colorLightDart,
      backgroundColor: colorBackgroundDart,
      cardColor: const Color(0xFF8F8F8),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
      ),
      textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Roboto',
          displayColor: Colors.white,
          bodyColor: Colors.white),
      primaryTextTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Roboto',
          displayColor: Colors.white,
          bodyColor: Colors.white),
      accentTextTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Roboto',
          displayColor: Colors.black87,
          bodyColor: Colors.black87),
      accentIconTheme: const IconThemeData(
        color: primaryColor,
      ),
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  static const searchBackgroundColor = Color(0xFF808191);
  static const categoryIconColor = Color(0xFF808191);
  static const activeCheckedBoxColor = Color(0xFF377DFF);
}
