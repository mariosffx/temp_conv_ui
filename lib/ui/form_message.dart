import 'package:flutter/material.dart';

enum MessageType { error, result }

class FormMessage extends StatelessWidget {
  final String? messageText;
  final MessageType? messageType;

  const FormMessage({
    super.key,
    required this.messageText,
    required this.messageType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: messageText != null
          ? Align(
              alignment: Alignment.topLeft,
              child: Text(
                messageText ?? "",
                style: messageType == MessageType.error
                    ? TextStyle(color: Theme.of(context).colorScheme.error)
                    : messageType == MessageType.result
                    ? TextStyle(color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            )
          : null,
    );
  }
}
