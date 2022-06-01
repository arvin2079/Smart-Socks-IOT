/*
* here we define two theme data with custom font and colors for the application,
* one light theme and one dark.
* */


import 'package:flutter/material.dart';

final ThemeData _lightThemeBase = ThemeData.light();
final ThemeData _darkThemeBase = ThemeData.dark();

/// light theme instance
final ThemeData lightTheme = _lightThemeBase.copyWith(
  textTheme: _buildTexttheme(_lightThemeBase.textTheme),
  tabBarTheme: _lightThemeBase.tabBarTheme.copyWith(
    labelColor: Colors.black,
  ),
  appBarTheme: _lightThemeBase.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(
      color: Colors.black, //change your color here
    ),
    actionsIconTheme: IconThemeData(color: _lightThemeBase.backgroundColor),
    titleTextStyle: const TextStyle(
      fontFamily: 'Vazir',
      fontSize: 19,
      color: Colors.black,
    ),
  ),
);

/// dark theme instance
final ThemeData darkTheme = _darkThemeBase.copyWith(
  textTheme: _buildTexttheme(_darkThemeBase.textTheme),
  tabBarTheme: _darkThemeBase.tabBarTheme.copyWith(
    labelColor: Colors.white,
  ),
  appBarTheme: _darkThemeBase.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(
      color: Colors.white, //change your color here
    ),
    actionsIconTheme: IconThemeData(color: _darkThemeBase.backgroundColor),
    titleTextStyle: const TextStyle(
      fontFamily: 'Vazir',
      fontSize: 19,
      color: Colors.white,
    ),
  ),
);

_buildTexttheme(TextTheme base) {
  return base.copyWith(
    button: base.button!.copyWith(fontFamily: 'Vazir'),
    headline1: base.headline1!.copyWith(fontFamily: 'Vazir'),
    headline2: base.headline2!.copyWith(fontFamily: 'Vazir'),
    headline3: base.headline3!.copyWith(fontFamily: 'Vazir'),
    headline4: base.headline4!.copyWith(fontFamily: 'Vazir'),
    headline5: base.headline5!.copyWith(fontFamily: 'Vazir'),
    subtitle1: base.subtitle1!.copyWith(fontFamily: 'Vazir'),
    subtitle2: base.subtitle2!.copyWith(fontFamily: 'Vazir'),
    bodyText1: base.bodyText1!.copyWith(fontFamily: 'Vazir'),
    bodyText2: base.bodyText2!.copyWith(fontFamily: 'Vazir'),
  );
}
