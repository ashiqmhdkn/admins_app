import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/pages/Batch/widget/batch_course_card.dart';
import 'package:learning_admin_app/pages/Subjects/edit_subject.dart';
import 'package:learning_admin_app/provider/subjects_provider.dart';
class SubjectList extends ConsumerStatefulWidget {
  final String courseId;
  const SubjectList({super.key, required this.courseId});
  @override
  ConsumerState<SubjectList> createState() => _SubjecList();
}

class _SubjecList extends ConsumerState<SubjectList> {
  @override
  void initState() {
    super.initState();
    ref.read(subjectsNotifierProvider.notifier).setcourse_id(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsNotifierProvider);
    return subjectsState.when(
      data: (subjects) {
        if (subjects.isEmpty) {
          return const Center(child: Text('No Subjects available'));
        }
        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  duration: const Duration(milliseconds: 400),
                  child: FadeInAnimation(
                    child: BatchCourseCard(
                      onToggle: (value) {},
                      isEnabled: true,
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
                                    "Delete Subject?",
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
                              .read(subjectsNotifierProvider.notifier)
                              .deleteSubject(subjectId: subject.subject_id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Subject deleted")),
                          );
                        }
                      },
                      onEdit: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (context) => EditSubject(subject: subject),
                        );
                      },
                      title: subject.title,
                      backGroundImage: subject.subject_image,
                      onTap: () {
                        context.push(
                          '/chapterupdate/${subject.title}',
                          extra: subject.subject_id,
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
