import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/question_model.dart';

// ---------------------------------------------------------------------------
// QuestionResponse
// Dual-purpose:
//   1. Live mutable answer state during an exam attempt.
//   2. Persisted graded record after submission.
// ---------------------------------------------------------------------------

class QuestionResponse {
  final String questionId;
  final QuestionType type;
  final int maxMarks;

  // ── Student answer fields ────────────────────────────────────────────────
  final List<int> selectedOptionIndexes;
  final String writtenAnswer;

  // ── Grading fields (null = not yet graded) ───────────────────────────────
  final int? marksAwarded;
  final String? feedback;

  const QuestionResponse({
    required this.questionId,
    required this.type,
    required this.maxMarks,
    this.selectedOptionIndexes = const [],
    this.writtenAnswer = '',
    this.marksAwarded,
    this.feedback,
  });

  // ── Convenience getters ──────────────────────────────────────────────────

  bool get isMCQ => type == QuestionType.multipleChoice;

  bool get hasAnswer => isMCQ
      ? selectedOptionIndexes.isNotEmpty
      : writtenAnswer.trim().isNotEmpty;

  bool get needsManualGrading => !isMCQ && marksAwarded == null;

  bool get isGraded => marksAwarded != null;

  bool isOptionSelected(int index) => selectedOptionIndexes.contains(index);

  // ── Mutation helpers (immutable — each returns a new instance) ────────────

  /// Toggle for multi-select MCQ.
  QuestionResponse toggleOption(int index) {
    final updated = List<int>.from(selectedOptionIndexes);
    updated.contains(index) ? updated.remove(index) : updated.add(index);
    return copyWith(selectedOptionIndexes: updated);
  }

  /// Replace selection for single-select MCQ.
  QuestionResponse selectSingleOption(int index) =>
      copyWith(selectedOptionIndexes: [index]);

  /// Update the written answer text.
  QuestionResponse updateWrittenAnswer(String text) =>
      copyWith(writtenAnswer: text);

  // ── Auto-grading ─────────────────────────────────────────────────────────

  /// For MCQ: full marks on exact match, 0 otherwise.
  /// For written types: no-op — marksAwarded stays null for teacher review.
  QuestionResponse autoGrade({required List<int> correctOptionIndexes}) {
    if (!isMCQ) return this;
    final correct = Set<int>.from(correctOptionIndexes);
    final selected = Set<int>.from(selectedOptionIndexes);
    final isCorrect = correct.difference(selected).isEmpty &&
        selected.difference(correct).isEmpty;
    return copyWith(marksAwarded: isCorrect ? maxMarks : 0);
  }

  // ── Factories ─────────────────────────────────────────────────────────────

  /// Build a blank [QuestionResponse] for a question at attempt start.
  factory QuestionResponse.forQuestion(QuestionModel question) {
    return QuestionResponse(
      questionId: question.questionId,
      type: question.type,
      maxMarks: question.marks,
    );
  }

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      questionId: json['question_id'] as String,
      type: QuestionType.values.firstWhere((e) => e.name == json['type']),
      maxMarks: json['max_marks'] as int,
      selectedOptionIndexes:
          List<int>.from(json['selected_option_indexes'] ?? []),
      writtenAnswer: json['written_answer'] as String? ?? '',
      marksAwarded: json['marks_awarded'] as int?,
      feedback: json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'type': type.name,
        'max_marks': maxMarks,
        'selected_option_indexes': selectedOptionIndexes,
        'written_answer': writtenAnswer,
        'marks_awarded': marksAwarded,
        'feedback': feedback,
      };

  QuestionResponse copyWith({
    String? questionId,
    QuestionType? type,
    int? maxMarks,
    List<int>? selectedOptionIndexes,
    String? writtenAnswer,
    int? marksAwarded,
    String? feedback,
  }) {
    return QuestionResponse(
      questionId: questionId ?? this.questionId,
      type: type ?? this.type,
      maxMarks: maxMarks ?? this.maxMarks,
      selectedOptionIndexes:
          selectedOptionIndexes ?? this.selectedOptionIndexes,
      writtenAnswer: writtenAnswer ?? this.writtenAnswer,
      marksAwarded: marksAwarded ?? this.marksAwarded,
      feedback: feedback ?? this.feedback,
    );
  }
}

class ExamResponse {
  final String responseId;
  final String examId;
  final String studentId;
  final DateTime submittedAt;
  final int totalMarks;

  final int obtainedMarks;

  final List<QuestionResponse> questionResponses;

  const ExamResponse({
    required this.responseId,
    required this.examId,
    required this.studentId,
    required this.submittedAt,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.questionResponses,
  });

  double get percentage =>
      totalMarks == 0 ? 0 : (obtainedMarks / totalMarks) * 100;

  bool get isPassed => percentage >= 40;

  bool get isFullyGraded => questionResponses.every((r) => r.isGraded);

  List<QuestionResponse> get pendingManualGrading =>
      questionResponses.where((r) => r.needsManualGrading).toList();

  factory ExamResponse.fromAttempt({
    required Exam exam,
    required List<QuestionResponse> responses,
    required String studentId,
    required String responseId,
  }) {
    assert(
      exam.questionModels.length == responses.length,
      'responses must be parallel to exam.questionModels',
    );

    final graded = List.generate(
      exam.questionModels.length,
      (i) => responses[i].autoGrade(
        correctOptionIndexes: exam.questionModels[i].correctOptionIndexes,
      ),
    );

    final totalMarks =
        exam.questionModels.fold(0, (sum, q) => sum + q.marks);
    final obtainedMarks =
        graded.fold(0, (sum, r) => sum + (r.marksAwarded ?? 0));

    return ExamResponse(
      responseId: responseId,
      examId: exam.examId,
      studentId: studentId,
      submittedAt: DateTime.now(),
      totalMarks: totalMarks,
      obtainedMarks: obtainedMarks,
      questionResponses: graded,
    );
  }


  ExamResponse applyManualGrade({
    required int questionIndex,
    required int marksAwarded,
    String? feedback,
  }) {
    final updated = List<QuestionResponse>.from(questionResponses);
    updated[questionIndex] = updated[questionIndex].copyWith(
      marksAwarded: marksAwarded,
      feedback: feedback,
    );
    final newObtained =
        updated.fold(0, (sum, r) => sum + (r.marksAwarded ?? 0));
    return copyWith(
        questionResponses: updated, obtainedMarks: newObtained);
  }

  factory ExamResponse.fromJson(Map<String, dynamic> json) {
    return ExamResponse(
      responseId: json['response_id'] as String,
      examId: json['exam_id'] as String,
      studentId: json['student_id'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      totalMarks: json['total_marks'] as int,
      obtainedMarks: json['obtained_marks'] as int,
      questionResponses: (json['question_responses'] as List)
          .map((q) => QuestionResponse.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'response_id': responseId,
        'exam_id': examId,
        'student_id': studentId,
        'submitted_at': submittedAt.toIso8601String(),
        'total_marks': totalMarks,
        'obtained_marks': obtainedMarks,
        'question_responses':
            questionResponses.map((r) => r.toJson()).toList(),
      };

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
}