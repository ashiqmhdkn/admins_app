import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/request_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authControllerProvider.notifier).getToken();
});

// ─────────────────────────────────────────────
// MODELS (inline — move to models/ if preferred)
// ─────────────────────────────────────────────

class BatchRequest {
  final String requestId;
  final String batchId;
  final String studentId;
  final String status;
  final String createdAt;

  BatchRequest({
    required this.requestId,
    required this.batchId,
    required this.studentId,
    required this.status,
    required this.createdAt,
  });

  factory BatchRequest.fromJson(Map<String, dynamic> json) => BatchRequest(
    requestId: json['request_id'] ?? '',
    batchId: json['batch_id'] ?? '',
    studentId: json['student_id'] ?? '',
    status: json['status'] ?? '',
    createdAt: json['created_at'] ?? '',
  );
}

class BatchMember {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String joinedAt;

  BatchMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.joinedAt,
  });

  factory BatchMember.fromJson(Map<String, dynamic> json) => BatchMember(
    userId: json['user_id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    profileImage: json['profile_image'] ?? '',
    joinedAt: json['joined_at'] ?? '',
  );
}

// ─────────────────────────────────────────────
// BATCH CODE PROVIDER
// ─────────────────────────────────────────────

class BatchCodeNotifier extends AsyncNotifier<String?> {
  String _batchId = '';

  @override
  Future<String?> build() async => null;

  void setBatchId(String batchId) {
    _batchId = batchId;
    ref.invalidateSelf();
  }

  Future<String?> generateCode() async {
    final token = await ref.read(authTokenProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => batchCodeGenerate(token: token!, batchId: _batchId),
    );
    return state.value;
  }

  Future<bool> deleteCode() async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchCodeDelete(token: token!, batchId: _batchId);
      if (success) state = const AsyncValue.data(null);
      return success;
    } catch (e) {
      return false;
    }
  }
}

final batchCodeProvider = AsyncNotifierProvider<BatchCodeNotifier, String?>(
  () => BatchCodeNotifier(),
);

// ─────────────────────────────────────────────
// BATCH REQUESTS PROVIDER
// ─────────────────────────────────────────────

class BatchRequestsNotifier extends AsyncNotifier<List<BatchRequest>> {
  String _batchId = '';

  @override
  Future<List<BatchRequest>> build() async {
    if (_batchId.isEmpty) return [];
    final token = await ref.read(authTokenProvider.future);
    final raw = await batchRequestsGet(token: token!, batchId: _batchId);
    return raw.map((e) => BatchRequest.fromJson(e)).toList();
  }

  void setBatchId(String batchId) {
    _batchId = batchId;
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    final token = await ref.read(authTokenProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final raw = await batchRequestsGet(token: token!, batchId: _batchId);
      return raw.map((e) => BatchRequest.fromJson(e)).toList();
    });
  }

  // Student submits a join request
  Future<bool> submitRequest({required String code}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchRequestSubmit(
        token: token!,
        batchId: _batchId,
        code: code,
      );
      return success;
    } catch (e) {
      return false;
    }
  }

  // Admin accepts a request
  Future<bool> acceptRequest({required String requestId}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchRequestAccept(
        token: token!,
        requestId: requestId,
      );
      if (success) await refresh();
      return success;
    } catch (e) {
      return false;
    }
  }

  // Admin rejects a request
  Future<bool> rejectRequest({required String requestId}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchRequestReject(
        token: token!,
        requestId: requestId,
      );
      if (success) await refresh();
      return success;
    } catch (e) {
      return false;
    }
  }

  // Admin deletes a single request
  Future<bool> deleteSingleRequest({required String requestId}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchRequestDelete(
        token: token!,
        action: 'single',
        requestId: requestId,
      );
      if (success) await refresh();
      return success;
    } catch (e) {
      return false;
    }
  }

  // Admin deletes all accepted requests
  Future<bool> deleteAllAccepted() async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchRequestDelete(
        token: token!,
        action: 'accepted_all',
      );
      if (success) await refresh();
      return success;
    } catch (e) {
      return false;
    }
  }
}

final batchRequestsProvider =
    AsyncNotifierProvider<BatchRequestsNotifier, List<BatchRequest>>(
      () => BatchRequestsNotifier(),
    );

// ─────────────────────────────────────────────
// BATCH TEACHERS PROVIDER
// ─────────────────────────────────────────────

class BatchTeachersNotifier extends AsyncNotifier<List<BatchMember>> {
  String _batchId = '';

  @override
  Future<List<BatchMember>> build() async {
    if (_batchId.isEmpty) return [];
    final token = await ref.read(authTokenProvider.future);
    final raw = await batchTeachersGet(token: token!, batchId: _batchId);
    return raw.map((e) => BatchMember.fromJson(e)).toList();
  }

  void setBatchId(String batchId) {
    _batchId = batchId;
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    final token = await ref.read(authTokenProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final raw = await batchTeachersGet(token: token!, batchId: _batchId);
      return raw.map((e) => BatchMember.fromJson(e)).toList();
    });
  }

  Future<bool> assignTeacher({required String teacherId}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchTeacherAssign(
        token: token!,
        batchId: _batchId,
        teacherId: teacherId,
      );
      if (success) await refresh();
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeTeacher({required String teacherId}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchTeacherRemove(
        token: token!,
        batchId: _batchId,
        teacherId: teacherId,
      );
      if (success) await refresh();
      return success;
    } catch (e) {
      return false;
    }
  }
}

final batchTeachersProvider =
    AsyncNotifierProvider<BatchTeachersNotifier, List<BatchMember>>(
      () => BatchTeachersNotifier(),
    );

// ─────────────────────────────────────────────
// BATCH STUDENTS PROVIDER
// ─────────────────────────────────────────────

class BatchStudentsNotifier extends AsyncNotifier<List<BatchMember>> {
  String _batchId = '';

  @override
  Future<List<BatchMember>> build() async {
    if (_batchId.isEmpty) return [];
    final token = await ref.read(authTokenProvider.future);
    final raw = await batchStudentsGet(token: token!, batchId: _batchId);
    return raw.map((e) => BatchMember.fromJson(e)).toList();
  }

  void setBatchId(String batchId) {
    _batchId = batchId;
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    final token = await ref.read(authTokenProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final raw = await batchStudentsGet(token: token!, batchId: _batchId);
      return raw.map((e) => BatchMember.fromJson(e)).toList();
    });
  }

  Future<bool> removeStudent({required String studentId}) async {
    final token = await ref.read(authTokenProvider.future);
    try {
      final success = await batchStudentRemove(
        token: token!,
        batchId: _batchId,
        studentId: studentId,
      );
      if (success) await refresh();
      return success;
    } catch (e) {
      return false;
    }
  }
}

final batchStudentsProvider =
    AsyncNotifierProvider<BatchStudentsNotifier, List<BatchMember>>(
      () => BatchStudentsNotifier(),
    );
