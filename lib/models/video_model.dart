class Video {
  final String title;
  final String video_id;
  final String unit_id;
  final String description;
  final double duration;
  final String video_url;
  final String thumbnail_url;
  final String status;
  Video({
    required this.description,
    required this.duration,
    required this.status,
    required this.thumbnail_url,
    required this.unit_id,
    required this.video_url,
    required this.title,
    required this.video_id,
  });
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      unit_id: json['unit_id'],
      title: json['title'],
      thumbnail_url: json['thumbnail_url'],
      video_id: json['video_id'],
      video_url: json['video_url'],
      status: json['status'],
      description: json['description'],
      duration: json['duration'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'unit_id': unit_id,
      'thumbnail_url': thumbnail_url,
      'video_id': video_id,
      'video_url': video_url,
      'status': status,
      'description': description,
      'duration': duration,
    };
  }
}

class VideoState {
  final List<Video> videos;
  final bool isUploading;
  final double uploadProgress;

  VideoState({
    required this.videos,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });


  VideoState copyWith({
    List<Video>? videos,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return VideoState(
      videos: videos ?? this.videos,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
