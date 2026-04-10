import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/exam_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/exam_model.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authControllerProvider.notifier).getToken();
});

/// AsyncNotifier for creating an exam
class ExamNotifier extends AsyncNotifier<List<Exam>> {
  String unitId = "";
  String subjectId = "";
  @override
  @override
Future<List<Exam>> build() async {
  state = const AsyncValue.loading();
  final token = await ref.read(authTokenProvider.future);
  if (unitId.isEmpty && subjectId.isEmpty) {
    return [];
  } else if (unitId.isNotEmpty) {
    return getunitExams(token: token!, unitId: unitId);
  } else if (subjectId.isNotEmpty) {
    return getsubjectExams(token: token!, subjectId: subjectId);
  }
  return[];
}

  Future<bool> createExam(Exam exam) async {
    final token = await ref.read(authTokenProvider.future);

    try {
      final success = await createQuiz(token: token!, exam: exam);
      if (success) {
        state = await AsyncValue.guard(() async {
          if (unitId.isEmpty && subjectId.isEmpty) {
            return [];
          } else if (unitId.isNotEmpty) {
            return await getunitExams(token: token!, unitId: unitId);
          } else {
            return await getsubjectExams(token: token!, subjectId: subjectId);
          }
        });
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void setunit_id(String unit) {
    unitId = unit;
    ref.invalidateSelf();
  }
}

/// AsyncNotifier for creating an exa
final ExamProvider = AsyncNotifierProvider<ExamNotifier,List<Exam>>(
  () => ExamNotifier(),
);
