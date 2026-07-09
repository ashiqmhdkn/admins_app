import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/user_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/user_model.dart';

final _usersAuthTokenProvider = FutureProvider<String?>((ref) async {
  return ref.read(authControllerProvider.notifier).getToken();
});

class UsersNotifier extends AsyncNotifier<List<User>> {
  String unitId = "";
  @override
  Future<List<User>> build() async {
    final token = await ref.read(_usersAuthTokenProvider.future);
    print("userget from providertoken: $token");

    return usersGet(token: token!);
  }
}
final UsersNotifierProvider = AsyncNotifierProvider<UsersNotifier, List<User>>(
  () => UsersNotifier(),
);
