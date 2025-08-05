import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design-system/colors.dart';
import '../design-system/text.dart';


class Block extends StatefulWidget {
  final int blockId;
  final String blockText;
  final String name;
  final String username;
  final int upvotes;
  final int downvotes;
  final int conversations;
  final String imageUrl;

  const Block({
      super.key,
      required this.blockId, 
      required this.blockText,
      required this.name,
      required this.username,
      required this.upvotes,
      required this.downvotes,
      required this.conversations,
      required this.imageUrl,
    });

  @override
  State<Block> createState() => _BlockState();
}

class _BlockState extends State<Block> {

  @override
  Widget build(BuildContext context) {
    return
     InkWell(
      onTap: () {
        context.goNamed(
          'entry',
          pathParameters: {'blockId': widget.blockId.toString()},
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
                  text: "${widget.upvotes} Upvotes",
                  fontSize: 14.0,
                ),
                BlockTalkText(
                  text: "${widget.downvotes} Downvotes",
                  fontSize: 14.0,
                ),
                BlockTalkText(
                  text: "${widget.conversations} Conversations",
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