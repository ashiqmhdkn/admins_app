import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/exam_attend_page.dart';
import 'package:learning_admin_app/widgets/Cards/exam_card.dart';

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
                            builder: (_) => ExamAttemptPage(
                              title: "Reverend Insanity — Fang Yuan Arc",
                              description:
                                  "Test your knowledge of the demon Gu Master's journey.",
                              questions: getReverendInsanityQuestions(),
                            ),
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

List<QuestionModel> getReverendInsanityQuestions() {
  return [
    // 1. Short Answer
    QuestionModel(
      type: QuestionType.shortAnswer,
      title: "What is Fang Yuan's primary goal throughout Reverend Insanity?",
      description: "State his ultimate ambition in a few words.",
      marks: 2,
      isRequired: true,
    ),

    // 2. Multiple Choice (single correct)
    QuestionModel(
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
      type: QuestionType.longAnswer,
      title:
          "Explain how Fang Yuan uses his 500 years of future knowledge after rebirth.",
      description: "Describe his strategy in the early arcs.",
      marks: 5,
      isRequired: false,
    ),

    // 5. Short Answer
    QuestionModel(
      type: QuestionType.shortAnswer,
      title: "What rank is the Spring Autumn Cicada at the start of the novel?",
      description: "Enter the rank number.",
      marks: 2,
      isRequired: true,
    ),

    // 6. Multiple Choice (single correct)
    QuestionModel(
      type: QuestionType.multipleChoice,
      title:
          "What is the name of the village clan Fang Yuan belongs to at the start?",
      marks: 2,
      isRequired: true,
      options: ["Gu Yue Clan", "Bai Clan", "Qing Mao Mountain", "Lang Ya Sect"],
      correctOptionIndexes: [0],
    ),

    // 7. Multiple Choice (single correct)
    QuestionModel(
      type: QuestionType.multipleChoice,
      title:
          "Which aptitude does Fang Yuan possess, considered the worst in the clan?",
      description: "This makes others underestimate him early on.",
      marks: 3,
      isRequired: true,
      options: [
        "Rank A Wood Aptitude",
        "Rank C Fire Aptitude",
        "Rank E Gray Bone Aptitude",
        "Zero Aptitude",
      ],
      correctOptionIndexes: [2],
    ),

    // 8. Long Answer
    QuestionModel(
      type: QuestionType.longAnswer,
      title:
          "Discuss the philosophical theme of 'a person's true self' as portrayed through Fang Yuan's character.",
      description:
          "The author Gu Zhen Ren uses Fang Yuan to challenge conventional morality. Elaborate.",
      marks: 8,
      isRequired: false,
    ),

    // 9. Short Answer
    QuestionModel(
      type: QuestionType.shortAnswer,
      title:
          "What is the name of the immortal Fang Yuan eventually becomes known as in the later arcs?",
      description: "His alias/title, not his birth name.",
      marks: 3,
      isRequired: false,
    ),

    // 10. Multiple Choice (multi correct)
    QuestionModel(
      type: QuestionType.multipleChoice,
      title:
          "Which of the following methods does Fang Yuan use to accumulate strength in the early chapters?",
      description: "Select all correct strategies.",
      marks: 4,
      isRequired: true,
      options: [
        "Secretly cultivating the Spring Autumn Cicada",
        "Manipulating clan competitions for resources",
        "Forming sincere brotherly bonds",
        "Using future knowledge to exploit opportunities",
      ],
      correctOptionIndexes: [0, 1, 3],
    ),
  ];
}
