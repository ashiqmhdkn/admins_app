import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/models/batch_model.dart';
import 'package:learning_admin_app/pages/Batch/widget/studentrequest.dart';
import 'package:learning_admin_app/pages/Batch/widget/teacherrequest.dart';

class BatchDetails extends StatefulWidget {
  final Batch batch;
  BatchDetails({super.key, required this.batch});

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CustomSlidingSegmentedControl<int>(
                initialValue: _selectedIndex,
                children: const {
                  0: const Text("students"),
                  1: const Text("Teachers"),
                },
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
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
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          StudentsTabWrapper(
            batchId: widget.batch.batchId,
            batchName: widget.batch.name,
          ),
          TeachersTabWrapper(
            batchId: widget.batch.batchId,
            batchName: widget.batch.name,
          ),
        ],
      ),
    );
  }
}

class StudentsTabWrapper extends StatelessWidget {
  final String batchId;
  final String batchName;

  const StudentsTabWrapper({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Requests"),
              Tab(text: "Accepted"),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [
                BatchRequestsScreen(batchId: batchId, batchName: batchName),
                StudentAcceptedPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeachersTabWrapper extends StatelessWidget {
  final String batchId;
  final String batchName;

  const TeachersTabWrapper({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Requests"),
              Tab(text: "Accepted"),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [
                TeacherRequestScreen(batchId: batchId, batchName: batchName),
                TeacherAcceptedPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudentAcceptedPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Accepted Students"));
  }
}

class TeacherAcceptedPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Accepted Teachers"));
  }
}
