import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/models/batch_model.dart';
import 'package:learning_admin_app/models/user_model.dart';
import 'package:learning_admin_app/pages/Batch/batch_details.dart';
import 'package:learning_admin_app/pages/Profile/update_profile.dart';
import 'package:learning_admin_app/pages/Units/admin_units.dart';
import 'package:learning_admin_app/pages/admin_nav_bar.dart';
import 'package:learning_admin_app/pages/login/login_page.dart';
import 'package:learning_admin_app/pages/login/register_page.dart';
import 'package:learning_admin_app/pages/Profile/profile_page.dart';
import 'package:learning_admin_app/pages/videoNotesExam/video_notes_exam.dart';
import 'package:learning_admin_app/splash.dart';

final router = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: "/login", builder: (context, state) => const LoginPage()),  
    GoRoute(path: "/batchdetails", builder: (context, state){ 
      final batch=state.extra as Batch; 
      return BatchDetails(batch: batch);}),
    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: "/adminnav", builder: (context, state) => const Adminnav()),
    GoRoute(
      path: "/profile/:username",
      builder: (context, state) {
        final username = state.pathParameters['username']!;
        return Profilepage(username: username);
      },
    ),
    GoRoute(
      path: "/editProfile",
      builder: (context, state) {
        final user = state.extra as User;
        return UpdateProfilePage(user: user);
      },
    ),
     GoRoute(
      path: "/chapterupdate/:name",
      builder: (context, state) {
        final name = state.pathParameters['name']!;
        final subjectId = state.extra as String;
        // final subject_id=state.pathParameters['subject_id']!;
        return AdminUnits(subjectId: subjectId, subjectName: name);
      },
    ),
    GoRoute(
      path: "/adminunits/:unitname",
      builder: (context, state) {
        final unitname = state.pathParameters['unitname']!;
        final unitId = state.extra as String;
        return VideoNotesExam(unitName: unitname, unitId: unitId);
      },
    ),
  ],
);
