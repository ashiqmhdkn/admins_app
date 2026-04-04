import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/comment_model.dart';
import 'package:learning_admin_app/pages/widgets/Sheet/comment_sheet.dart';

class Videoplayback extends StatefulWidget {
  final String url;
  final String title;
  final String description;

  const Videoplayback({
    super.key,
    required this.url,
    required this.title,
    required this.description,
  });

  @override
  State<Videoplayback> createState() => _VideoplaybackState();
}

class _VideoplaybackState extends State<Videoplayback> {
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      liveStream: false,
      useAsmsTracks: true,
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableQualities: true,
          enablePlaybackSpeed: true,
          enableSubtitles: false,
          playIcon: Icons.play_arrow,
          pauseIcon: Icons.pause_rounded,
          enableAudioTracks: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _betterPlayerController != null
                  ? BetterPlayer(controller: _betterPlayerController!)
                  : const Center(child: CircularProgressIndicator()),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    title: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Text(
                        widget.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tileColor: Theme.of(context).colorScheme.tertiary,
                leading: const Icon(Icons.comment),
                title: const Text(
                  "Comments",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  openCommentsSheet(
                    context,
                    comments: [
                      CommentModel(
                        id: "1",
                        username: "Ashiq",
                        text: "Hello",
                        createdAt: DateTime.now(),
                      ),
                      CommentModel(
                        id: "2",
                        username: "Vishnu",
                        text: "Hi",
                        createdAt: DateTime.now(),
                      ),
                    ],
                    onSend: (text) {
                      debugPrint("New comment: $text");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
