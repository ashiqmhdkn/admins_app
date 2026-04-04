import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/examresponse_model.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/exam_summary_page.dart';

class ExamAttemptPage extends StatefulWidget {
  final Exam exam;
  final String studentId;

  const ExamAttemptPage({
    super.key,
    required this.exam,
    required this.studentId,
  });

  @override
  State<ExamAttemptPage> createState() => _ExamAttemptPageState();
}

class _ExamAttemptPageState extends State<ExamAttemptPage> {
  late List<QuestionResponse> _responses;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _responses = widget.exam.questionModels
        .map(QuestionResponse.forQuestion)
        .toList();
  }

  void _goToNext() {
    if (_currentIndex < widget.exam.questionModels.length - 1) {
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
    for (int i = 0; i < widget.exam.questionModels.length; i++) {
      final q = widget.exam.questionModels[i];
      final r = _responses[i];
      if (q.isRequired && !r.hasAnswer) {
        _showValidationError(i, "Please answer question ${i + 1}");
        return;
      }
    }

    final examResponse = ExamResponse.fromAttempt(
      exam: widget.exam,
      responses: _responses,
      studentId: widget.studentId,
      responseId: 'resp_${DateTime.now().millisecondsSinceEpoch}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamSummaryPage(examResponse: examResponse),
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isAnswered(int i) => _responses[i].hasAnswer;

  void _updateResponse(int index, QuestionResponse updated) {
    setState(() => _responses[index] = updated);
  }

  void _showQuestionOverview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuestionOverviewSheet(
        questions: widget.exam.questionModels,
        currentIndex: _currentIndex,
        isAnswered: _isAnswered,
        onNavigate: (i) {
          Navigator.pop(context);
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final total = widget.exam.questionModels.length;
    final progress = total == 0 ? 0.0 : (_currentIndex + 1) / total;
    final answeredCount = List.generate(
      total,
      (i) => i,
    ).where(_isAnswered).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _showQuestionOverview,
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(
                "$answeredCount/$total",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ),
        ],
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
                    ).colorScheme.primaryContainer.withValues(alpha: 0.5),
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: SizedBox(
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
                            margin: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 10,
                            ),
                            width: isActive ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : isAnswered
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.4)
                                  : Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _showQuestionOverview,
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: Theme.of(context).colorScheme.outline,
                    size: 20,
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
                question: widget.exam.questionModels[i],
                response: _responses[i],
                questionNumber: i + 1,
                onUpdate: (updated) => _updateResponse(i, updated),
              ),
            ),
          ),
          _buildBottomBar(total),
        ],
      ),
    );
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

// ─── Question Overview Bottom Sheet ──────────────────────────────────────────

class _QuestionOverviewSheet extends StatelessWidget {
  final List<QuestionModel> questions;
  final int currentIndex;
  final bool Function(int) isAnswered;
  final void Function(int) onNavigate;

  // responses param removed — isAnswered callback already covers this
  const _QuestionOverviewSheet({
    required this.questions,
    required this.currentIndex,
    required this.isAnswered,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final answeredCount = List.generate(
      total,
      (i) => i,
    ).where(isAnswered).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Text(
                      "All Questions",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _LegendDot(
                      color: Theme.of(context).colorScheme.primary,
                      label: "$answeredCount answered",
                    ),
                    const SizedBox(width: 12),
                    _LegendDot(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.5),
                      label: "${total - answeredCount} left",
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: total,
                  itemBuilder: (_, i) {
                    final answered = isAnswered(i);
                    final isCurrent = i == currentIndex;
                    final q = questions[i];

                    final Color bgColor;
                    final Color borderColor;
                    final Color textColor;

                    if (isCurrent) {
                      bgColor = Theme.of(context).colorScheme.primary;
                      borderColor = Theme.of(context).colorScheme.primary;
                      textColor = Theme.of(context).colorScheme.onPrimary;
                    } else if (answered) {
                      bgColor = Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.6);
                      borderColor = Theme.of(context).colorScheme.primary;
                      textColor = Theme.of(context).colorScheme.primary;
                    } else {
                      bgColor = Colors.transparent;
                      borderColor = Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.4);
                      textColor = Theme.of(context).colorScheme.onSurface;
                    }

                    return Tooltip(
                      message: q.title.isNotEmpty
                          ? q.title
                          : "Question ${i + 1}",
                      child: GestureDetector(
                        onTap: () => onNavigate(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: borderColor,
                              width: isCurrent ? 2 : 1.2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                "${i + 1}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              if (q.isRequired && !answered)
                                Positioned(
                                  top: 5,
                                  right: 6,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              if (answered && !isCurrent)
                                Positioned(
                                  bottom: 4,
                                  right: 5,
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(
                      "Red dot = required & unanswered",
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}

// ─── Question Attempt Card ────────────────────────────────────────────────────

class QuestionAttemptCard extends StatelessWidget {
  final QuestionModel question;
  final QuestionResponse response;
  final int questionNumber;
  final void Function(QuestionResponse updated) onUpdate;

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

// ─── MCQ Widget ───────────────────────────────────────────────────────────────

class _MCQAnswerWidget extends StatefulWidget {
  final QuestionModel question;
  final QuestionResponse response;
  final void Function(QuestionResponse) onUpdate;

  const _MCQAnswerWidget({
    required this.question,
    required this.response,
    required this.onUpdate,
  });

  @override
  State<_MCQAnswerWidget> createState() => _MCQAnswerWidgetState();
}

class _MCQAnswerWidgetState extends State<_MCQAnswerWidget> {
  late QuestionResponse _response;

  @override
  void initState() {
    super.initState();
    _response = widget.response;
  }

  // Fix: sync local state when the parent pushes a new response object
  // (e.g. after navigating away and back via the overview sheet).
  @override
  void didUpdateWidget(_MCQAnswerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      _response = widget.response;
    }
  }

  bool get _isMultiSelect => widget.question.correctOptionIndexes.length > 1;

  void _onTap(int i) {
    setState(() {
      _response = _isMultiSelect
          ? _response.toggleOption(i)
          : _response.selectSingleOption(i);
    });
    widget.onUpdate(_response);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isMultiSelect ? "Select all that apply" : "Select one option",
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(options.length, (i) {
          final isSelected = _response.isOptionSelected(i);
          return GestureDetector(
            onTap: () => _onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.4),
                  width: isSelected ? 2 : 1.2,
                ),
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: _isMultiSelect
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      borderRadius: _isMultiSelect
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
                      options[i].isEmpty ? "Option ${i + 1}" : options[i],
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

// ─── Text Answer Widget ───────────────────────────────────────────────────────

class _TextAnswerWidget extends StatefulWidget {
  final QuestionModel question;
  final QuestionResponse response;
  final void Function(QuestionResponse) onUpdate;

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
    _controller = TextEditingController(text: widget.response.writtenAnswer);
  }

  // Fix: if the parent pushes a response whose text differs from the
  // controller (e.g. after programmatic navigation), sync the controller.
  // Guard with a text comparison to avoid moving the cursor while the user types.
  @override
  void didUpdateWidget(_TextAnswerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response.writtenAnswer != _controller.text) {
      _controller.text = widget.response.writtenAnswer;
    }
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
      onChanged: (v) => widget.onUpdate(widget.response.updateWrittenAnswer(v)),
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
  const MarksChip({required this.marks, super.key});

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
