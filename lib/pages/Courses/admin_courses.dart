import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:learning_admin_app/pages/Courses/add_course.dart';
import 'package:learning_admin_app/pages/Courses/add_course_info.dart';
import 'package:learning_admin_app/pages/Courses/edit_course.dart';
import 'package:learning_admin_app/pages/Subjects/admin_subjects.dart';
import 'package:learning_admin_app/provider/course_provider.dart';
import 'package:learning_admin_app/pages/widgets/Cards/course_card.dart';
import 'package:learning_admin_app/pages/widgets/admin_appbar.dart';

class AdminCourses extends ConsumerWidget {
  const AdminCourses({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesNotifierProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AdminAppBar(
        title: "Courses",
        onAddPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return const AddCourse();
            },
          );
        },
      ),
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text("No Coures Available"));
          }
          return AnimationLimiter(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    duration: const Duration(milliseconds: 400),
                    child: FadeInAnimation(
                      child: CourseCard(
                        infoFilling: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) {
                                return AddCoursePage(course: course);
                              },
                            ),
                          );
                        },
                        onEdit: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => EditCourse(course: course),
                          );
                        },
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
                        onDelete: () async {
                          final confirm = await showModalBottomSheet<bool>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Delete Course?",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    const Text("This action cannot be undone."),

                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Delete"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          if (confirm == true) {
                            await ref
                                .read(coursesNotifierProvider.notifier)
                                .deleteCourse(courseId: course.course_id!);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: const Text("Course deleted"),
                              ),
                            );
                          }
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
      ),
    );
  }
}
