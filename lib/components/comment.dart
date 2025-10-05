import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../design-system/text.dart';
import '../design-system/blockquote.dart';

import '../components/add_comment.dart';

import '../services/auth_service.dart';

class Comment extends StatefulWidget {
  final int id;
  final int? parentId; // Optional parent ID for nested comments
  final int entryId;
  final int numOfReplies;
  final String text;
  final String author;
  final String classification;
  final String avatarUrl;
  final String? textToImprove; // only if the classification is "Improvement"
  final bool addCommentIsDisabled;

  const Comment({
    super.key,
    required this.id,
    required this.text,
    required this.entryId,
    required this.author,
    required this.classification,
    required this.addCommentIsDisabled,
    this.avatarUrl = 'assets/avatar.jpg',
    this.textToImprove,
    this.parentId,
    this.numOfReplies = 0,
  });

  @override
  State<Comment> createState() => _CommentState();
}


class _CommentState extends State<Comment> {
  final ValueNotifier<bool> _repliesIsExpanded = ValueNotifier<bool>(false);
  bool _addReplyIsExpanded = false;
  late int _repliesCount;

  List<Comment> replies = [];

  Future<void> fetchReplies() async {
    const backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8080');

    final response = await http.get(
      Uri.parse('$backendUrl/retrieve-comment-replies?comment_id=${widget.id}&entry_id=${widget.entryId}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      print('Fetched replies: $data');

      setState(() {
        replies = data.map((reply) => Comment(
          id: reply['id'],
          entryId: widget.entryId,
          text: reply['context'],
          parentId: widget.id,
          author: reply['username'],
          classification: reply['type'],
          numOfReplies: reply['num_of_replies'] ?? 0,
          addCommentIsDisabled: widget.addCommentIsDisabled
        )).toList();

        _repliesCount = replies.length;
      });
    }
    else {
      print('Failed to fetch replies: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch replies');
    }

  }

  Future<void> addReply(String replyText, String classification) async {
    const backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8080');

    AuthService authService = AuthService();
    String? accessToken;

    try {
      accessToken = await authService.getAccessToken();
    }
    catch (e) {
      print('Error fetching access token: $e');
      return;
    }

    final response = await http.post(
      Uri.parse('$backendUrl/add-comment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken.toString(),
      },
      body: jsonEncode({
        'entry_id': widget.entryId,
        'parent_id': widget.id ?? null,
        'context': replyText,
        'classification': classification.toLowerCase(),
      }),
    );

    if (response.statusCode == 201) {
      print('Reply added successfully: ${response.body}');
      final Map<String, dynamic> data = jsonDecode(response.body);

      final newReply = Comment(
        id: data['id'],
        author: data['username'] ?? 'Unknown',
        text: data['context'] ?? '',
        classification: data['type'] ?? 'opinion',
        avatarUrl: widget.avatarUrl,
        entryId: data['entry_id'],
        numOfReplies: data['num_of_replies'] ?? 0,
        addCommentIsDisabled: widget.addCommentIsDisabled 
      );

      setState(() {
        replies.add(newReply);

        _repliesCount++;
      });

    }
    else {
      print('Failed to add reply: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to add reply');
    }
  }

  @override
  void initState() {
    super.initState();

    _repliesCount = widget.numOfReplies;

    _repliesIsExpanded.addListener(() {
      print("Replies expanded: ${_repliesIsExpanded.value}");
      if (_repliesIsExpanded.value && replies.isEmpty) {
        fetchReplies();
      }
    });
  }

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
          if (widget.classification == 'opinion') 
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
                    _repliesIsExpanded.value = !_repliesIsExpanded.value;
                    });
                  },
                  icon: const Icon(Icons.chat, size: 16.0),
                  label: Text('Replies ($_repliesCount)'),
                ),
              ]
            ),
          if (replies.isNotEmpty && _repliesIsExpanded.value) 
            ...replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child:
                 Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Comment(
                        id: reply.id,
                        text: reply.text,
                        author: reply.author,
                        classification: reply.classification,
                        avatarUrl: reply.avatarUrl,
                        entryId: widget.entryId,
                        numOfReplies: reply.numOfReplies,
                        addCommentIsDisabled : widget.addCommentIsDisabled
                      )
                    ),
                  ],
                  )
              )
            ),
          if (widget.classification == 'opinion' && _addReplyIsExpanded)
            AddComment(
              avatarUrl: widget.avatarUrl,
              withClassification: false,
              placeholderText: 'Add a reply...',
              commentController: TextEditingController(),
              onSubmit: (String replyText, String classification) {
                addReply(replyText, classification);
                setState(() {
                  _repliesIsExpanded.value = true;
                  _addReplyIsExpanded = false;
                });
              },
              disabled: widget.addCommentIsDisabled
            )
        ]
      )
    );
  }
}