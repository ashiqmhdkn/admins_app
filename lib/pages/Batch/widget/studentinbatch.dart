import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/provider/request_provider.dart';

class StudentAccepted extends ConsumerWidget {
  final String BatchId;
  const StudentAccepted({super.key, required this.BatchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(batchStudentsProvider);

    // Set batchId once (important: do this outside build if possible)
    ref.read(batchStudentsProvider.notifier).setBatchId(BatchId);

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (students) {
        if (students.isEmpty) {
          return const Center(child: Text("No students found"));
        }
        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return ListTile(
              title: Text(student.name ?? "Unnamed"),
              subtitle: Text("ID: ${student.email}"),
            );
          },
        );
      },
    );
  }
}