import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/exam_attend_page.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/exam_summary_page.dart';
import 'package:learning_admin_app/pages/widgets/Cards/exam_card.dart';

class StudentExams extends StatelessWidget {
  final String unitId;
  const StudentExams({super.key, required this.unitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimationLimiter(
          child: ListView.builder(
            itemCount: 10,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: ExamListTile(
                      onStartExam: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamAttemptPage(exam: _buildExam(),studentId: "",),
                          ),
                        );
                      },
                      title: "Name ${index + 1}",
                      subtitle: "Subtitle",
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Exam _buildExam() {
  return Exam(
    examId: "1",
    title: "Reverend Insanity — Fang Yuan Arc",
    description: "Test your knowledge of the demon Gu Master's journey.",
    unitId: " unitId",
    subjectId: "demo_subject",
    questionModels: getReverendInsanityQuestions(),
  );
}

List<QuestionModel> getReverendInsanityQuestions() {
  return [
    // 1. Short Answer
    QuestionModel(
      questionId: "1",
      type: QuestionType.shortAnswer,
      title: "What is Fang Yuan's primary goal throughout Reverend Insanity?",
      description: "State his ultimate ambition in a few words.",
      marks: 2,
      isRequired: true,
    ),

    // 2. Multiple Choice (single correct)
    QuestionModel(
      questionId: "2",
      type: QuestionType.multipleChoice,
      title:
          "Which Gu does Fang Yuan obtain at the beginning of the story that sets him apart?",
      description: "Choose the correct Gu worm.",
      marks: 3,
      isRequired: true,
      options: [
        "Spring Autumn Cicada",
        "Moonlight Gu",
        "Rank 6 Immortal Gu",
        "Blood Python Gu",
      ],
      correctOptionIndexes: [0],
    ),

    // 3. Multiple Choice (multi correct)
    QuestionModel(
      questionId: "3",
      type: QuestionType.multipleChoice,
      title:
          "Which of the following accurately describe Fang Yuan's personality?",
      description: "Select all that apply.",
      marks: 4,
      isRequired: true,
      options: [
        "Ruthlessly rational",
        "Compassionate toward allies",
        "Self-serving above all else",
        "Willing to sacrifice anyone for his goals",
      ],
      correctOptionIndexes: [0, 2, 3],
    ),

    // 4. Long Answer
    QuestionModel(
      questionId: "4",
      type: QuestionType.longAnswer,
      title:
          "Explain how Fang Yuan uses his 500 years of future knowledge after rebirth.",
      description: "Describe his strategy in the early arcs.",
      marks: 5,
      isRequired: false,
    ),

  ];
}
