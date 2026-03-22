import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_admin_app/models/staff_model.dart';
import 'package:learning_admin_app/widgets/Cards/staff_info_card.dart';

class AdminStaffList extends StatelessWidget {
  final String role;
  const AdminStaffList({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final roles = ["Teacher", "Mentor", "Coordinator", "Collaborator"];

    final List<Staff> staffList = List.generate(
      20,
      (index) => Staff(
        id: "staff_${index + 1}",
        name: "Staff ${index + 1}",
        role: roles[index % roles.length],
      ),
    );

    final filteredStaff = staffList
        .where((staff) => staff.role == role)
        .toList();

    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: filteredStaff.length,
        itemBuilder: (context, index) {
          final staff = filteredStaff[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: AnimationConfiguration.staggeredList(
              position: index,
              child: SlideAnimation(
                duration: const Duration(milliseconds: 400),
                child: FadeInAnimation(
                  child: StaffInfoTile(
                    name: staff.name,
                    role: staff.role,
                    onTap: () {
                      context.push("/profile/${staff.name}", extra: staff);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
