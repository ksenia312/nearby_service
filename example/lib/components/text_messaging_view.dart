import 'package:flutter/material.dart';

class TextMessagingView extends StatefulWidget {
  const TextMessagingView({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<TextMessagingView> createState() => _TextMessagingViewState();
}

class _TextMessagingViewState extends State<TextMessagingView> {
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: (value) => setState(() => _message = value),
          decoration: const InputDecoration(
            hintText: 'Enter your message',
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => widget.onSend(_message),
          child: const Text('Send message'),
        ),
      ],
    );
  }
}
