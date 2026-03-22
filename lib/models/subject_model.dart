
class Subject {
  final String title;
  final String subject_image;
  final String course_id;
  final String subject_id;


  Subject({
    required this.title,
    required this.subject_image,
    required this.course_id,
    required this.subject_id
  });
  factory Subject.fromJson(Map<String,dynamic> json){
    return Subject(
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
