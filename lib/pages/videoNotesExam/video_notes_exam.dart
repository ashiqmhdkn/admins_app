import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:learning_admin_app/pages/exam/exam.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Quiz/quiz_creation.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Notes/add_note.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Videos/add_video.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Notes/notes.dart';
import 'package:learning_admin_app/pages/videoNotesExam/Videos/videos.dart';

class VideoNotesExam extends StatefulWidget {
  final String unitName;
  final String unitId;
  const VideoNotesExam({
    super.key,
    required this.unitName,
    required this.unitId,
  });

  @override
  State<VideoNotesExam> createState() => _AdminVide0NotesExamState();
}

class _AdminVide0NotesExamState extends State<VideoNotesExam> {
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
          widget.unitName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CustomSlidingSegmentedControl<int>(
              initialValue: _selectedIndex,
              children: const {
                0: Text("Classes"),
                1: Text("Exam"),
                2: Text("Notes"),
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
        actions: [
          ElevatedButton(
            onPressed: _openBottomSheet,

            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.primary,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 15),
        ],
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
          AdminSubjectVideos(unitName: widget.unitName, unit_id: widget.unitId),
          StudentExams(unitId: widget.unitId),
          AdminSubjectNotes(unitName: widget.unitName,unitId: widget.unitId,),
        ],
      ),
    );
  }

  void _openBottomSheet() {
    if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizCreation(unitId: widget.unitId)),
      );
      return;
    }
    Widget sheet;

    switch (_selectedIndex) {
      case 0:
        sheet = AddVideo(unitid: widget.unitId);
        break;

      case 2:
        sheet = AddNotes(unitId: widget.unitId);
        break;

      default:
        sheet = const SizedBox();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => sheet,
    );
  }
}
