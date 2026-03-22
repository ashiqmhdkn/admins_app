import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/api/profile_api.dart';
import 'package:learning_admin_app/controller/auth_controller.dart';
import 'package:learning_admin_app/models/user_model.dart';
import 'package:learning_admin_app/pages/login/otp_sheet.dart';
import 'package:learning_admin_app/widgets/Custom/custom_button_one.dart';
import 'package:learning_admin_app/widgets/Custom/custom_text_box.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Login",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('lib/assets/image.png'),
                radius: 100,
              ),
              const SizedBox(height: 30),

              Customtextbox(
                hinttext: 'Phone number',
                textController: _phoneNumberController,
                textFieldIcon: Icons.phone,
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _passwordcontroller,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Custombuttonone(
                text: authState == "loading" ? 'Signing In...' : 'Sign In',
                onTap: () async {
                  FocusScope.of(context).unfocus();

                  final pass = hashPasswordWithSalt(
                    _passwordcontroller.text,
                    "y6SsdIR",
                  );

                  bool success = await ref
                      .read(authControllerProvider.notifier)
                      .login(_phoneNumberController.text, pass);
                  if (!success) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid email or password'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                  final token = await ref
                      .read(authControllerProvider.notifier)
                      .getToken();

                  if (token == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Authentication error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                  User person = await profileapi(token);

                  if (person.role == 'admin') {
                    GoRouter.of(context).go('/adminnav');
                  } else if (person.role == 'teacher') {
                    GoRouter.of(context).go('/teachernav');
                  } else {
                    GoRouter.of(context).go('/');
                  }
                },
              ),

              const SizedBox(height: 10),

              Custombuttonone(
                text: 'Go to Register',
                onTap: () {
                  context.push('/register');
                },
              ),
              const SizedBox(height: 10),

              Custombuttonone(
                text: 'Otp test',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) =>
                        OtpBottomSheet(phone: _phoneNumberController.text),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String hashPasswordWithSalt(String password, String salt) {
    final combined = password + salt;
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
