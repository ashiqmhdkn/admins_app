import 'package:flutter/material.dart';

class EditBatchCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onGenerate;

  const EditBatchCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(image, fit: BoxFit.fill),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          circleActionButton(
                            icon: Icons.edit,
                            onTap: onEdit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          circleActionButton(
                            icon: Icons.delete,
                            onTap: onDelete,
                            color: Colors.red,
                          ),

                          circleActionButton(
                            icon: Icons.sports_handball,
                            onTap: onGenerate,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget circleActionButton({
  required IconData icon,
  required VoidCallback onTap,
  required Color color,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.92),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    ),
  );
}
