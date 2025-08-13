import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../design-system/colors.dart';
import '../design-system/text.dart';
import '../design-system/pill.dart';
import '../design-system/vote_button.dart';

import '../components/navbar.dart';
import '../components/contributers_circle.dart';
import '../components/banner.dart';
import '../components/comment.dart';
import '../components/add_comment.dart';

import '../services/auth_service.dart';

class EntryPage extends StatefulWidget {
  final String? blockId;
  const EntryPage({super.key, this.blockId});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  String _content = "";
  String _title = "";
  int _upvotes = 0;
  int _downvotes = 0;
  String _userInteraction = "";
  List<String> _tags = [];
  String _selectedClassification = 'Opinion';
  List<dynamic> _comments = [];

  final TextEditingController _commentController = TextEditingController();

  Future<void> voteEntry(String interactionType) async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    AuthService authService = AuthService();
    String? accessToken;

    try{
       accessToken = await authService.getAccessToken();
    }
    catch (e) {
      print("Error retrieving access token: $e");
      return;
    }

    final response = await http.post(
      Uri.parse('$backendUrl/vote-entry'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken.toString(),
      },
      body: jsonEncode({
        'entry_id': widget.blockId,
        'interaction_type': interactionType,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      setState(() {
        _upvotes = responseData['upvotes'] ?? _upvotes;
        _downvotes = responseData['downvotes'] ?? _downvotes;
        _userInteraction = responseData['user_interaction'] ?? '';
      });
    } else {
      throw Exception('Failed to vote entry');
    }

  }

  Future<void> _retrieveEntry() async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );
    String? accessToken;

    try {
      accessToken = await AuthService().getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }
    }
    catch (e) {accessToken = null;}

    final response = await http.get(
      Uri.parse('$backendUrl/retrieve-entry?id=${widget.blockId}'),
      headers: {
        'Authorization': accessToken ?? '',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> entryData = jsonDecode(response.body);
      setState(() {
        _title = entryData['title'] ?? '';
        _content = entryData['content'] ?? '';
        _upvotes = entryData['upvotes'] ?? 0;
        _downvotes = entryData['downvotes'] ?? 0;
        _tags = List<String>.from(entryData['tags'] ?? []);
        _userInteraction = entryData['user_interaction'] ?? '';
      });
    } else {
      throw Exception('Failed to load entry');
    }
  }

  Future<void> _addComment(String comment, String classification) async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:8080',
    );
    String? accessToken;

    try {
      accessToken = await AuthService().getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }
    }
    catch (e) {
      accessToken = null;
      print("Error retrieving access token: $e");
      return;
    }

    final response = await http.post(
      Uri.parse('$backendUrl/add-comment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
      body: jsonEncode({
        'entry_id': int.parse(widget.blockId ?? '-1'),
        'context': comment,
        'classification': classification.toLowerCase(),
      }),
    );

    if (response.statusCode == 201) {
      print('Comment added successfully');
    } else {
      print('Failed to add comment: ${response.body}');
      throw Exception('Failed to add comment');
    }
  }

  Future<void> _retrieveComments() async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );
    String? accessToken;

    try {
      accessToken = await AuthService().getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }
    }
    catch (e) {
      accessToken = null;
      print("Error retrieving access token: $e");
      return;
    }

    final response = await http.get(
      Uri.parse('$backendUrl/retrieve-comments?entry_id=${widget.blockId}'),
      headers: {
        'Authorization': accessToken,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> commentsData = jsonDecode(response.body);
      setState(() {
        _comments = commentsData;
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  void initState() {
    super.initState();

    print("Block ID: ${widget.blockId}");

    _retrieveEntry();
    _retrieveComments();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                top: true,
                bottom: false,
                left: false,
                right: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ContributorsCircle(),
                          BlockTalkText(
                            text: "15 Contributors",
                            fontSize: 14.0,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ..._tags.map((tag) => BlockTalkPill(text: tag)),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      BlockTalkText(text: _title, fontSize: 24.0),
                      SizedBox(height: 8),
                      BlockTalkText(text: _content, fontSize: 16.0),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          VoteButton(
                            label: "Upvote",
                            votes: _upvotes,
                            hasAlreadyVoted: _userInteraction == 'upvote',
                            onPressed: (interactionType) {
                              voteEntry(interactionType.toLowerCase());
                            },
                            icon: Icon(Icons.arrow_upward_rounded, color: _userInteraction == 'upvote' ? Colors.white : AppColors.primaryButtonColor),
                          ),
                          VoteButton(
                            label: "Downvote",
                            votes: _downvotes,
                            hasAlreadyVoted: _userInteraction == 'downvote',
                            onPressed: (interactionType) {
                              voteEntry(interactionType.toLowerCase());
                            },
                            icon: Icon(Icons.arrow_downward_rounded, color: _userInteraction == 'downvote' ? Colors.white : AppColors.primaryButtonColor),
                          ),
                        ],
                      ),
                      BlockTalkBanner(text: "Conversation"),
                      SizedBox(height: 8),
                      AddComment(
                        commentController: _commentController,
                        onSubmit: (comment, classification) {
                          if (comment.isNotEmpty) {
                            _addComment(comment, classification);
                            _commentController.clear();
                          }
                        },
                        initialClassification: _selectedClassification,
                        onClassificationChanged: (value) {
                          setState(() {
                            _selectedClassification = value;
                          });
                        },
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: _comments.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return Comment(
                              id: comment['id'] ?? 0,
                              entryId: int.parse(widget.blockId ?? '-1'),
                              parentId: null,
                              author: comment['username'] ?? 'Unknown',
                              text: comment['context'] ?? '',
                              classification: comment['type'] ?? 'opinion',
                              numOfReplies: comment['num_of_replies'] ?? 0,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Navbar(selectedIndex: 0),
          ],
        ),
      ),
    );
  }
}
