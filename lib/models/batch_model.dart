class Batch {
  final String batchId;
  final String name;
  final String batchImage;
  final String courseId;
  final String duration;
  final String createdAt;

  Batch({
    required this.batchId,
    required this.name,
    required this.batchImage,
    required this.courseId,
    required this.duration,
    required this.createdAt,
  });

  // 🔹 Convert JSON → Model
  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      batchId: json['batch_id'] ?? '',
      name: json['name'] ?? '',
      batchImage: json['batch_image'] ?? '',
      courseId: json['course_id'] ?? '',
      duration: json['duration'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  // 🔹 Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      "batch_id": batchId,
      "name": name,
      "batch_image": batchImage,
      "course_id": courseId,
      "duration": duration,
      "created_at": createdAt,
    };
  }

  // 🔹 CopyWith (useful for editing)
  Batch copyWith({
    String? batchId,
    String? name,
    String? batchImage,
    String? courseId,
    String? duration,
    String? createdAt,
  }) {
    return Batch(
      batchId: batchId ?? this.batchId,
      name: name ?? this.name,
      batchImage: batchImage ?? this.batchImage,
      courseId: courseId ?? this.courseId,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
