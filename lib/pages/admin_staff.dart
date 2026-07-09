import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/pages/widgets/Cards/staff_info_card.dart';
import 'package:learning_admin_app/provider/users_provider.dart';

class AdminStaff extends ConsumerWidget {
  const AdminStaff({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final userAsync=ref.watch(UsersNotifierProvider);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Students",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              context.push('/profile/Admin');
            },
            icon: CircleAvatar(
              backgroundImage: AssetImage("lib/assets/image.png"),
            ),
          ),
        ],
      ),
      body:  userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
        data: (users) {
          if(users.isEmpty){
            return const Center(child: Text("No Users Available"));
          }
          return AnimationLimiter(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 400),
                      child: FadeInAnimation(
                        child: StaffInfoTile(
                          user: user,
                          onTap: () {
                            context.push("/profile/${user.username}", extra: user);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
