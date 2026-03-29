import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/widgets/Custom/custom_bold_text.dart';
import 'package:learning_admin_app/widgets/admin_appbar.dart';
class QuizReviewPage extends StatelessWidget {
  final String title;
  final String description;
  final List<QuestionModel> questions;

  const QuizReviewPage({
    super.key,
    required this.title,
    required this.description,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AdminAppBar(title: "Review Quiz",onAddPressed: () {
        
      },),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title :  $title",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Description : $description",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Customboldtext(text: "Questions", fontValue: 24),
            const SizedBox(height: 10),
            ...questions.asMap().entries.map((entry) {
              int idx = entry.key;
              QuestionModel q = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q${idx + 1}: ${q.title}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (q.description.isNotEmpty) ...[
                      Text(q.description),
                      const SizedBox(height: 8),
                    ],

                    if (q.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(q.imagePath!),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),

                    if (q.type == QuestionType.multipleChoice)
                      _buildMCQPreview(q)
                    else
                      _buildTextAnswerPreview(q),

                    const SizedBox(height: 8),
                    Text(
                      "Marks: ${q.marks} | Required: ${q.isRequired ? 'Yes' : 'No'}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMCQPreview(QuestionModel q) {
    return Column(
      children: List.generate(q.optionControllers.length, (i) {
        bool isCorrect = q.correctOptionIndexes.contains(i);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            border: Border.all(
              color: isCorrect ? Colors.green : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_box : Icons.check_box_outline_blank,
                color: isCorrect ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 10),

              Expanded(child: Text(q.optionControllers[i].text)),

              if (isCorrect)
                const Text(
                  "Correct",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextAnswerPreview(QuestionModel q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Answer",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(q.answer.isEmpty ? "No answer provided." : q.answer),
        ],
      ),
    );
  }
}
