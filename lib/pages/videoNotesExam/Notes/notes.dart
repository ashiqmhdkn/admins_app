import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:learning_admin_app/provider/notes_provider.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Notes/securePdfViewer.dart';
import 'package:learning_admin_app/widgets/Cards/notes_card.dart';

class AdminSubjectNotes extends ConsumerStatefulWidget {
  final String unitName;
  final String unitId;
  const AdminSubjectNotes({
    super.key,
    required this.unitName,
    required this.unitId,
  });
  ConsumerState<AdminSubjectNotes> createState() => _notesState();
}

class _notesState extends ConsumerState<AdminSubjectNotes> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notesNotifierProvider.notifier).setunit_id(widget.unitId);
      print("working notes fetch request");
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.read(notesNotifierProvider.notifier).setunit_id(widget.unitId);
    final notesAsync = ref.watch(notesNotifierProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimationLimiter(
          child: notesAsync.when(
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
                      ref.invalidate(notesNotifierProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

            data: (notes) {
              if (notes.isEmpty) {
                return const Center(child: Text("No Notes availale"));
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 400),
                      child: FadeInAnimation(
                        child: AdminSubjectNotesCard(
                          title: note.title,
                          subtitle: "file format notmention",
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SecurePdfViewer(noteId: note.noteId),
                              ),
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
                                        "Delete Note?",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      const Text(
                                        "This action cannot be undone.",
                                      ),

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
                                  .read(notesNotifierProvider.notifier)
                                  .deleteNote(noteId: note.noteId);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Note deleted")),
                              );
                            }
                          },
                          onEdit: () {},
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

