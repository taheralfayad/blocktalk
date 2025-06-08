import 'package:flutter/material.dart';

import '../design-system/button.dart';

class AddComment extends StatefulWidget {
  const AddComment({super.key});

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 200.0,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                ),
            ),
            SizedBox(height: 8.0),
            BlockTalkButton(
              text: 'Submit',
              type: "solid",
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  // Handle comment submission logic here
                  print('Comment submitted: ${_commentController.text}');
                  _commentController.clear();
                }
              },
            ),
          ],
        ),
      );
  }
}