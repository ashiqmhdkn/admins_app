import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color.fromRGBO(247, 247, 247, 1.0),
    primary: Colors.blue,
    secondary: Colors.black,
    tertiary: const Color.fromARGB(255, 204, 204, 204),
    onPrimary: Colors.black,
  ),
);
ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Color.fromARGB(255, 40, 16, 175),
    secondary: Colors.white,
    tertiary: const Color.fromARGB(255, 56, 56, 56),
    onPrimary: Colors.white,
  ),
);
