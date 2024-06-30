import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EditorBackground {
  none,
  gradient,
  blur,
}

class Constants {
  static const Color lightPrimary = Color.fromARGB(255, 255, 255, 255);
  static const Color darkPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color lightAccent = Color.fromARGB(255, 0, 0, 0);
  static const Color darkAccent = Color.fromARGB(255, 255, 255, 255);
  static const Color lightBG = Color.fromARGB(255, 255, 255, 255);
  static const Color darkBG = Color.fromARGB(255, 0, 0, 0);

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: lightAccent,
    ),
    scaffoldBackgroundColor: lightBG,
    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      color: lightBG,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0.0,
      backgroundColor: lightBG,
      iconTheme: IconThemeData(color: Colors.black),
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(
          secondary: lightAccent,
        )
        .copyWith(surface: lightBG),
  );

  static ThemeData darkTheme = ThemeData(
    iconTheme: const IconThemeData(color: Colors.white),
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBG,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: darkAccent,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      color: darkBG,
    ),
    appBarTheme: const AppBarTheme(
        elevation: 0.0,
        backgroundColor: darkBG,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
        )),
    colorScheme: ColorScheme.fromSwatch(
      accentColor: darkAccent,
    )
        .copyWith(
          secondary: darkAccent,
          brightness: Brightness.dark,
        )
        .copyWith(surface: darkBG),
  );
}
