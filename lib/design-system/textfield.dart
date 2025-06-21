import 'package:flutter/material.dart';

class BlockTalkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const BlockTalkTextField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }
}
