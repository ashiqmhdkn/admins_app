import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/models/units_model.dart';
import 'package:learning_admin_app/provider/unit_provider.dart';
import 'package:learning_admin_app/utils/app_snackbar.dart';
import 'package:learning_admin_app/utils/image_cropper.dart';

class EditUnit extends ConsumerStatefulWidget {
  final Unit unit;

  const EditUnit({super.key, required this.unit});

  @override
  ConsumerState<EditUnit> createState() => _EditUnitState();
}

class _EditUnitState extends ConsumerState<EditUnit> {
  String? newUnitImage; // New local image path
  late TextEditingController _titleController;
  bool _isUploading = false;
  bool _keepExistingImage = true; // Flag to track if we keep the network image
  final double _aspectRatio = 1;
  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing unit data
    _titleController = TextEditingController(text: widget.unit.title);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final String pickedImagePath = result.files.single.path!;

      // Open crop page
      final String? croppedImagePath = await ImageCropHelper.cropImage(
        context,
        pickedImagePath,
        aspectRatio: _aspectRatio,
      );

      // If user completed cropping, use the cropped image
      if (croppedImagePath != null) {
        setState(() {
          newUnitImage = croppedImagePath;
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      newUnitImage = null;
      _keepExistingImage = false; // Remove existing image too
    });
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
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Edit Unit",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Name"),
              const SizedBox(height: 6),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter Unit name",
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

              const SizedBox(height: 20),

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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
      ),
    );
  }

  Widget _buildImageWidget() {
    // If new image is selected, show it
    if (newUnitImage != null) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: _aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(newUnitImage!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
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

    // If keeping existing image, show network image
    if (_keepExistingImage && widget.unit.unit_image.isNotEmpty) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: _aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.unit.unit_image,
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
            Text("Select Image for the Unit"),
            Text("or Browse", style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_titleController.text.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please fill all fields and select a file.",
        type: SnackType.error,
        showAtTop: true,
      );
      return;
    }

    // Check if at least we have an image (either existing or new)
    if (!_keepExistingImage && newUnitImage == null) {
      AppSnackBar.show(
        context,
        message: "Please select an image",
        type: SnackType.error,
        showAtTop: true,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final result = await ref
        .read(unitsNotifierProvider.notifier)
        .updateUnit(
          unitId: widget.unit.unit_id,
          title: _titleController.text,
          unitImage:
              newUnitImage ??
              widget.unit.unit_image, // null if keeping existing image
        );

    setState(() {
      _isUploading = false;
    });

    if (context.mounted) {
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unit updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update unit"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
