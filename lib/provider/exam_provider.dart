import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/exam_api.dart';
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/provider/batch_provider.dart';

/// AsyncNotifier for creating an exam
class CreateExamNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<String?> createExam(Exam exam) async {
    state = const AsyncLoading();
    final token = await ref.read(authTokenProvider.future);

    state = await AsyncValue.guard(
      () => createQuiz(token: token!, exam: exam),
    );

    return state.value;
  }
}

final createExamProvider =
    AsyncNotifierProvider<CreateExamNotifier, String?>(
  () => CreateExamNotifier(),
);