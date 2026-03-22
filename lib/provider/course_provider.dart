import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/course_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/course_model.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authControllerProvider.notifier).getToken();
});

class CoursesNotifier extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    state = const AsyncValue.loading();
    final token = await ref.read(authTokenProvider.future);
    return coursesget(token!);
  }

  // Create new course
  Future<bool> createCourse({
    required String title,
    required String description,
    required String courseImage,
  }) async {
    final token = await ref.read(authTokenProvider.future);

    try {
      final success = await coursespost(
        token: token!,
        title: title,
        description: description,
        courseImage: courseImage,
      );

      if (success) {
        // Refresh the list only if the operation was successful
        state = await AsyncValue.guard(() => coursesget(token));
      }

      return success;
    } catch (e) {
      // Handle error and return false
      return false;
    }
  }

  // Update existing course
  Future<bool> updateCourse({
    required String courseId,
    required String title,
    required String description,
    required String? courseImage,
  }) async {
    final token = await ref.read(authTokenProvider.future);

    try {
      final success = await coursesPut(
        token: token!,
        courseId: courseId,
        title: title,
        description: description,
        courseImage: courseImage,
      );

      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => coursesget(token));
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Delete course
  Future<bool> deleteCourse({required String courseId}) async {
    state = const AsyncValue.loading();
    final token = await ref.read(authTokenProvider.future);

    try {
      final success = await coursesDelete(token: token!, courseId: courseId);

      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => coursesget(token));
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Refresh courses list
  Future<void> refresh() async {
    final token = await ref.read(authTokenProvider.future);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => coursesget(token!));
  }
}

final coursesNotifierProvider =
    AsyncNotifierProvider<CoursesNotifier, List<Course>>(
      () => CoursesNotifier(),
    );
