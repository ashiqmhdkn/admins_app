import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
                      onStartExam: () {},
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
