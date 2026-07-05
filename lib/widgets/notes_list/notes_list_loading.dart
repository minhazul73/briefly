import 'package:flutter/material.dart';

/// Centered loading indicator shown while the notes stream delivers its
/// first event.
class NotesListLoading extends StatelessWidget {
  const NotesListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
