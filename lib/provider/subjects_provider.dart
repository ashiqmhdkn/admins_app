import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/subjects_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/subject_model.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  return  ref.watch(authControllerProvider.notifier).getToken();
});
class SubjectProvider extends AsyncNotifier<List<Subject>> {
  String course_id = "";

  @override
  Future<List<Subject>> build() async {
    // Don't manually set loading state - AsyncNotifier handles this
    final token = await ref.read(authTokenProvider.future);

    
    // If course_id is empty, return empty list or throw error
    if (course_id.isEmpty) {
      return [];
    }
    
    return subjectsget(token:token!, course_id:course_id);
  }

  void setcourse_id(String course) {
    course_id = course;
    // Trigger a rebuild after setting course_id
    ref.invalidateSelf();
  }

  // Create new subject
  Future<bool> createSubject({
    required String title,
    required String subjectImage,
  }) async {
    final token = await ref.read(authTokenProvider.future);
    
    try {
      final success = await subjectspost(
        token: token!,
        title: title,
        course_id: course_id,
        subjectImage: subjectImage,
      );
      
      if (success) {
        // Refresh the list only if the operation was successful
        state = await AsyncValue.guard(() => subjectsget(token:token, course_id:course_id));
      }
      
      return success;
    } catch (e) {
      // Handle error and return false
      return false;
    }
  }

  // Update existing subject
  Future<bool> updateSubject({
    required String subjectId,
    required String title,
    required String? subjectImage,
  }) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await subjectsPut(
        token: token!,
        subject_id: subjectId,
        title: title,
        subjectImage: subjectImage,
      );
      
      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => subjectsget(token:token, course_id:course_id));
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // Delete subject
  Future<bool> deleteSubject({
    required String subjectId,
  }) async {
final token = await ref.read(authTokenProvider.future);    
    try {
      final success = await subjectsDelete(
        token: token!,
        subjectId: subjectId,
      );
      
      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => subjectsget(token:token, course_id:course_id));
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // Refresh subjects list
  Future<void> refresh() async {
final token = await ref.read(authTokenProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => subjectsget(token:token!, course_id:course_id));
  }
}

final subjectsNotifierProvider = 
  AsyncNotifierProvider<SubjectProvider, List<Subject>>(
    () => SubjectProvider(),
  );
