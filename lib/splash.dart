import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/api/profile_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_bold_text.dart';
// your AuthController

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ref.read(authControllerProvider.notifier).getToken();

    if (token == null || token == "loading") {
      // No token → go to login
      GoRouter.of(context).go('/login');
    }
    // If you need profile API call:
    final user = await profileapi(token!);
    // Timer(Duration(seconds: 5),()=>context.go('/test'));
    if (user == Error()) {
      SnackBar(content: Text("unsuccessfull user fetch"));
      GoRouter.of(context).go('/login');
    } else {
      print(user);
      // your existing API
      switch (user.role) {
        case 'admin':
          GoRouter.of(context).go('/adminnav');
          break;
        case 'teacher':
          GoRouter.of(context).go("/teachernav");
          break;
        case 'student':
          GoRouter.of(context).go("/");
          break;
        default:
          GoRouter.of(context).go('/login');
      }
    }
    // );
  }

  @override
  Widget build(BuildContext context) {
    // set theme according to system
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              radius: 80,
              backgroundImage: Image.asset('lib/assets/image.png').image,
            ), // simple splash loader
          ),
          SizedBox(height: 10),
          Customboldtext(
            text: "A LEGACY OF SUCCESS \n     FOR GENERATIONS",
            fontValue: 17,
          ),
        ],
      ),
    );
  }
}
