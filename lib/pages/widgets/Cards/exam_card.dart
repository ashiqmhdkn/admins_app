import 'package:flutter/material.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_bold_text.dart';

class ExamListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onStartExam;

  const ExamListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onStartExam,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Theme.of(context).colorScheme.secondary,
      color: Theme.of(context).colorScheme.tertiary,
      child: ListTile(
        title: Customboldtext(text: title, fontValue: 16),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.green),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          onPressed: onStartExam,
          child: const Text("Start", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
