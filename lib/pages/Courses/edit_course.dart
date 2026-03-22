import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/models/course_model.dart';
import 'package:learning_admin_app/provider/course_provider.dart';
import 'package:learning_admin_app/utils/app_snackbar.dart';
import 'package:learning_admin_app/utils/image_cropper.dart';
import 'package:learning_admin_app/utils/image_preview.dart';

class EditCourse extends ConsumerStatefulWidget {
  final Course course;

  const EditCourse({super.key, required this.course});

  @override
  ConsumerState<EditCourse> createState() => _EditCourseState();
}

class _EditCourseState extends ConsumerState<EditCourse> {
  String? newCourseImage; // New local image path
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isUploading = false;
  bool _keepExistingImage = true; // Flag to track if we keep the network image
  final double _aspectRatio = 4 / 3;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course.title);
    _descriptionController = TextEditingController(
      text: widget.course.description,
    );
  }

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
          newCourseImage = croppedImagePath;
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      newCourseImage = null;
      _keepExistingImage = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 2),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Edit Course",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            const Text("Name"),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Enter Course name",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Description"),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter Course Description",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Image"),
            const SizedBox(height: 8),
            _buildImageWidget(),

            const SizedBox(height: 12),
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
                    onPressed: _isUploading ? null : _handleUpdate,
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
                            "Update",
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
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (newCourseImage != null) {
      return Center(
        child: AspectRatioImageField(
          imagePath: newCourseImage!,
          aspectRatio: _aspectRatio,
          onPick: _pickFile,
          onRemove: () => setState(() => newCourseImage = ""),
        ),
      );
    }

    if (_keepExistingImage && widget.course.course_image.isNotEmpty) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: _aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.course.course_image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: const Icon(Icons.error, size: 40),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    // No image - show picker
    return GestureDetector(
      onTap: () => _pickFile(),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 40),
            SizedBox(height: 8),
            Text("Select Image for the Course"),
            Text("or Browse", style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_descriptionController.text.isEmpty || _titleController.text.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please fill all fields ",
        type: SnackType.error,
        showAtTop: true,
      );
      return;
    }

    // Check if at least we have an image (either existing or new)
    if (!_keepExistingImage && newCourseImage == null) {
      AppSnackBar.show(
        context,
        message: "Please select an image.",
        type: SnackType.error,
        showAtTop: true,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final result = await ref
        .read(coursesNotifierProvider.notifier)
        .updateCourse(
          courseId: widget.course.course_id!,
          title: _titleController.text,
          courseImage: newCourseImage,
          description: _descriptionController.text,
        );

    setState(() {
      _isUploading = false;
    });

    if (context.mounted) {
      if (result) {
        AppSnackBar.show(
          context,
          message: "Course udpated successfully",
          type: SnackType.success,
          showAtTop: true,
        );
        Navigator.pop(context);
      } else {
        AppSnackBar.show(
          context,
          message: "Failed to update course",
          type: SnackType.error,
          showAtTop: true,
        );
      }
    }
  }
}
