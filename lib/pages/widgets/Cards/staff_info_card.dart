import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/user_model.dart';

class StaffInfoTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  const StaffInfoTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: Card(
        elevation: 3,
        shadowColor: Theme.of(context).colorScheme.secondary,
        color: Theme.of(context).colorScheme.tertiary,
        child: Center(
          child: InkWell(
            onTap: onTap,
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(user.image!),
              ),
              title: Text(user.username),
            ),
          ),
        ),
      ),
    );
  }
}
