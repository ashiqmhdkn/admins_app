import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/units_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/units_model.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authControllerProvider.notifier).getToken();
});

class UnitProvider extends AsyncNotifier<List<Unit>> {
  String subject_id = "";

  @override
  Future<List<Unit>> build() async {
    // Don't manually set loading state - AsyncNotifier handles this
    final token = await ref.read(authTokenProvider.future);
    // If subject_id is empty, return empty list or throw error
    if (subject_id.isEmpty) {
      return [];
    }

    return unitsget(token!, subject_id);
  }

  void setsubject_id(String subject) {
    subject_id = subject;
    // Trigger a rebuild after setting subject_id
    ref.invalidateSelf();
  }

  // Create new unit
  Future<bool> createUnit({
    required String title,
    required String unitImage,
  }) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await unitspost(
        token: token!,
        title: title,
        subject_id: subject_id,
        unitImage: unitImage,
      );

      if (success) {
        // Refresh the list only if the operation was successful
        state = await AsyncValue.guard(() => unitsget(token, subject_id));
      }

      return success;
    } catch (e) {
      // Handle error and return false
      return false;
    }
  }

  // Update existing unit
  Future<bool> updateUnit({
    required String unitId,
    required String title,
    required String? unitImage,
  }) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await unitsPut(
        token: token!,
        unit_id: unitId,
        title: title,
        unitImage: unitImage,
      );

      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => unitsget(token, subject_id));
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Delete unit
  Future<bool> deleteUnit({required String unitId}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await unitsDelete(token: token!, unitId: unitId);

      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => unitsget(token, subject_id));
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Refresh units list
  Future<void> refresh() async {
    final token = await ref.read(authTokenProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => unitsget(token!, subject_id));
  }
}

final unitsNotifierProvider = AsyncNotifierProvider<UnitProvider, List<Unit>>(
  () => UnitProvider(),
);
