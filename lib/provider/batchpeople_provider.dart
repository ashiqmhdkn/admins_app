import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/batchpeople.dart';
import 'package:learning_admin_app/api/request_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/batch_model.dart';
import 'package:learning_admin_app/models/user_model.dart';

/// Provider to get the auth token
final authTokenProvider = FutureProvider<String?>((ref) async {
  return ref.read(authControllerProvider.notifier).getToken();
});

/// AsyncNotifier for fetching students of a batch
class BatchStudentsNotifier extends AsyncNotifier<List<User>> {
  String batchId = "";

  @override
  Future<List<User>> build() async {
    final token = await ref.read(authTokenProvider.future);

    // If batchId is empty, return empty list
    if (batchId.isEmpty) {
      return [];
    }

    return getBatchStudents(token: token!, batchId: batchId);
  }

  /// Set batchId and trigger rebuild
  void setBatchId(String id) {
    batchId = id;
    ref.invalidateSelf();
  }
}

/// Provider instance
final batchStudentsProvider =
    AsyncNotifierProvider<BatchStudentsNotifier, List<User>>(
  () => BatchStudentsNotifier(),
);