import 'package:flutter/material.dart';

import '../design-system/text.dart';

import '../components/add_comment.dart';

class Comment extends StatefulWidget {
  final String text;
  final String author;
  final String classification;
  final String avatarUrl;
  final List<Comment> replies;

  const Comment({
    super.key,
    required this.text,
    required this.author,
    required this.classification,
    this.avatarUrl = 'assets/avatar.jpg',
    this.replies = const [],
  });

  @override
  State<Comment> createState() => _CommentState();
}


class _CommentState extends State<Comment> {
  bool _repliesIsExpanded = false;
  bool _addReplyIsExpanded = false;


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
                      backgroundImage: AssetImage(widget.avatarUrl),
                    )
                  ),
                  BlockTalkText(
                    text: widget.author,
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
                  text: widget.classification,
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
              text: widget.text,
              fontSize: 16.0,
            ),
          ),
          if (widget.classification == 'Conversation') 
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _addReplyIsExpanded = !_addReplyIsExpanded;
                    });
                  },
                  icon: const Icon(Icons.reply, size: 16.0),
                  label: const Text('Reply'),
                ),
                const SizedBox(width: 8.0),
                TextButton.icon(
                onPressed: () {
                  setState(() {
                      _repliesIsExpanded = !_repliesIsExpanded;
                    });
                  },
                  icon: const Icon(Icons.chat, size: 16.0),
                  label: Text('Replies (${widget.replies.length})'),
                ),
              ]
            ),
          if (widget.replies.isNotEmpty && _repliesIsExpanded) 
            ...widget.replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child:
                 Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Comment(
                        text: reply.text,
                        author: reply.author,
                        classification: reply.classification,
                        avatarUrl: reply.avatarUrl,
                        replies: reply.replies,
                      )
                    ),
                  ],
                  )
              )
            ),
          if (widget.classification == 'Conversation' && _addReplyIsExpanded)
            AddComment(
              avatarUrl: widget.avatarUrl,
              withClassification: false,
              placeholderText: 'Add a reply...',
            )
        ]
      )
    );
  }
}