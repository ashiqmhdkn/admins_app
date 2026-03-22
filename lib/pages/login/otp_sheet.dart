import 'package:flutter/material.dart';
import 'package:learning_admin_app/utils/app_snackbar.dart';
import 'package:learning_admin_app/widgets/Custom/custom_button_one.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phone;

  const OtpBottomSheet({super.key, required this.phone});

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String getOtp() {
    return controllers.map((c) => c.text).join();
  }

  void onOtpChange(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFilled = getOtp().length == 6;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Verify Your Phone Number",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            Text(
              "Please enter the 6-digit code we sent to",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 17),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 5),

            Text(
              widget.phone,
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => onOtpChange(index, value),
                  ),
                );
              }),
            ),

            const SizedBox(height: 15),
            Custombuttonone(
              text: "Send Again",
              onTap: () {
                AppSnackBar.show(
                  context,
                  message: "Otp successfully sended",
                  type: SnackType.success,
                  showAtTop: true,
                );
              },
            ),

            const SizedBox(height: 10),
            Custombuttonone(
              text: "Continue",
              onTap: isFilled
                  ? () {
                      final otp = getOtp();

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("OTP Entered: $otp")),
                      );
                    }
                  : null,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
