import 'package:learning_admin_app/models/question_model.dart';

class Exam {
  String examId;
   String title;
  String? description;
 String unitId;
   String subjectId;
   List<QuestionModel> questionModels;
 
  Exam({
    required this.examId,
    required this.title,
    required this.questionModels,
    required this.unitId,
    required this.subjectId,
    this.description,
  });
 
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      examId: json['exam_id'] as String,
      subjectId: json['subject_id'] as String,
      title: json['title'] as String,
      unitId: json['unit_id'] as String,
      questionModels: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
    );
  }
 
  Map<String, dynamic> toJson() {
    return {
      'exam_id': examId,
      'title': title,
      'subject_id': subjectId,
      'unit_id': unitId,
      'questions': questionModels.map((q) => q.toJson()).toList(),
      'description': description,
    };
  }
 
  Exam copyWith({
    String? examId,
    String? title,
    String? description,
    String? unitId,
    String? subjectId,
    List<QuestionModel>? questionModels,
  }) {
    return Exam(
      examId: examId ?? this.examId,
      title: title ?? this.title,
      description: description ?? this.description,
      unitId: unitId ?? this.unitId,
      subjectId: subjectId ?? this.subjectId,
      questionModels: questionModels ?? this.questionModels,
    );
  }
}