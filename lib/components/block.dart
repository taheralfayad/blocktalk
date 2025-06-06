import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design-system/colors.dart';
import '../design-system/text.dart';


class Block extends StatefulWidget {
  final String blockId;
  final String blockText;
  final String name;
  final String username;
  final String text;
  final int likes;
  final int comments;
  final int shares;
  final String imageUrl;

  const Block({
      super.key,
      required this.blockId, 
      required this.blockText,
      required this.name,
      required this.username,
      required this.text,
      required this.likes,
      required this.comments,
      required this.shares,
      required this.imageUrl,
    });

  @override
  State<Block> createState() => _BlockState();
}

class _BlockState extends State<Block> {
  int blockLikes = 50871;
  int comments = 1571;
  int shares = 1000;

  @override
  Widget build(BuildContext context) {
    return
     InkWell(
      onTap: () {
        context.goNamed(
          'entry',
          pathParameters: {'blockId': widget.blockId},
        );
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 16.0,
          right: 8.0,
          left: 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.blockColor,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(widget.imageUrl),
                ),
                SizedBox(width: 8,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlockTalkText(
                      text: widget.name,
                      fontWeight: FontWeight.bold,
                    ),
                    BlockTalkText(
                      text: "@" + widget.username,
                      fontSize: 14.0,
                    )
                  ]
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
                top: 12.0,
                ),
              child: BlockTalkText(
                text: widget.blockText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlockTalkText(
                  text: "${widget.likes} Likes",
                  fontSize: 14.0,
                ),
                BlockTalkText(
                  text: "${widget.comments} Comments",
                  fontSize: 14.0,
                ),
                BlockTalkText(
                  text: "${widget.shares} Shares",
                  fontSize: 14.0,
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}