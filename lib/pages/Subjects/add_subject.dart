import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/provider/subjects_provider.dart';
import 'package:learning_admin_app/utils/app_snackbar.dart';
import 'package:learning_admin_app/utils/image_cropper.dart';
import 'package:learning_admin_app/utils/image_preview.dart';

class AddSubject extends ConsumerStatefulWidget {
  const AddSubject({super.key});

  @override
  ConsumerState<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends ConsumerState<AddSubject> {
  String subjectImage = "";
  final TextEditingController _titleController = TextEditingController();
  bool _isUploading = false;
  final double _aspectRatio = 4 / 3;
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final String pickedImagePath = result.files.single.path!;

      final String? croppedImagePath = await ImageCropHelper.cropImage(
        context,
        pickedImagePath,
        aspectRatio: _aspectRatio,
      );

      if (croppedImagePath != null) {
        setState(() {
          subjectImage = croppedImagePath;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Subject Upload",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            const Text("Name"),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Enter Subject name",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text("File"),
            const SizedBox(height: 8),

            Center(
              child: AspectRatioImageField(
                imagePath: subjectImage,
                aspectRatio: _aspectRatio,
                onPick: _pickFile,
                onRemove: () => setState(() => subjectImage = ""),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primary,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    onPressed: _isUploading
                        ? null
                        : () async {
                            if (subjectImage.isEmpty ||
                                _titleController.text.isEmpty) {
                              AppSnackBar.show(
                                context,
                                message:
                                    "Please fill all fields and select a file.",
                                type: SnackType.error,
                                showAtTop: true,
                              );
                              return;
                            }

                            setState(() => _isUploading = true);

                            final success = await ref
                                .read(subjectsNotifierProvider.notifier)
                                .createSubject(
                                  title: _titleController.text,
                                  subjectImage: subjectImage,
                                );

                            setState(() => _isUploading = false);

                            if (!context.mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Subject created successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to create subject"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: _isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Upload",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.tertiary,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    onPressed: _isUploading
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
