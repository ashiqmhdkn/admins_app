import 'package:flutter/material.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_bold_text.dart';

class ExamListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onStartExam;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const ExamListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onStartExam,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shadowColor: theme.colorScheme.secondary,
      color: theme.colorScheme.tertiary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Customboldtext(text: title, fontValue: 16),
        subtitle: Text(subtitle),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isEnabled ? onStartExam : null,
              child: const Text("Start", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(width: 8),

            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
