import 'package:flutter/material.dart';

class Customprimarytext extends StatelessWidget {
  final String text;
  final int fontValue;
  const Customprimarytext({
    super.key,
    required this.text,
    required this.fontValue,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: fontValue.toDouble()));
  }
}
