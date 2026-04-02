import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/models/batch_model.dart';
import 'package:learning_admin_app/pages/Batch/widget/subject_list.dart';
import 'package:learning_admin_app/widgets/Custom/custom_primary_text.dart';

class BatchDetails extends StatefulWidget {
  final String courseId;
  final Batch batch;
  BatchDetails({super.key, required this.courseId, required this.batch});

  @override
  State<BatchDetails> createState() => _BatchDetailsState();
}

class _BatchDetailsState extends State<BatchDetails> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          widget.batch.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              context.push('/profile/Vaishnav');
            },
            icon: CircleAvatar(
              backgroundImage: AssetImage("lib/assets/image.png"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(
                    context,
                    title: "Students",
                    icon: Icons.people,
                    onTap: () {
                      context.push('/batch/students', extra: widget.batch);
                    },
                  ),
                  _buildGridItem(
                    context,
                    title: "Teachers",
                    icon: Icons.school,
                    onTap: () {
                      context.push('/batch/teachers', extra: widget.batch);
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Customprimarytext(text: "Subjects", fontValue: 17),
            ),

             SubjectList(courseId: widget.courseId,),
          ],
        ),
      ),
    );
  }
}

Widget _buildGridItem(
  BuildContext context, {
  required String title,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.tertiary),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
