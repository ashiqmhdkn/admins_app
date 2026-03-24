import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:learning_admin_app/pages/Courses/edit_course.dart';
import 'package:learning_admin_app/pages/Subjects/admin_subjects.dart';
import 'package:learning_admin_app/provider/course_provider.dart';
import 'package:learning_admin_app/widgets/Cards/course_card.dart';
import 'package:learning_admin_app/widgets/Cards/course_card_batch.dart';

class SubjectList extends ConsumerWidget {
  const SubjectList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesNotifierProvider);
    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) {
          return const Center(child: Text("No Coures Available"));
        }
        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  duration: const Duration(milliseconds: 400),
                  child: FadeInAnimation(
                    child: CourseCardBatch(
                      title: course.title,
                      backGroundImage: course.course_image,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminSubjects(
                              course_name: course.title,
                              courseid: course.course_id as String,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
