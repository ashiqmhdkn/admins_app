import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/question_model.dart';
import 'package:learning_admin_app/widgets/Custom/custom_button_one.dart';

class TextQuestionEditorSheet extends StatelessWidget {
  final QuestionModel question;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const TextQuestionEditorSheet({
    super.key,
    required this.question,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BaseEditor(
      title: "Edit Question",
      onDelete: onDelete,
      children: [
        (s) => CustomField(
          label: "Title",
          value: question.title,
          onChanged: (v) {
            question.title = v;
            onUpdate();
          },
        ),
        (s) => CustomField(
          label: "Description",
          value: question.description,
          onChanged: (v) {
            question.description = v;
            onUpdate();
          },
        ),
        (s) => CustomField(
          label: "Answer",
          value: question.answer,
          onChanged: (v) {
            question.answer = v;
            onUpdate();
          },
        ),
        (s) => marks(question, onUpdate),
        (s) => required(question, onUpdate, s),
      ],
    );
  }
}

class BaseEditor extends StatelessWidget {
  final String title;
  final List<Widget Function(void Function(void Function()))> children;

  final VoidCallback onDelete;

  const BaseEditor({
    super.key,
    required this.title,
    required this.children,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...children.map((builder) => builder(setSheetState)),

                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: onDelete,
                ),
                Center(
                  child: Custombuttonone(
                    text: "Save",
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget marks(QuestionModel q, VoidCallback onUpdate) {
  return TextField(
    controller: TextEditingController(text: q.marks.toString()),
    keyboardType: TextInputType.number,
    onChanged: (v) {
      q.marks = int.tryParse(v) ?? 1;
      onUpdate();
    },

    decoration: InputDecoration(
      label: Text("Marks"),
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

class CustomField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const CustomField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant CustomField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      controller.text = widget.value;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }
}
