enum QuestionType { shortAnswer, longAnswer, multipleChoice }

class QuestionModel {
   String questionId;
   QuestionType type;
   String title;
   String? imagePath;
   String description;
 String answer;
 int marks;
   bool isRequired;
  List<String> options;
   List<int> correctOptionIndexes;

  QuestionModel({
    required this.questionId,
    required this.type,
    this.imagePath,
    this.title = '',
    this.description = '',
    this.answer = '',
    this.marks = 1,
    this.isRequired = false,
    List<String>? options,
    List<int>? correctOptionIndexes,
  }) : options = options ?? [],
       correctOptionIndexes = correctOptionIndexes ?? [];

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionId: json['question_id'] as String,
      type: QuestionType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'] as String? ?? '',
      imagePath: json['image_path'] as String?,
      description: json['description'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      marks: json['marks'] as int? ?? 1,
      isRequired: json['is_required'] as bool? ?? false,
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndexes: List<int>.from(
        json['correct_option_indexes'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'type': type.name,
      'title': title,
      'image_path': imagePath,
      'description': description,
      'answer': answer,
      'marks': marks,
      'is_required': isRequired,
      'options': options,
      'correct_option_indexes': correctOptionIndexes,
    };
  }

  QuestionModel copyWith({
    String? questionId,
    QuestionType? type,
    String? title,
    String? imagePath,
    String? description,
    String? answer,
    int? marks,
    bool? isRequired,
    List<String>? options,
    List<int>? correctOptionIndexes,
  }) {
    return QuestionModel(
      questionId: questionId ?? this.questionId,
      type: type ?? this.type,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      answer: answer ?? this.answer,
      marks: marks ?? this.marks,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
      correctOptionIndexes: correctOptionIndexes ?? this.correctOptionIndexes,
    );
  }
}
