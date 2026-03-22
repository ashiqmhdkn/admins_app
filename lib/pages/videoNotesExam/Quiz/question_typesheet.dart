import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/question_model.dart';

class QuestionTypeSheet extends StatelessWidget {
  final void Function(QuestionType) onSelect;

  const QuestionTypeSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.short_text),
          title: const Text("Short Answer"),
          onTap: () => onSelect(QuestionType.shortAnswer),
        ),
        ListTile(
          leading: const Icon(Icons.notes),
          title: const Text("Long Answer"),
          onTap: () => onSelect(QuestionType.longAnswer),
        ),
        ListTile(
          leading: const Icon(Icons.radio_button_checked),
          title: const Text("Multiple Choice"),
          onTap: () => onSelect(QuestionType.multipleChoice),
        ),
      ],
    );
  }
}
