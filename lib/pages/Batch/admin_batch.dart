import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/pages/Batch/add_batch.dart';
import 'package:learning_admin_app/pages/Batch/edit_batch.dart';
import 'package:learning_admin_app/provider/batch_provider.dart';
import 'package:learning_admin_app/provider/request_provider.dart';
import 'package:learning_admin_app/utils/app_snackbar.dart';
import 'package:learning_admin_app/widgets/Cards/edit_batch_card.dart';

class Adminbatch extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;

  const Adminbatch({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  ConsumerState<Adminbatch> createState() => _AdminbatchState();
}

class _AdminbatchState extends ConsumerState<Adminbatch> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(batchsNotifierProvider.notifier).setcourse_id(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          widget.courseName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddBatch(),
              );
            },
          ),
        ],
      ),
      body: _buildBatchsGrid(),
    );
  }

  Widget _buildBatchsGrid() {
    String course_id=widget.courseId;
    final batchsAsync = ref.watch(batchsNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: batchsAsync.when(
        data: (batchs) {
          if (batchs.isEmpty) {
            return const Center(child: Text('No batchs available'));
          }

          return AnimationLimiter(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: batchs.length,
              itemBuilder: (context, index) {
                final batch = batchs[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: 2,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: FadeInAnimation(
                      child: EditBatchCard(
                        title: batch.name,
                        image: batch.batchImage,
                        onGenerate: () async {
                          ref
                              .read(batchCodeProvider.notifier)
                              .setBatchId(batch.batchId);
                          final code = await ref
                              .read(batchCodeProvider.notifier)
                              .generateCode();

                          if (!context.mounted) return;

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: const Text(
                                  "Referral Code",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Card(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiary,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: SelectableText(
                                                code ?? "No code generated",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  letterSpacing: 2,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            IconButton(
                                              onPressed: () async {
                                                await Clipboard.setData(
                                                  ClipboardData(
                                                    text: code.toString(),
                                                  ),
                                                );

                                                Navigator.pop(context);

                                                AppSnackBar.show(
                                                  context,
                                                  type: SnackType.success,
                                                  message:
                                                      "Code copied to clipboard",
                                                );
                                              },
                                              icon: Icon(
                                                Icons.copy,
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
                              );
                            },
                          );
                        },
                        onDelete: () async {
                          final confirm = await showModalBottomSheet<bool>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Delete Batch?",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    const Text("This action cannot be undone."),

                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Delete"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          if (confirm == true) {
                            await ref
                                .read(batchsNotifierProvider.notifier)
                                .deleteBatch(batchId: batch.batchId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Batch deleted")),
                            );
                          }
                        },
                        onEdit: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => EditBatch(),
                          );
                        },
                        onTap: () {
                          // Navigate to lessons page
                          context.push('/batchdetails/$course_id',extra: batch);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(batchsNotifierProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
