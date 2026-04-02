import 'package:flutter/material.dart';

class BatchCourseCard extends StatelessWidget {
  final String title;
  final String backGroundImage;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const BatchCourseCard({
    super.key,
    required this.title,
    required this.backGroundImage,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 210,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(backGroundImage, fit: BoxFit.cover),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(icon: Icons.edit, onTap: onEdit),

                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.white.withOpacity(0.5),
                        ),

                        _buildActionButton(icon: Icons.delete, onTap: onDelete),

                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Icon(
                                isEnabled ? Icons.lock_open : Icons.lock,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Switch(
                                value: isEnabled,
                                onChanged: onToggle,
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 70,
                    padding: const EdgeInsets.fromLTRB(16, 26, 0, 16),
                    color: Colors.black.withOpacity(0.50),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
