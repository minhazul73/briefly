import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../../utils/date_time_helper.dart';
import '../../utils/app_motion.dart';
import '../common/confirm_delete_dialog.dart';

/// Grid-friendly note card.
///
/// - Sizes itself to content (masonry layout).
/// - Capped at [_maxHeight] so no card dominates the grid.
/// - Delete via icon (swipe-to-delete omitted — awkward in a 2-col grid).
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  static const double _maxHeight = 210;

  final NoteModel note;
  final VoidCallback onTap;

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showConfirmDeleteDialog(context);
    if (!confirmed || !context.mounted) return;

    final provider = context.read<NotesProvider>();
    final success = await provider.deleteNote(note.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Note deleted.'
              : (provider.errorMessage ?? 'Delete failed.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppMotion.medium,
      curve: AppMotion.curve,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: ConstrainedBox(
        // Content-driven height, but never taller than _maxHeight.
        constraints: const BoxConstraints(maxHeight: _maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.15),
              width: 2.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              splashColor: cs.primary.withValues(alpha: 0.08),
              highlightColor: cs.primary.withValues(alpha: 0.04),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 13, 10, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title — up to 2 lines
                      Text(
                        note.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Description — shown if present, up to 5 lines
                      if (note.description.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          note.description,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.45,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Footer: timestamp + delete icon
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 11,
                            color: cs.primary.withValues(alpha: 0.65),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              DateTimeHelper.timeAgo(note.updatedAt),
                              style: tt.labelSmall?.copyWith(
                                fontSize: 10.5,
                                color: cs.primary.withValues(alpha: 0.65),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _handleDelete(context),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: cs.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
