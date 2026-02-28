import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool loading;
  final String text;

  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.primaryContainer,
        ),
        foregroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }
}
