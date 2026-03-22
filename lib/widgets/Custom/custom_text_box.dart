import 'package:flutter/material.dart';

class Customtextbox extends StatelessWidget {
  final String hinttext;
  final TextEditingController textController;
  final IconData textFieldIcon;
  const Customtextbox({
    super.key,
    required this.hinttext,
    required this.textController,
    required this.textFieldIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: textController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          textFieldIcon,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        fillColor: Colors.white,
        filled: true,
        hintText: hinttext,
        hintStyle: TextStyle(color: Colors.black),
      ),
    );
  }
}
