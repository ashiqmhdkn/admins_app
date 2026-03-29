import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/notes_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/notes_model.dart';

final _notesAuthTokenProvider = FutureProvider<String?>((ref) async {
  return ref.read(authControllerProvider.notifier).getToken();
});


class NotesNotifier extends AsyncNotifier<List<Note>> {
  String unitId="";
  @override
  Future<List<Note>> build() async {
    final token = await ref.read(_notesAuthTokenProvider.future);
     if (unitId.isEmpty) {return [];}
    print("notes requested in provider request unitId:$unitId");
    print("token: $token");
    return notesGet(token: token!, unitId: unitId);
  }
void setunit_id(String unitId) {
    this.unitId = unitId;
    ref.invalidateSelf();
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> createNote({
    required String title,
    required File file,
  }) async {
    final token = await ref.read(_notesAuthTokenProvider.future);

    try {
      final success = await notesPost(
        token: token!,
        unitId: unitId, // unitId comes from the family argument
        title: title,
        file: file,
      );

      if (success) {
        state = await AsyncValue.guard(
          () => notesGet(token: token, unitId: unitId),
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<bool> updateNote({
    required String noteId,
    String? title,
    File? file,
  }) async {
    final token = await ref.read(_notesAuthTokenProvider.future);

    try {
      final success = await notesPut(
        token: token!,
        noteId: noteId,
        title: title,
        file: file,
      );

      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(
          () => notesGet(token: token, unitId:unitId),
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> deleteNote({required String noteId}) async {
    final token = await ref.read(_notesAuthTokenProvider.future);

    try {
      final success = await notesDelete(token: token!, noteId: noteId);

      if (success) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(
          () => notesGet(token: token, unitId: unitId),
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // ── REFRESH ───────────────────────────────────────────────────────────────
  Future<void> refresh() async {
    final token = await ref.read(_notesAuthTokenProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => notesGet(token: token!, unitId: unitId),
    );
  }
}

/// Usage:
///   ref.watch(notesNotifierProvider("unit_123"))
final notesNotifierProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(
      () => NotesNotifier(),
    );