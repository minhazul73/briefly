import 'package:flutter/material.dart';
import '../../utils/app_motion.dart';

/// Shown when the notes collection is confirmed empty (not during loading).
class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppMotion.medium,
      curve: AppMotion.curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 72,
              color: cs.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add one',
              style: tt.bodyMedium?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}
