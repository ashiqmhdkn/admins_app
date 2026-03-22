import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/provider/video_provider.dart';

class AddVideo extends ConsumerStatefulWidget {
  final String unitid;
  const AddVideo({super.key, required this.unitid});

  @override
  ConsumerState<AddVideo> createState() => _AddVideoState();
}

class _AddVideoState extends ConsumerState<AddVideo> {
  File? videoFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isUploading = false;
  bool _isLoadingDuration = false;
  double _uploadProgress = 0.0; // Tracks 0.0 to 1.0

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      setState(() {
        videoFile = File(result.files.single.path!);
        _uploadProgress = 0.0;
      });
    }
  }

  Future<void> _submit() async {
    if (videoFile == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select a video.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
  
      final result = await ref.read(videosNotifierProvider.notifier).uploadVideo(
            videoFile: videoFile!,
            title: _titleController.text,
            description: _descriptionController.text,
            onProgress: (sent, total) {
              setState(() {
                _uploadProgress = sent / total;
              });
            },
          );

      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video uploaded successfully"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Upload returned false");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _videoPreview() {
    return Stack(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_file, size: 60, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                videoFile!.path.split('/').last,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (!_isUploading) // Don't allow removing file while uploading
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => videoFile = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Video Upload",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Name"),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              enabled: !_isUploading,
              decoration: InputDecoration(
                hintText: "Enter Video name",
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                hintText: "Enter Video Description",
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Video File"),
            const SizedBox(height: 8),
            videoFile == null
                ? GestureDetector(
                    onTap: _pickFile,
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
                          Icon(Icons.video_library_outlined, size: 40),
                          SizedBox(height: 8),
                          Text("Select Video File"),
                          Text("or Browse", style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  )
                : _videoPreview(),
            
            // --- PROGRESS SECTION ---
            if (_isUploading) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[200],
                minHeight: 8,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "${(_uploadProgress * 100).toStringAsFixed(1)}% Uploaded",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: (_isUploading || _isLoadingDuration) ? null : _submit,
                    child: _isUploading
                        ? const Text("Uploading...", style: TextStyle(color: Colors.white))
                        : const Text("Upload", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white)),
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