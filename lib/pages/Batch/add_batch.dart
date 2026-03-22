import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/provider/batch_provider.dart';
import 'package:learning_admin_app/utils/app_snackbar.dart';
import 'package:learning_admin_app/utils/image_cropper.dart';
import 'package:learning_admin_app/utils/image_preview.dart';

class AddBatch extends ConsumerStatefulWidget {
  const AddBatch({super.key});

  @override
  ConsumerState<AddBatch> createState() => _AddBatchState();
}

class _AddBatchState extends ConsumerState<AddBatch> {
  String courseImage = "";
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isUploading = false;
  final double _aspectRatio = 1 / 1;

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
          courseImage = croppedImagePath;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: const Text(
                "Add Batch",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            const Text("Name"),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Enter Batch name",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text("Duration"),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,

              decoration: InputDecoration(
                hintText: "Enter Course Duration",
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
                imagePath: courseImage,
                aspectRatio: _aspectRatio,
                onPick: _pickFile,
                onRemove: () => setState(() => courseImage = ""),
              ),
            ),

            const SizedBox(height: 24),

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
                            if (courseImage != "" &&
                                _descriptionController.text.isNotEmpty &&
                                _titleController.text.isNotEmpty) {
                              setState(() {
                                _isUploading = true;
                              });

                              final result = await ref
                                  .read(batchsNotifierProvider.notifier)
                                  .createBatch(
                                    title: _titleController.text,
                                    batchImage: courseImage,
                                    duration: _descriptionController.text,
                                  );

                              setState(() {
                                _isUploading = false;
                              });

                              if (context.mounted) {
                                if (result) {
                                  AppSnackBar.show(
                                    context,
                                    message: "Batch created succesfully",
                                    type: SnackType.success,
                                  );
                                  Navigator.pop(context);
                                } else {
                                  AppSnackBar.show(
                                    context,
                                    message: "Failed to create batch",
                                    type: SnackType.error,
                                    showAtTop: true,
                                  );
                                }
                              }
                            } else {
                              AppSnackBar.show(
                                context,
                                message:
                                    "Please fill all fields and select a file.",
                                type: SnackType.error,
                                showAtTop: true,
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
                        : () {
                            Navigator.pop(context);
                          },
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
