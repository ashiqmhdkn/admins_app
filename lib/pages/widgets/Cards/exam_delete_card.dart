import 'package:flutter/material.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_bold_text.dart';

class ExamDeleteTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onStartExam;
  final VoidCallback onDeleteExam;

  const ExamDeleteTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onStartExam,
    required this.onDeleteExam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shadowColor: theme.colorScheme.secondary,
      color: theme.colorScheme.tertiary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onStartExam,
        title: Customboldtext(text: title, fontValue: 16),
        subtitle: Text(subtitle),

        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDeleteExam,
        ),
      ),
    );
  }
}
