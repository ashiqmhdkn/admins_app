class Course {
  final String? course_id;
  final String title; // e.g., "Class 9"
  final String description;
  final String course_image;

  Course({
    this.course_id,
    required this.title,
    required this.course_image,
    required this.description,
  });
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'],
      course_image: json['course_image'] ?? '',
      description: json['description'],
      course_id: json['course_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'course_image': course_image,
      'description': description,
      'course_id': course_id,
    };
  }

  Course copyWith({
    String? course_id,
    String? course_image,
    String? description,
    String? title,
  }) {
    return Course(
      title: title ?? this.title,
      course_image: course_image ?? this.course_image,
      description: description ?? this.description,
    );
  }
}
