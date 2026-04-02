import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/provider/notes_provider.dart';
import 'package:learning_admin_app/utils/app_snackbar.dart';

class AddNotes extends ConsumerStatefulWidget {
  final String unitId;

  const AddNotes({super.key, required this.unitId});

  @override
  ConsumerState<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends ConsumerState<AddNotes> {
  File? pdfFile;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isUploading = false;

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        pdfFile = File(result.files.single.path!);
      });
    }
  }

  void _submit() async {
    if (pdfFile == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a PDF"),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    final result = await ref
        .read(notesNotifierProvider.notifier)
        .createNote(title: _titleController.text.trim(), file: pdfFile!);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() => _isUploading = false);
      if (result) {
        Navigator.pop(context);
      } else {
        AppSnackBar.show(
          context,
          showAtTop: true,
           message:"failed to create notes ",
            type:SnackType.error,
        );
      }
    });
  }

  Widget _pdfPreview() {
    return Stack(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                pdfFile!.path.split('/').last,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        if (!_isUploading)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => pdfFile = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void oninite() {}

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Add Notes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Title"),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              enabled: !_isUploading,
              decoration: InputDecoration(
                hintText: "Enter notes title",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text("Description"),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              enabled: !_isUploading,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter description",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text("PDF File"),
            const SizedBox(height: 8),

            pdfFile == null
                ? GestureDetector(
                    onTap: _pickPDF,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, size: 40),
                          SizedBox(height: 8),
                          Text("Select PDF File"),
                          Text(
                            "Tap to browse",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  )
                : _pdfPreview(),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isUploading
                        ? const Text(
                            "Uploading...",
                            style: TextStyle(color: Colors.white),
                          )
                        : const Text(
                            "Add Notes",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isUploading
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
