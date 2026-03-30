import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/exam_summary_page.dart';

class StudentResponse {
  String textAnswer;
  List<int> selectedOptionIndexes;

  StudentResponse({this.textAnswer = '', List<int>? selectedOptionIndexes})
    : selectedOptionIndexes = selectedOptionIndexes ?? [];
}

class ExamAttemptPage extends StatefulWidget {
  final String title;
  final String description;
  final List<QuestionModel> questions;

  const ExamAttemptPage({
    super.key,
    required this.title,
    required this.description,
    required this.questions,
  });

  @override
  State<ExamAttemptPage> createState() => _ExamAttemptPageState();
}

class _ExamAttemptPageState extends State<ExamAttemptPage> {
  late List<StudentResponse> _responses;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _responses = List.generate(
      widget.questions.length,
      (_) => StudentResponse(),
    );
  }

  void _goToNext() {
    if (_currentIndex < widget.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrev() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitExam() {
    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final r = _responses[i];
      if (q.isRequired) {
        if (q.type == QuestionType.multipleChoice &&
            r.selectedOptionIndexes.isEmpty) {
          _showValidationError(
            i,
            "Please select an option for question ${i + 1}",
          );
          return;
        }
        if (q.type != QuestionType.multipleChoice &&
            r.textAnswer.trim().isEmpty) {
          _showValidationError(i, "Please answer question ${i + 1}");
          return;
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamSummaryPage(
          title: widget.title,
          questions: widget.questions,
          responses: _responses,
        ),
      ),
    );
  }

  void _showValidationError(int questionIndex, String message) {
    _pageController.animateToPage(
      questionIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final progress = total == 0 ? 0.0 : (_currentIndex + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 300),
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Question ${_currentIndex + 1} of $total",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 28,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: total,
                    itemBuilder: (_, i) {
                      final isActive = i == _currentIndex;
                      final isAnswered = _isAnswered(i);
                      return GestureDetector(
                        onTap: () => _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : isAnswered
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.4)
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: total,
              itemBuilder: (_, i) => QuestionAttemptCard(
                question: widget.questions[i],
                response: _responses[i],
                questionNumber: i + 1,
                onUpdate: () => setState(() {}),
              ),
            ),
          ),
          _buildBottomBar(total),
        ],
      ),
    );
  }

  bool _isAnswered(int i) {
    final q = widget.questions[i];
    final r = _responses[i];
    if (q.type == QuestionType.multipleChoice) {
      return r.selectedOptionIndexes.isNotEmpty;
    }
    return r.textAnswer.trim().isNotEmpty;
  }

  Widget _buildBottomBar(int total) {
    final isLast = _currentIndex == total - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            if (_currentIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  label: Text(
                    "Previous",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onPressed: _goToPrev,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_currentIndex > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                icon: Icon(
                  isLast ? Icons.check_circle_outline : Icons.arrow_forward_ios,
                  size: 14,
                ),
                label: Text(isLast ? "Submit Exam" : "Next"),
                onPressed: isLast ? _submitExam : _goToNext,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: isLast
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionAttemptCard extends StatelessWidget {
  final QuestionModel question;
  final StudentResponse response;
  final int questionNumber;
  final VoidCallback onUpdate;

  const QuestionAttemptCard({
    super.key,
    required this.question,
    required this.response,
    required this.questionNumber,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Card(
        elevation: 4,
        color: Theme.of(context).colorScheme.tertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.title.isEmpty
                              ? "Question $questionNumber"
                              : question.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (question.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            question.description,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MarksChip(marks: question.marks),
                      if (question.isRequired)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            "* Required",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (question.imagePath != null) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(question.imagePath!),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              if (question.type == QuestionType.multipleChoice)
                _MCQAnswerWidget(
                  question: question,
                  response: response,
                  onUpdate: onUpdate,
                )
              else
                _TextAnswerWidget(
                  question: question,
                  response: response,
                  onUpdate: onUpdate,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MCQAnswerWidget extends StatefulWidget {
  final QuestionModel question;
  final StudentResponse response;
  final VoidCallback onUpdate;

  const _MCQAnswerWidget({
    required this.question,
    required this.response,
    required this.onUpdate,
  });

  @override
  State<_MCQAnswerWidget> createState() => _MCQAnswerWidgetState();
}

class _MCQAnswerWidgetState extends State<_MCQAnswerWidget> {
  @override
  Widget build(BuildContext context) {
    final options = widget.question.optionControllers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.correctOptionIndexes.length > 1
              ? "Select all that apply"
              : "Select one option",
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(options.length, (i) {
          final text = options[i].text;
          final isSelected = widget.response.selectedOptionIndexes.contains(i);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (widget.question.correctOptionIndexes.length > 1) {
                  if (isSelected) {
                    widget.response.selectedOptionIndexes.remove(i);
                  } else {
                    widget.response.selectedOptionIndexes.add(i);
                  }
                } else {
                  widget.response.selectedOptionIndexes
                    ..clear()
                    ..add(i);
                }
              });
              widget.onUpdate();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withOpacity(0.4),
                  width: isSelected ? 2 : 1.2,
                ),
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.35)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: widget.question.correctOptionIndexes.length > 1
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      borderRadius:
                          widget.question.correctOptionIndexes.length > 1
                          ? BorderRadius.circular(5)
                          : null,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text.isEmpty ? "Option ${i + 1}" : text,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TextAnswerWidget extends StatefulWidget {
  final QuestionModel question;
  final StudentResponse response;
  final VoidCallback onUpdate;

  const _TextAnswerWidget({
    required this.question,
    required this.response,
    required this.onUpdate,
  });

  @override
  State<_TextAnswerWidget> createState() => _TextAnswerWidgetState();
}

class _TextAnswerWidgetState extends State<_TextAnswerWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.response.textAnswer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLong = widget.question.type == QuestionType.longAnswer;

    return TextField(
      controller: _controller,
      maxLines: isLong ? 6 : 2,
      minLines: isLong ? 4 : 1,
      onChanged: (v) {
        widget.response.textAnswer = v;
        widget.onUpdate();
      },
      decoration: InputDecoration(
        hintText: isLong ? "Write your answer here..." : "Enter your answer",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}

class MarksChip extends StatelessWidget {
  final int marks;
  const MarksChip({required this.marks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$marks ${marks == 1 ? 'mark' : 'marks'}",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
