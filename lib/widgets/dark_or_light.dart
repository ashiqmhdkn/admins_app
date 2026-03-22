import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/theme/theme_state.dart';

class Darkorlight extends ConsumerWidget {
  const Darkorlight({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme.brightness == Brightness.dark;

    return IconButton(
      tooltip: 'Toggle Theme',
      icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
      onPressed: () async {
        await ref.read(themeProvider.notifier).toggleTheme();
      },
    );
  }
}
