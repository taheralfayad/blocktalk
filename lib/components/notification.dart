import 'package:flutter/material.dart';

class BlockTalkNotification extends StatelessWidget {
  final String message;
  final Color color;

  const BlockTalkNotification({required this.message, this.color = Colors.red});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
