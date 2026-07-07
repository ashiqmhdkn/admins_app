import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/models/subject_model.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/exam_attend_page.dart';
import 'package:learning_admin_app/pages/widgets/Cards/exam_card.dart';
import 'package:learning_admin_app/pages/widgets/Cards/exam_delete_card.dart';
import 'package:learning_admin_app/provider/exam_provider.dart';

class ExamCourseEdit extends ConsumerStatefulWidget {
  final String unitId;
  const ExamCourseEdit({super.key, required this.unitId});
@override
  ConsumerState<ExamCourseEdit> createState()=>_studentExams();
}
class _studentExams extends ConsumerState<ExamCourseEdit>{
  @override 
  void initState(){
    super.initState();
    Future.microtask((){
      ref.read(ExamProvider.notifier).setunit_id(widget.unitId);
    });
  }
  @override
  Widget build(BuildContext context) {
    final ExamsState=ref.watch(ExamProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimationLimiter(
          child: ExamsState.when(
            data: (Exams){
              if(Exams.isEmpty){
                return const Center(child: Text("No Exams"),);
              }
              return ListView.builder(
            itemCount: Exams.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final Exam=Exams[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: ExamDeleteTile(
                      onDeleteExam: () {
                        ref.read(ExamProvider.notifier).deleteExam(examId: Exam.examId);
                      },
                      onStartExam: () async{
                       final List<QuestionModel> quesitons= await ref.read(ExamProvider.notifier).questions(Exam.examId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamAttemptPage(
                              exam: _buildExam(Exam,quesitons),
                              studentId: "",
                            ),
                          ),
                        );
                      },
                      title: Exam.title,
                      subtitle: Exam.description??"",
                    ),
                  ),
                ),
              );
            },
          );
            }
          , error: (error, stack) => Center(child: Text('Error: $error')), loading: () => const Center(child: const CircularProgressIndicator()),)
          
        ),
      ),
    );
  }
}

Exam _buildExam(Exam exam,List<QuestionModel> questions) {
  return Exam(
    examId: exam.examId,
    title: exam.title,
    description: exam.description,
    unitId: exam.unitId,
    subjectId: exam.subjectId,
    questionModels: questions,
  );
}