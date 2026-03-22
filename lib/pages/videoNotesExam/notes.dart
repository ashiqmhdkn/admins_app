import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:learning_admin_app/pages/videoNotesExam/video_playback.dart';
import 'package:learning_admin_app/widgets/Cards/notes_card.dart';
class AdminSubjectNotes extends StatelessWidget {
  final String unitName;
  const AdminSubjectNotes({super.key, required this.unitName});

  @override
  Widget build(BuildContext context) {
    final videos = List.generate(7, (index) {
      return {
        "title": "Linear Algebra",
        "subtitle": "Chapter ${index + 1} Notes",
        "image": "lib/assets/maths.jpeg",
      };
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimationLimiter(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];

              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  duration: const Duration(milliseconds: 400),
                  child: FadeInAnimation(
                    child: AdminSubjectNotesCard(
                      title: video["title"]!,
                      subtitle: video["subtitle"]!,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const Videoplayback(
                              url: "",
                              title: "",
                              description: "",
                            ),
                          ),
                        );
                      },
                      onDelete: () {},
                      onEdit: () {},
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
