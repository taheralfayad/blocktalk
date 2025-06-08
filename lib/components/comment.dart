import 'package:flutter/material.dart';

import '../design-system/text.dart';


class Comment extends StatelessWidget {
  final String text;
  final String author;
  final String classification;
  final String avatarUrl;

  const Comment({
    super.key,
    required this.text,
    required this.author,
    required this.classification,
    this.avatarUrl = 'assets/avatar.jpg',
  });


  @override
  Widget build(BuildContext context) {
    return Container (
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                    ),
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundImage: AssetImage(avatarUrl),
                    )
                  ),
                  BlockTalkText(
                    text: author,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: BlockTalkText(
                  text: classification,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 12.0,
              bottom: 8.0,
            ),
            child: BlockTalkText(
              text: text,
              fontSize: 16.0,
            ),
          ),
        ]
      )
    );
  }
}