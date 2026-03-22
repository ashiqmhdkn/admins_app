class Unit {
  final String title;
  final String unit_image;
  final String subject_id;
  final String unit_id;

  Unit({
    required this.title,
    required this.unit_image,
    required this.subject_id,
    required this.unit_id,
  });
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unit_id: json['unit_id'],
      title: json['title'],
      unit_image: json['unit_image'],
      subject_id: json['subject_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'unit_id': unit_id,
      'unit_image': unit_image,
      'subject_id': subject_id,
    };
  }
}
