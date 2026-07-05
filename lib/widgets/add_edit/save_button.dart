import 'package:flutter/material.dart';
import '../../utils/app_motion.dart';

/// Save button that swaps its label for a spinner while [isSaving] is true,
/// and is fully disabled (not just visually) during that period.
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
    this.label = 'Save',
  });

  final bool isSaving;
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSaving ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.fast,
        switchInCurve: AppMotion.curve,
        switchOutCurve: AppMotion.curve,
        child: isSaving
            ? const SizedBox(
                key: ValueKey('spinner'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                key: const ValueKey('label'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
