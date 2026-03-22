import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:learning_admin_app/pages/videoNotesExam/video_playback.dart';
import 'package:learning_admin_app/provider/video_provider.dart';
import 'package:learning_admin_app/widgets/Cards/video_selection_card.dart';
class AdminSubjectVideos extends ConsumerStatefulWidget {
  final String unitName;
  final String unit_id;
  const AdminSubjectVideos({
    super.key,
    required this.unitName,
    required this.unit_id,
  });
  ConsumerState<AdminSubjectVideos> createState() => _AdminSubjectsState();
}

class _AdminSubjectsState extends ConsumerState<AdminSubjectVideos> {
  @override
  void initState() {
    super.initState();
    // Set courseId only once when widget is created
    Future.microtask(() {
      ref.read(videosNotifierProvider.notifier).setUnitId(widget.unit_id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final VideoProvider = ref.watch(videosNotifierProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimationLimiter(
          child: VideoProvider.when(
            data: (Videos) {
              if (Videos.isEmpty) {
                return const Center(child: Text('No Videos available'));
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: Videos.length,
                itemBuilder: (context, index) {
                  final video = Videos[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 400),
                      child: FadeInAnimation(
                        child: AdminVideoSelectionCard(
                          title: video.title,
                          subtitle: video.description,
                          imagelocation: video.thumbnail_url,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Videoplayback(
                                  url: video.video_url,
                                  title: "",
                                  description: "",
                                ),
                              ),
                            );
                          },
                          onEdit: () {},
                          onDelete: () {},
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ),
    );
  }
}
