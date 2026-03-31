class StudentResponse {
  String textAnswer;
  List<int> selectedOptionIndexes;

  StudentResponse({this.textAnswer = '', List<int>? selectedOptionIndexes})
    : selectedOptionIndexes = selectedOptionIndexes ?? [];
}
