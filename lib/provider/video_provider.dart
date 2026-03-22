import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/api/video_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/video_model.dart';
import 'package:video_player/video_player.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authControllerProvider.notifier).getToken();
});

class VideoService {
  final String token;

  VideoService(this.token);

  // Get video duration in seconds
  Future<int?> getVideoDuration(File videoFile) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      return controller.value.duration.inSeconds;
    } catch (e) {
      print('❌ Error getting video duration: $e');
      return null;
    } finally {
      await controller?.dispose();
    }
  }

  // Fetch all videos for a unit
  Future<List<Video>> fetchVideos(String unitId) async {
    return await videosGet(token, unitId);
  }

  Future<bool> uploadVideo({
    required File videoFile,
    required String unitId,
    required String title,
    required String description,
    void Function(int sent, int total)? onProgress,
  }) async {
    final duration = await getVideoDuration(videoFile) ?? 0;
    return await videoUpload(
      token: token,
      videoFile: videoFile,
      duration: duration,
      unit_id: unitId,
      title: title,
      description: description,
      onProgress: onProgress,
    );
  }
}

//   // Delete video
//   Future<bool> deleteVideo(String videoId) async {
//     return await videoDelete(token: token, videoId: videoId);
//   }

final videoServiceProvider = Provider<VideoService>((ref) {
  final token = ref.watch(authTokenProvider).value;
  if (token == null) throw Exception('No token available');
  return VideoService(token);
});

class VideoProvider extends AsyncNotifier<List<Video>> {
  String unitId = "";

  @override
  Future<List<Video>> build() async {
    if (unitId.isEmpty) return [];

    final service = ref.read(videoServiceProvider);
    return service.fetchVideos(unitId);
  }

  // Set which unit to show videos for
  void setUnitId(String unit) {
    unitId = unit;
    ref.invalidateSelf();
  }

  // Reload videos from server
  Future<void> refresh() async {
    if (unitId.isEmpty) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(videoServiceProvider);
      return service.fetchVideos(unitId);
    });
  }

  // Upload new video
  Future<bool> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    void Function(int sent, int total)? onProgress, // 👈 Add this
  }) async {
    final service = ref.read(videoServiceProvider);
    final success = await service.uploadVideo(
      videoFile: videoFile,
      unitId: unitId,
      title: title,
      description: description,
      onProgress: onProgress, // 👈 Pass it down
    );

    if (success) await refresh();
    return success;
  }
}

//   // Delete video
//   Future<bool> deleteVideo(String videoId) async {
//     final service = ref.read(videoServiceProvider);

//     final success = await service.deleteVideo(videoId);

//     if (success) await refresh();
//     return success;
//   }
// }

final videosNotifierProvider =
    AsyncNotifierProvider<VideoProvider, List<Video>>(() => VideoProvider());


