import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/widgets/Custom/custom_appbar.dart';
import 'package:learning_admin_app/widgets/Custom/custom_bold_text.dart';
import 'package:learning_admin_app/widgets/batch_course_view.dart';
import 'package:learning_admin_app/widgets/payments_count_container.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: Customappbar(title: "Dashboard"),
      body: Column(
        children: [
          Paymentcountcontainer(),
          const Center(
            child: const Customboldtext(
              text: "Manage Your Batches",
              fontValue: 20,
            ),
          ),
          Expanded(child: BatchCourseview()),
          //   child: ManageTeachers(token: token), // ✅ safe usage
        ],
      ),
    );
  }
}
