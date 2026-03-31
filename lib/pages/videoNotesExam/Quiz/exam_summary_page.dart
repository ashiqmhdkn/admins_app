import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/models/student_quiz_response.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/exam_attend_page.dart';

class ExamSummaryPage extends StatelessWidget {
  final Exam exam;
  final List<StudentResponse> responses;

  const ExamSummaryPage({
    super.key,
    required this.exam,
    required this.responses,
  });

 int get _answeredCount {
  int count = 0;
  for (int i = 0; i < exam.questionModels.length; i++) {
    final q = exam.questionModels[i];
    final r = responses[i];

    if (q.type == QuestionType.multipleChoice) {
      if (r.selectedOptionIndexes.isNotEmpty) count++;
    } else {
      if (r.textAnswer.trim().isNotEmpty) count++;
    }
  }
  return count;
}

  int get _totalMarks =>
    exam.questionModels.fold(0, (sum, q) => sum + q.marks);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review & Submit"),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Card(
              elevation: 4,
              color: Theme.of(context).colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: "Answered",
                        value:
                            "$_answeredCount / ${exam.questionModels.length}",
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                    const VerticalDivider(width: 24),
                    Expanded(
                      child: _SummaryTile(
                        label: "Total Marks",
                        value: "$_totalMarks",
                        icon: Icons.star_outline,
                        color: Colors.amber,
                      ),
                    ),
                    const VerticalDivider(width: 24),
                    Expanded(
                      child: _SummaryTile(
                        label: "Skipped",
                        value: "${exam.questionModels.length - _answeredCount}",
                        icon: Icons.radio_button_unchecked,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: exam.questionModels.length,
              itemBuilder: (_, i) {
                final q = exam.questionModels[i];
                final r = responses[i];
                final answered = q.type == QuestionType.multipleChoice
                    ? r.selectedOptionIndexes.isNotEmpty
                    : r.textAnswer.trim().isNotEmpty;

                return Card(
                  elevation: 2,
                  color: Theme.of(context).colorScheme.tertiary,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: answered
                          ? Colors.green
                          : Colors.redAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: answered
                          ? Colors.green.withOpacity(0.15)
                          : Colors.redAccent.withOpacity(0.15),
                      child: Icon(
                        answered ? Icons.check : Icons.close,
                        size: 16,
                        color: answered ? Colors.green : Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      q.title.isEmpty ? "Question ${i + 1}" : q.title,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      answered ? _getResponsePreview(q, r) : "Not answered",
                      style: TextStyle(
                        fontSize: 12,
                        color: answered ? Colors.grey : Colors.redAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: MarksChip(marks: q.marks),
                  ),
                );
              },
            ),
          ),

          // Final submit
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.send_outlined),
                  label: const Text("Submit Exam"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => _SubmitConfirmDialog(
                        onConfirm: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getResponsePreview(QuestionModel q, StudentResponse r) {
    if (q.type == QuestionType.multipleChoice) {
      final selected = r.selectedOptionIndexes
          .map((i) => q.options[i])
          .join(', ');
      return selected;
    }
    return r.textAnswer;
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}

class _SubmitConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _SubmitConfirmDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Submit Exam?"),
      content: const Text(
        "Once submitted, you cannot change your answers. Are you sure you want to proceed?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),

        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Yes, Submit"),
        ),
      ],
    );
  }
}
