import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/batch_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/batch_model.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authControllerProvider.notifier).getToken();
});

class BatchProvider extends AsyncNotifier<List<Batch>> {
  String course_id = "";

  @override
  Future<List<Batch>> build() async {
    // Don't manually set loading state - AsyncNotifier handles this
    final token = await ref.read(authTokenProvider.future);
    // If course_id is empty, return empty list or throw error
    if (course_id.isEmpty) {
      return [];
    }

    return await getBatches(courseId: course_id, token: token!);
  }

  void setcourse_id(String course) {
    course_id = course;
    // Trigger a rebuild after setting course_id
    ref.invalidateSelf();
  }

  // Create new batch
  Future<bool> createBatch({
    required String title,
    required String batchImage,
    required String duration,
  }) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await postBatch(
        token: token!,
        name: title,
        courseId: course_id,
        imagePath: batchImage,
        duration: duration,
      );

      if (success) {
        // Refresh the list only if the operation was successful
        state = await AsyncValue.guard(
          () => getBatches(token: token!, courseId: course_id),
        );
      }

      return success;
    } catch (e) {
      // Handle error and return false
      return false;
    }
  }

  // Update existing batch
  Future<bool> updateBatch({
    required String batchId,
    required String title,
    required String? batchImage,
    required String duration,
  }) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await putBatch(
        token: token!,
        batchId: batchId,
        name: title,
        imagePath: batchImage,
        duration: duration,
      );

      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(
          () => getBatches(courseId: course_id, token: token!),
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Delete batch
  Future<bool> deleteBatch({required String batchId}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchdelete(token: token!, batchId: batchId);

      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(
          () => getBatches(token: token, courseId: course_id),
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Refresh batchs list
  Future<void> refresh() async {
    final token = await ref.read(authTokenProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => getBatches(token: token!, courseId: course_id),
    );
  }
}

final batchsNotifierProvider =
    AsyncNotifierProvider<BatchProvider, List<Batch>>(() => BatchProvider());
