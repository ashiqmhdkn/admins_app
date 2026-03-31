import 'package:learning_admin_app/models/question_model.dart';

class Exam {
  final String title;
  final String? description;
  final String unitId;
  final String subjectId;
  final List<QuestionModel> questionModels;

  Exam({
    required this.title,
    required this.questionModels,
    required this.unitId,
    required this.subjectId,
    this.description,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      subjectId: json['subject_id'],
      title: json['title'],
      unitId: json['unit_id'],
      questionModels:json['questions'],
      //  (json['questions'] as List)
          // .map((q) => QuestionModel.fromJson(q))
          // .toList(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject_id': subjectId,
      'unit_id': unitId,
      // 'questions': questionModels.map((q) => q.toJson()).toList(),
      'description': description,
    };
  }

  Exam copyWith({
    String? title,
    String? description,
    String? unitId,
    String? subjectId,
    List<QuestionModel>? questionModels,
  }) {
    return Exam(
      title: title ?? this.title,
      description: description ?? this.description,
      unitId: unitId ?? this.unitId,
      subjectId: subjectId ?? this.subjectId,
      questionModels: questionModels ?? this.questionModels,
    );
  }
}