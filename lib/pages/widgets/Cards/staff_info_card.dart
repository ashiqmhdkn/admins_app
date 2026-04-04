import 'package:flutter/material.dart';

class StaffInfoTile extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onTap;
  const StaffInfoTile({
    super.key,
    required this.name,
    required this.role,
    required this.onTap,
  });

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
                backgroundImage: AssetImage("lib/assets/image.png"),
              ),
              title: Text(name),
            ),
          ),
        ),
      ),
    );
  }
}
