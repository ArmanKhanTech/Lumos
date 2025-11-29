// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The [EditorBackground] enumeration defines the types of backgrounds available for editors.
enum EditorBackground {
  none,
  gradient,
  blur,
}

/// The [Constants] class contains color constants for light and dark themes, including
/// primary and accent colors, as well as background colors for both themes.

/// It provides two [ThemeData] instances:
/// - [lightTheme]: Configured for a light user interface with appropriate colors and styles.
/// - [darkTheme]: Configured for a dark user interface, featuring contrasting colors for visibility.

/// Additionally, an enumeration [EditorBackground] is defined to specify the background types
/// available for editors, such as no background, gradient background, or blurred background.
class Constants {
  static const Color lightPrimary = Color.fromARGB(255, 255, 255, 255);
  static const Color darkPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color lightAccent = Color.fromARGB(255, 0, 0, 0);
  static const Color darkAccent = Color.fromARGB(255, 255, 255, 255);
  static const Color lightBG = Color.fromARGB(255, 255, 255, 255);
  static const Color darkBG = Color.fromARGB(255, 0, 0, 0);

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBG,
    bottomAppBarTheme: const BottomAppBarThemeData(
      elevation: 0,
      color: lightBG,
    ),
    appBarTheme: const AppBarTheme(
        elevation: 0.0,
        backgroundColor: lightBG,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        actionsIconTheme: IconThemeData(color: Colors.black)),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(
          secondary: lightAccent,
        )
        .copyWith(surface: lightBG),
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBG,
    primaryColor: Colors.white,
    bottomAppBarTheme: const BottomAppBarThemeData(
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
        titleTextStyle: TextStyle(color: Colors.white),
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
