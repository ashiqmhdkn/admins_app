import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:learning_admin_app/pages/Courses/admin_courses.dart';
import 'package:learning_admin_app/pages/admin_dashboard.dart';
import 'package:learning_admin_app/pages/admin_payments.dart';
import 'package:learning_admin_app/pages/admin_staff.dart';

class Adminnav extends StatefulWidget {
  const Adminnav({super.key});

  @override
  State<Adminnav> createState() => _AdminnavState();
}

class _AdminnavState extends State<Adminnav>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final _pages = const [AdminDashboard(), AdminCourses(), AdminStaff(),AdminPayments()];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabChange(int newIndex) {
    if (newIndex == _currentIndex) return;

    _previousIndex = _currentIndex;
    _currentIndex = newIndex;

    final isForward = _currentIndex > _previousIndex;

    _slideAnimation = Tween<Offset>(
      begin: isForward ? const Offset(1, 0) : const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(from: 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _pages[_previousIndex],
          SlideTransition(
            position: _slideAnimation,
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: GNav(
          selectedIndex: _currentIndex,
          onTabChange: _onTabChange,
          gap: 8,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tabBorderRadius: 16,
          activeColor: colorScheme.onPrimary,
          tabBackgroundColor: colorScheme.primary,
          color: colorScheme.secondary,
          tabs: const [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.book_outlined, text: 'Courses'),
            GButton(icon: Icons.person, text: 'Staff'),
            GButton(icon: Icons.monetization_on, text: 'Payments'),
          ],
        ),
      ),
    );
  }
}
