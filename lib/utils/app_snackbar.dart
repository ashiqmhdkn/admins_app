import 'package:flutter/material.dart';

enum SnackType { success, error, warning, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Color? customColor,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    bool showAtTop = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final statusBarHeight = mediaQuery.padding.top;

    final Color backgroundColor = customColor ?? _getColor(type);

    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      behavior: behavior,
      duration: duration,
      margin: behavior == SnackBarBehavior.floating
          ? EdgeInsets.only(
              bottom: showAtTop ? screenHeight - statusBarHeight - 100 : 20,
              top: showAtTop ? statusBarHeight + 10 : 0,
            )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }

  static Color _getColor(SnackType type) {
    switch (type) {
      case SnackType.success:
        return Colors.green;
      case SnackType.error:
        return Colors.red;
      case SnackType.warning:
        return Colors.orange;
      case SnackType.info:
      default:
        return Colors.blueGrey;
    }
  }
}
