enum QuestionType { shortAnswer, longAnswer, multipleChoice }

class QuestionModel {
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
    required this.type,
    this.imagePath,
    this.title = '',
    this.description = '',
    this.answer = '',
    this.marks = 1,
    this.isRequired = false,
    List<String>? options,
    List<int>? correctOptionIndexes,
  })  : options = options ?? [],
        correctOptionIndexes = correctOptionIndexes ?? [];

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      title: json['title'] ?? '',
      imagePath: json['imagePath'],
      description: json['description'] ?? '',
      answer: json['answer'] ?? '',
      marks: json['marks'] ?? 1,
      isRequired: json['isRequired'] ?? false,
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndexes: List<int>.from(json['correctOptionIndexes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'title': title,
      'imagePath': imagePath,
      'description': description,
      'answer': answer,
      'marks': marks,
      'isRequired': isRequired,
      'options': options,
      'correctOptionIndexes': correctOptionIndexes,
    };
  }

  QuestionModel copyWith({
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