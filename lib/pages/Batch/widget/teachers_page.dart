import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/batch_model.dart';
import 'package:learning_admin_app/pages/Batch/widget/teacherrequest.dart';
import 'package:learning_admin_app/widgets/Custom/custom_appbar.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class TeachersPage extends StatelessWidget {
  final Batch batch;

  const TeachersPage({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Customappbar(title: "Teachers"),
      body: TeachersTabWrapper(batchId: batch.batchId, batchName: batch.name),
    );
  }
}

class TeachersTabWrapper extends StatefulWidget {
  final String batchId;
  final String batchName;

  const TeachersTabWrapper({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<TeachersTabWrapper> createState() => _TeachersTabWrapperState();
}

class _TeachersTabWrapperState extends State<TeachersTabWrapper> {
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: CustomSlidingSegmentedControl<int>(
            initialValue: _selectedIndex,
            children: const {0: Text("Requests"), 1: Text("Accepted")},
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: colorScheme.tertiary),
            ),
            thumbDecoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            onValueChanged: (value) {
              setState(() {
                _selectedIndex = value;
              });

              _pageController.animateToPage(
                value,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              TeacherRequestScreen(
                batchId: widget.batchId,
                batchName: widget.batchName,
              ),
              TeacherAcceptedPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }
}

class TeacherAcceptedPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Accepted Teachers"));
  }
}
