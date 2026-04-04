import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/api/profile_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/user_model.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_primary_text.dart';
import 'package:learning_admin_app/pages/widgets/dark_or_light.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilepage extends ConsumerWidget {
  final String username;
  const Profilepage({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(actions: [Darkorlight()], scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                    "https://imagedelivery.net/qbIY5PxQGCt4my9mH271vg/99b1944d-1cec-422f-a658-655e7df66800/public",
                  ),
                ),
                const SizedBox(width: 60),
                Flexible(
                  child: Column(
                    children: [
                      Customprimarytext(text: username, fontValue: 25),
                      Customprimarytext(text: "Class XII", fontValue: 15),
                      SizedBox(height: 5),
                      SizedBox(
                        height: 30,
                        width: 90,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          onPressed: () async {
                            var token = await ref
                                .read(authControllerProvider.notifier)
                                .getToken();
                            print("Token in profile page: $token");
                            User user = await profileapi(token!);
                            GoRouter.of(
                              context,
                            ).push('/editProfile', extra: user);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const SizedBox(height: 20),
            _settingsSectionTitle("Feedback"),
            _SettingsTile(
              icon: Icons.star_border,
              title: "Rate the app",
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.flag_outlined,
              title: "Report a problem",
              onTap: () {},
            ),

            const SizedBox(height: 20),
            _settingsSectionTitle("Crescent "),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: "Terms and conditions",
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: "Privacy policy",
              onTap: () {},
            ),

            const SizedBox(height: 20),
            _SettingsTile(
              icon: Icons.logout,
              title: "Sign out",
              onTap: () async {
                await ref.read(authControllerProvider.notifier).logout();
                GoRouter.of(context).go('/login');
              },
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  "Delete account",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

Widget _settingsSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.9),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
