import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/question_review_page.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/question_typesheet.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/text_question_editor_sheet.dart';
import 'package:learning_admin_app/utils/app_snackbar.dart';
import 'package:learning_admin_app/utils/image_cropper.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_appbar.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_button_one.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_text_box.dart';

class QuizCreation extends StatefulWidget {
  final String unitId;
  const QuizCreation({super.key, required this.unitId});

  @override
  State<QuizCreation> createState() => _QuizCreationState();
}

class _QuizCreationState extends State<QuizCreation> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<QuestionModel> _questions = [];

  void _openEditor(QuestionModel q, int index) async {
    final updatedQuestion = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuestionEditorPage(question: q)),
    );

    if (updatedQuestion != null) {
      setState(() {
        _questions[index] = updatedQuestion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Customappbar(title: "Create Questions"),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Customtextbox(
                hinttext: "Quiz Title",
                textController: _titleController,
                textFieldIcon: Icons.title,
              ),
              const SizedBox(height: 10),
              Customtextbox(
                hinttext: "Quiz Description",
                textController: _descriptionController,
                textFieldIcon: Icons.description,
              ),
              const SizedBox(height: 20),

              ...List.generate(
                _questions.length,
                (i) => TextQuestionCard(
                  index: i,
                  question: _questions[i],
                  onTap: () => _openEditor(_questions[i], i),
                  onDelete: () {
                    setState(() => _questions.removeAt(i));
                  },
                  onUpdate: () => setState(() {}),
                ),
              ),

              const SizedBox(height: 10),

              Custombuttonone(
                text: "Add New",
                onTap: () async {
                  final type = await showModalBottomSheet<QuestionType>(
                    context: context,
                    builder: (_) => QuestionTypeSheet(
                      onSelect: (type) {
                        Navigator.pop(context, type);
                      },
                    ),
                  );

                  if (type == null) return;

                  final newQuestion = QuestionModel(
                    questionId: "1",
                    type: type,
                    options: type == QuestionType.multipleChoice ? [''] : [],
                    correctOptionIndexes: [],
                  );

                  final created = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuestionEditorPage(question: newQuestion),
                    ),
                  );

                  if (created != null) {
                    setState(() => _questions.add(created));
                  }
                },
              ),
              const SizedBox(height: 10),
              Custombuttonone(
                text: "Review ",
               onTap: () {
  if (_titleController.text.trim().isEmpty) {
    AppSnackBar.show(
      context,
      message: "Enter a title",
      type: SnackType.error,
    );
  } else if (_questions.isEmpty) {
    AppSnackBar.show(
      context,
      message: "Have atleast one question ",
    );
  } else {
    final exam = _buildExam();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizReviewPage(
          exam: exam, 
        ),
      ),
    );
  }
}
              ),
            ],
          ),
        ),
      ),
    );
  }
  Exam _buildExam() {
  return Exam(
    examId: "3",
    title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),
    unitId: widget.unitId,
    subjectId: "ID", 
    questionModels: _questions,
  );
}
}

class TextQuestionCard extends StatelessWidget {
  final int index;
  final QuestionModel question;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  const TextQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.onTap,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: Theme.of(context).colorScheme.tertiary,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${index + 1}. ${question.title.isEmpty ? "Untitled" : question.title}",
                style: TextStyle(fontSize: 17),
              ),
              if (question.description.isNotEmpty)
                Text(
                  question.description,
                  style: const TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 8),
              if (question.imagePath != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(question.imagePath!),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                question.type == QuestionType.multipleChoice
                    ? "${question.correctOptionIndexes.length} correct / ${question.options.length} options"
                    : "Answer: ${question.answer.isEmpty ? "Not specified" : question.answer}",
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text("Marks : ${question.marks} "),
                  const Spacer(),
                  Switch(
                    value: question.isRequired,
                    onChanged: (v) {
                      question.isRequired = v;
                      onUpdate();
                    },
                    activeThumbColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionEditorPage extends StatefulWidget {
  final QuestionModel question;

  const QuestionEditorPage({super.key, required this.question});

  @override
  State<QuestionEditorPage> createState() => _QuestionEditorPageState();
}

class _QuestionEditorPageState extends State<QuestionEditorPage> {
  late QuestionModel question;

  @override
  void initState() {
    super.initState();
    question = widget.question;
  }

  void _save() {
    if (question.title.isEmpty && question.imagePath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add text or image")));
      return;
    }
    if (question.type == QuestionType.multipleChoice &&
        question.correctOptionIndexes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one correct option")),
      );
      return;
    }

    Navigator.pop(context, question);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Question"),
        scrolledUnderElevation: 0,
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomField(
              label: "Title",
              value: question.title,
              onChanged: (v) {
                question.title = v;
              },
            ),

            CustomField(
              label: "Description",
              value: question.description,
              onChanged: (v) {
                question.description = v;
              },
            ),

            buildImageSection(
              context,
              question,
              () => setState(() {}),
              (fn) => setState(fn),
            ),

            const SizedBox(height: 10),

            if (question.type == QuestionType.multipleChoice)
              buildMCQEditor(
                question: question,
                onUpdate: () => setState(() {}),
                setSheetState: (fn) => setState(fn),
              )
            else
              CustomField(
                label: "Answer",
                value: question.answer,
                onChanged: (v) {
                  question.answer = v;
                },
              ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Marks",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      question.marks = int.tryParse(v) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Text("Required"),
                Switch(
                  value: question.isRequired,
                  onChanged: (v) {
                    setState(() => question.isRequired = v);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget required(
  QuestionModel q,
  VoidCallback onUpdate,
  void Function(void Function()) setSheetState,
) {
  return SwitchListTile(
    title: const Text("Required"),
    value: q.isRequired,
    onChanged: (v) {
      q.isRequired = v;
      setSheetState(() {});
      onUpdate();
    },
  );
}

Widget buildMCQEditor({
  required QuestionModel question,
  required VoidCallback onUpdate,
  required void Function(void Function()) setSheetState,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Options (Select one or more)"),
      const SizedBox(height: 10),

      ...List.generate(
        question.options.length,
        (i) {
          final controller = TextEditingController(text: question.options[i]);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Checkbox(
                  value: question.correctOptionIndexes.contains(i),
                  onChanged: (v) {
                    setSheetState(() {
                      if (v == true &&
                          !question.correctOptionIndexes.contains(i)) {
                        question.correctOptionIndexes.add(i);
                      } else {
                        question.correctOptionIndexes.remove(i);
                      }
                    });
                    onUpdate();
                  },
                ),

                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (val) {
                      question.options[i] = val;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Option ${i + 1}",
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setSheetState(() {
                      question.options.removeAt(i);

                      question.correctOptionIndexes = question
                          .correctOptionIndexes
                          .where((index) => index != i)
                          .map((index) => index > i ? index - 1 : index)
                          .toList();
                    });
                    onUpdate();
                  },
                ),
              ],
            ),
          );
        },
      ),

      TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text("Add option"),
        onPressed: () {
          setSheetState(() {
            question.options.add('');
          });
          onUpdate();
        },
      ),
    ],
  );
}

Future<void> pickAndCropImage(
  BuildContext context,
  QuestionModel question,
  void Function(void Function()) setSheetState,
  VoidCallback onUpdate,
) async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    final pickedPath = result.files.single.path!;

    final croppedPath = await ImageCropHelper.cropImage(
      context,
      pickedPath,
      aspectRatio: 4 / 3,
    );

    if (croppedPath != null) {
      setSheetState(() {
        question.imagePath = croppedPath;
      });
      onUpdate();
    }
  }
}

Widget buildImageSection(
  BuildContext context,
  QuestionModel question,
  VoidCallback onUpdate,
  void Function(void Function()) setSheetState,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      const Text("Question Image"),

      const SizedBox(height: 8),

      if (question.imagePath == null)
        GestureDetector(
          onTap: () =>
              pickAndCropImage(context, question, setSheetState, onUpdate),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 40),
                SizedBox(height: 8),
                Text("Add Image"),
              ],
            ),
          ),
        )
      else
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(question.imagePath!),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setSheetState(() {
                    question.imagePath = null;
                  });
                  onUpdate();
                },
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      SizedBox(height: 10),
    ],
  );
}

