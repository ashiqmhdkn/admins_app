import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/examresponse_model.dart';
class ExamSummaryPage extends StatelessWidget {
  final ExamResponse examResponse;

  const ExamSummaryPage({super.key, required this.examResponse});

  @override
  Widget build(BuildContext context) {
    final responses = examResponse.questionResponses;
    final total = responses.length;
    final answeredCount = responses.where((r) => r.hasAnswer).length;
    final pendingCount = examResponse.pendingManualGrading.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Summary"),
        scrolledUnderElevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "${examResponse.obtainedMarks} / ${examResponse.totalMarks}",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${examResponse.percentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: examResponse.totalMarks == 0
                            ? 0
                            : examResponse.obtainedMarks /
                                  examResponse.totalMarks,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          examResponse.isPassed
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatChip(
                            label: "Answered",
                            value: "$answeredCount/$total",
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          _StatChip(
                            label: "Pending review",
                            value: "$pendingCount",
                            color: pendingCount > 0
                                ? Colors.orange
                                : Colors.green,
                          ),
                          _StatChip(
                            label: "Result",
                            value: examResponse.isPassed ? "Pass" : "Fail",
                            color: examResponse.isPassed
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ],
                      ),
                      if (pendingCount > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$pendingCount written question(s) are pending teacher review. "
                                  "Your score may increase once graded.",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Question list ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList.builder(
              itemCount: total,
              itemBuilder: (context, i) {
                final r = responses[i];
                return _QuestionSummaryCard(index: i, response: r);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Back to Home"),
          ),
        ),
      ),
    );
  }
}

// ─── Per-question summary card ────────────────────────────────────────────────

class _QuestionSummaryCard extends StatelessWidget {
  final int index;
  final QuestionResponse response;

  const _QuestionSummaryCard({required this.index, required this.response});

  @override
  Widget build(BuildContext context) {
    final isGraded = response.isGraded;
    final isPending = response.needsManualGrading;

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_top_rounded;
      statusLabel = "Pending review";
    } else if (!response.hasAnswer) {
      statusColor = Theme.of(context).colorScheme.outline;
      statusIcon = Icons.remove_circle_outline;
      statusLabel = "Not answered";
    } else if (response.isMCQ) {
      final correct = (response.marksAwarded ?? 0) == response.maxMarks;
      statusColor = correct ? Colors.green : Colors.redAccent;
      statusIcon = correct ? Icons.check_circle : Icons.cancel_outlined;
      statusLabel = correct ? "Correct" : "Incorrect";
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
      statusLabel = "Answered";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  "Q${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Marks chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isGraded
                        ? statusColor.withValues(alpha: 0.12)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isGraded
                          ? statusColor.withValues(alpha: 0.4)
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isGraded
                        ? "${response.marksAwarded}/${response.maxMarks}"
                        : "—/${response.maxMarks}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isGraded
                          ? statusColor
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),

            // Answer preview
            if (response.hasAnswer) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(
                "Your answer:",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _answerPreview(response),
                style: const TextStyle(fontSize: 14),
              ),
            ],

            // Feedback from teacher
            if (response.feedback != null && response.feedback!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        response.feedback!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _answerPreview(QuestionResponse r) {
    if (r.isMCQ) {
      if (r.selectedOptionIndexes.isEmpty) return "No option selected";
      final labels = r.selectedOptionIndexes
          .map((i) => "Option ${i + 1}")
          .join(", ");
      return labels;
    }
    final text = r.writtenAnswer.trim();
    if (text.isEmpty) return "No answer written";
    return text.length > 200 ? "${text.substring(0, 200)}…" : text;
  }
}

// ─── Stat chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
