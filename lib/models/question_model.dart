import 'package:flutter/material.dart';

enum QuestionType { shortAnswer, longAnswer, multipleChoice }

class QuestionModel {
  QuestionType type;
  String title;
  String? imagePath;
  String description;
  String answer;
  int marks;
  bool isRequired;

  List<TextEditingController> optionControllers;
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
  }) : optionControllers = (options ?? [''])
           .map((e) => TextEditingController(text: e))
           .toList(),
       correctOptionIndexes = correctOptionIndexes ?? [];
}
