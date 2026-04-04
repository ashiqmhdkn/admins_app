import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/api/profile_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/user_model.dart';
import 'package:learning_admin_app/utils/image_cropper.dart';
import 'package:learning_admin_app/utils/image_preview.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_button_one.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_primary_text.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_text_box.dart';

class UpdateProfilePage extends ConsumerStatefulWidget {
  final User user;
  const UpdateProfilePage({super.key, required this.user});

  @override
  ConsumerState<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends ConsumerState<UpdateProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedRole = '';
  bool _isLoading = false;
  String _profileImagePath = "";
  final double _aspectRatio = 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(
      text: widget.user.phone.toString(),
    );
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showError("Name cannot be empty");
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError("Email cannot be empty");
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showError("Phone number cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create updated user object
      final updatedUser = widget.user.copyWith(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: int.tryParse(_phoneController.text.trim()) ?? widget.user.phone,
        role: _selectedRole,
      );
      final token = ref.read(authControllerProvider);

      // Call your user controller to update profile
      await profileupdate(token!, updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      context.go('/');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: _profileImagePath.isNotEmpty
                        ? FileImage(File(_profileImagePath))
                        : const AssetImage('lib/assets/image.png')
                              as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickFile,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: colorScheme.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Customprimarytext(text: "Full Name", fontValue: 15),
            Customtextbox(
              hinttext: "Full Name",
              textController: _nameController,
              textFieldIcon: Icons.person,
            ),

            const SizedBox(height: 16),
            Customprimarytext(text: "Phone Number", fontValue: 15),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.phone),
                hintText: "Phone Number",
              ),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),
            Customprimarytext(text: "Email Address", fontValue: 15),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Email Address",
                prefixIcon: Icon(Icons.mail),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),
            Customprimarytext(text: "Role", fontValue: 15),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                items: ['student', 'teacher', 'admin']
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role[0].toUpperCase() + role.substring(1)),
                      ),
                    )
                    .toList(),
                value: _selectedRole,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Custombuttonone(
                      text: "Save Changes",
                      onTap: _handleSaveChanges,
                    ),
            ),
          ],
        ),
      ),
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
          _profileImagePath = croppedImagePath;
        });
      }
    }
  }

  void _showImagePreviewDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          content: AspectRatioImageField(
            imagePath: imagePath,
            aspectRatio: _aspectRatio,
            onPick: () {},
            onRemove: () {},
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _profileImagePath = imagePath;
                });
                Navigator.pop(context);
              },
              child: const Text("Use Image"),
            ),
          ],
        );
      },
    );
  }
}
