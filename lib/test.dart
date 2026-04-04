import 'package:flutter/material.dart';
import 'package:learning_admin_app/pages/Courses/add_course_info.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_button_one.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Custombuttonone(
          text: "Test Page ",
          onTap: () {
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (ctx) {
            //       return AddCoursePage(course: ,);
            //     },
            //   ),
            // );
          },
        ),
      ),
    );
  }
}
