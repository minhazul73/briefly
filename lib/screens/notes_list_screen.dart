import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../utils/app_motion.dart';
import '../widgets/add_edit/note_form_field.dart';
import '../widgets/add_edit/save_button.dart';
import '../widgets/notes_list/empty_notes_view.dart';
import '../widgets/notes_list/note_card.dart';
import '../widgets/notes_list/notes_list_loading.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  void _openSheet(BuildContext context, {NoteModel? note}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _NoteSheet(existingNote: note),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
        heroTag: 'fab_new_note',
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          // Stream-level error toast
          if (provider.errorMessage != null && !provider.isSaving) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
              provider.clearError();
            });
          }

          final Widget body;
          if (provider.isLoading) {
            body = const NotesListLoading(key: ValueKey('loading'));
          } else if (provider.notes.isEmpty) {
            body = const EmptyNotesView(key: ValueKey('empty'));
          } else {
            body = _NotesList(
              key: const ValueKey('list'),
              notes: provider.notes,
              onEdit: (note) => _openSheet(context, note: note),
            );
          }

          return AnimatedSwitcher(
            duration: AppMotion.medium,
            switchInCurve: AppMotion.curve,
            switchOutCurve: AppMotion.curve,
            child: body,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Masonry grid
// ─────────────────────────────────────────────────────────────────────────────

class _NotesList extends StatelessWidget {
  const _NotesList({super.key, required this.notes, required this.onEdit});

  final List<NoteModel> notes;
  final void Function(NoteModel) onEdit;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 120),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          key: ValueKey(note.id),
          note: note,
          onTap: () => onEdit(note),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({this.existingNote});
  final NoteModel? existingNote;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingNote?.title ?? '');
    _descCtrl = TextEditingController(text: widget.existingNote?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<NotesProvider>();
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    final success = _isEditing
        ? await provider.updateNote(widget.existingNote!.id, title, desc)
        : await provider.addNote(title, desc);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Something went wrong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ─────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ── Header row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 8, 0),
            child: Row(
              children: [
                Text(
                  _isEditing ? 'Edit Note' : 'New Note',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // ── Form ────────────────────────────────────────────────────
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NoteFormField(
                    controller: _titleCtrl,
                    label: 'Title',
                    hint: 'Give your note a title',
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),
                  NoteFormField(
                    controller: _descCtrl,
                    label: 'Description',
                    hint: 'Write something…',
                    maxLines: 5,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  Selector<NotesProvider, bool>(
                    selector: (_, p) => p.isSaving,
                    builder: (_, isSaving, _) => SaveButton(
                      isSaving: isSaving,
                      onPressed: _save,
                      label: _isEditing ? 'Save Changes' : 'Add Note',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
