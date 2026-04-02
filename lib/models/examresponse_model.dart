import 'package:learning_admin_app/models/question_model.dart';

class ExamResponse {
  final String responseId;
  final String examId;
  final String studentId;
  final DateTime submittedAt;
  final int totalMarks;
  final int obtainedMarks;
  final List<QuestionResponse> questionResponses;

  ExamResponse({
    required this.responseId,
    required this.examId,
    required this.studentId,
    required this.submittedAt,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.questionResponses,
  });

  factory ExamResponse.fromJson(Map<String, dynamic> json) {
    return ExamResponse(
      responseId: json['response_id'],
      examId: json['exam_id'],
      studentId: json['student_id'],
      submittedAt: DateTime.parse(json['submitted_at']),
      totalMarks: json['total_marks'] ?? 0,
      obtainedMarks: json['obtained_marks'] ?? 0,
      questionResponses: (json['question_responses'] as List? ?? [])
          .map((q) => QuestionResponse.fromJson(q))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_id': responseId,
      'exam_id': examId,
      'student_id': studentId,
      'submitted_at': submittedAt.toIso8601String(),
      'total_marks': totalMarks,
      'obtained_marks': obtainedMarks,
      'question_responses': questionResponses.map((q) => q.toJson()).toList(),
    };
  }

  ExamResponse copyWith({
    String? responseId,
    String? examId,
    String? studentId,
    DateTime? submittedAt,
    int? totalMarks,
    int? obtainedMarks,
    List<QuestionResponse>? questionResponses,
  }) {
    return ExamResponse(
      responseId: responseId ?? this.responseId,
      examId: examId ?? this.examId,
      studentId: studentId ?? this.studentId,
      submittedAt: submittedAt ?? this.submittedAt,
      totalMarks: totalMarks ?? this.totalMarks,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      questionResponses: questionResponses ?? this.questionResponses,
    );
  }

  double get percentage =>
      totalMarks == 0 ? 0 : (obtainedMarks / totalMarks) * 100;

  bool get isPassed => percentage >= 40;
}

class QuestionResponse {
  final String questionId;
  final QuestionType type;

  // Supports single AND multi-select MCQ — just store all selected indexes
  final List<int> selectedOptionIndexes;

  final String? writtenAnswer;
  final int? marksAwarded;
  final String? feedback;

  QuestionResponse({
    required this.questionId,
    required this.type,
    this.selectedOptionIndexes = const [],
    this.writtenAnswer,
    this.marksAwarded,
    this.feedback,
  });

  /// Toggle an option on/off — returns a new instance with updated selection
  QuestionResponse toggleOption(int index) {
    final updated = List<int>.from(selectedOptionIndexes);
    if (updated.contains(index)) {
      updated.remove(index);
    } else {
      updated.add(index);
    }
    return copyWith(selectedOptionIndexes: updated);
  }

  /// For single-select MCQ — clears previous and selects only one
  QuestionResponse selectSingleOption(int index) {
    return copyWith(selectedOptionIndexes: [index]);
  }

  bool isOptionSelected(int index) => selectedOptionIndexes.contains(index);

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      questionId: json['question_id'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      selectedOptionIndexes:
          List<int>.from(json['selected_option_indexes'] ?? []),
      writtenAnswer: json['written_answer'],
      marksAwarded: json['marks_awarded'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'type': type.toString().split('.').last,
      'selected_option_indexes': selectedOptionIndexes,
      'written_answer': writtenAnswer,
      'marks_awarded': marksAwarded,
      'feedback': feedback,
    };
  }

  QuestionResponse copyWith({
    String? questionId,
    QuestionType? type,
    List<int>? selectedOptionIndexes,
    String? writtenAnswer,
    int? marksAwarded,
    String? feedback,
  }) {
    return QuestionResponse(
      questionId: questionId ?? this.questionId,
      type: type ?? this.type,
      selectedOptionIndexes:
          selectedOptionIndexes ?? this.selectedOptionIndexes,
      writtenAnswer: writtenAnswer ?? this.writtenAnswer,
      marksAwarded: marksAwarded ?? this.marksAwarded,
      feedback: feedback ?? this.feedback,
    );
  }
}