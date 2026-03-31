
import 'package:learning_admin_app/models/question_model.dart';

class Exam{
  final String title;
  final String? Description;
  final String unit_id;
  final String subject_id;
  final QuestionModel<List> questionModels;

  Exam({
    required this.title,
    required this.questionModels,
    required this.unit_id,
    required this.subject_id,
    this.Description,
  });
  factory Exam.fromJson(Map<String,dynamic> json){
    return Exam(
      subject_id: json['subject_id'],
      title: json['title'], 
      subject_image: json['subject_image'],
      course_id: json['course_id'],);

  }
  Map<String,dynamic>toJson(){
    return {
      'title': title,
      'subject_id':subject_id,
      'subject_image': subject_image,
       'course_id': course_id,
    };
  }

}
