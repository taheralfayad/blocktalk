import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../design-system/colors.dart';
import '../design-system/text.dart';
import '../design-system/pill.dart';

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
  List<String> _tags = [];

  Future<void> voteEntry(String interactionType) async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    AuthService authService = AuthService();

    String? accessToken = await authService.getAccessToken();

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

    final response = await http.get(
      Uri.parse('$backendUrl/retrieve-entry?id=${widget.blockId}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> entryData = jsonDecode(response.body);
      setState(() {
        _title = entryData['title'] ?? '';
        _content = entryData['content'] ?? '';
        _upvotes = entryData['upvotes'] ?? 0;
        _downvotes = entryData['downvotes'] ?? 0;
        _tags = List<String>.from(entryData['tags'] ?? []);
      });
    } else {
      throw Exception('Failed to load entry');
    }
  }

  void initState() {
    super.initState();
    _retrieveEntry();
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            label: Text("Upvote ($_upvotes)"),
                            icon: const Icon(Icons.arrow_upward_rounded),
                            onPressed: () {
                              voteEntry("upvote");
                            },
                          ),
                          TextButton.icon(
                            label: Text("Downvote ($_downvotes)"),
                            icon: Icon(Icons.arrow_downward_rounded),
                            onPressed: () {
                              voteEntry("downvote");
                            },
                          ),
                        ],
                      ),
                      BlockTalkBanner(text: "Conversation"),
                      SizedBox(height: 8),
                      AddComment(),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          if (index % 2 == 0) {
                            if (index == 2) {
                              return Comment(
                                text: "This is a comment to try out replies",
                                author: "@taher",
                                classification: "Conversation",
                                replies: [
                                  Comment(
                                    text:
                                        "This is a reply to the comment above",
                                    author: "@dgwn",
                                    classification: "Conversation",
                                    replies: [
                                      Comment(
                                        text:
                                            "This is a nested reply to the reply above",
                                        author: "@taher",
                                        classification: "Conversation",
                                        replies: [
                                          Comment(
                                            text:
                                                "This is a nested reply to the nested reply above",
                                            author: "@dgwn",
                                            classification: "Conversation",
                                            replies: [],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Comment(
                                    text:
                                        "This is another reply to the comment above",
                                    author: "@taher",
                                    classification: "Conversation",
                                  ),
                                ],
                              );
                            }
                            return Comment(
                              text:
                                  "This is a sample comment text for index $index. It can be a bit longer to simulate real comments.",
                              author: "@dgwn",
                              classification: "Source",
                            );
                          } else {
                            return Comment(
                              text:
                                  "This is another sample comment text for index $index. It can also be a bit longer to simulate real comments.",
                              author: "@taher",
                              classification: "Conversation",
                            );
                          }
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
