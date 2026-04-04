import 'package:flutter/material.dart';

class Customboldtext extends StatelessWidget {
  final String text;
  final int fontValue;
  const Customboldtext({
    super.key,
    required this.text,
    required this.fontValue,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontValue.toDouble(),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
