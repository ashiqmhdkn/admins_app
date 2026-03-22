import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';

class Customappbar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;

  const Customappbar({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return AppBar(
      scrolledUnderElevation: 0,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          onPressed: () async {
            // if (authState == null || authState.isEmpty || authState == "loading") {
            //   GoRouter.of(context).push('/login');
            // }
            // String name = await profileapi(authState!);
            context.push('/profile/Vaishnav');
          },
          icon: CircleAvatar(
            backgroundImage: AssetImage("lib/assets/image.png"),
          ),
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
