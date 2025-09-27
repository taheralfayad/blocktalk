import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design-system/colors.dart';
import '../design-system/text.dart';
import '../design-system/pill.dart';
import '../design-system/vote_button.dart';
import '../design-system/textfield.dart';
import '../design-system/dropdown_button.dart';
import '../design-system/button.dart';

import '../components/navbar.dart';
import '../components/contributers_circle.dart';
import '../components/banner.dart';
import '../components/comment.dart';
import '../components/add_comment.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

import '../globals.dart' as globals;

class EntryPage extends ConsumerStatefulWidget {
  final String? blockId;
  const EntryPage({super.key, this.blockId});

  @override
  ConsumerState<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  String _content = "";
  String _title = "";
  int _upvotes = 0;
  int _downvotes = 0;
  String _userInteraction = "";
  List<Map<String, String>> _tags = [];
  String _selectedClassification = 'Opinion';
  List<dynamic>? _comments = [];
  bool _editMode = false;
  List<Map<String, String>> _selectedTags = [];
  String? _highlightedImprovementText;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _entryContentController = TextEditingController();
  final TextEditingController _entryTitleController = TextEditingController();

  final FocusNode commentFocusNode = FocusNode();

  Future<void> voteEntry(String interactionType) async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    AuthService authService = AuthService();
    String? accessToken;

    try {
      accessToken = await authService.getAccessToken();
    } catch (e) {
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
    } catch (e) {
      accessToken = null;
    }

    final response = await http.get(
      Uri.parse('$backendUrl/retrieve-entry?id=${widget.blockId}'),
      headers: {'Authorization': accessToken ?? ''},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> entryData = jsonDecode(response.body);
      print(entryData);
      setState(() {
        _title = entryData['title'] ?? '';
        _content = entryData['content'] ?? '';
        _upvotes = entryData['upvotes'] ?? 0;
        _tags = (entryData["tags"] as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
        _downvotes = entryData['downvotes'] ?? 0;
        _userInteraction = entryData['user_interaction'] ?? '';

        // Set the edit state variables as the original entry's information
        _entryTitleController.text = _title;
        _entryContentController.text = _content;
        _selectedTags = List<Map<String, String>>.from(_tags);
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
    } catch (e) {
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
        'text_to_improve': _highlightedImprovementText
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
    } catch (e) {
      accessToken = null;
      print("Error retrieving access token: $e");
      return;
    }

    final response = await http.get(
      Uri.parse('$backendUrl/retrieve-comments?entry_id=${widget.blockId}'),
      headers: {'Authorization': accessToken},
    );

    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic>? commentsData = jsonDecode(response.body);
      setState(() {
        _comments = commentsData;
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  void _onSelectedTag(value) {
    setState(() {
      Map<String, String> tag = globals.blockTalkTags.firstWhere(
        (t) => t["name"] == value,
      );

      _selectedTags.add(tag);
      _selectedTags.removeWhere(
        (t) =>
            t["name"] != tag["name"] &&
            t["classification"] == tag["classification"],
      );

      print(_selectedTags);
    });
  }

  void _setClassificationValue(value) {
      setState(() {
        _selectedClassification = value;
      });
  }

  void _setHighlightedImprovementText(value){
    setState(() {
      _highlightedImprovementText = value;
    });
  }

  void initState() {
    super.initState();

    print("Block ID: ${widget.blockId}");

    _retrieveEntry();
    _retrieveComments();
  }

  Future<void> _editEntry() async {
    String newTitle = _entryTitleController.text.trim();
    String newContent = _entryContentController.text.trim();

    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    if (newTitle.isEmpty || newContent.isEmpty || _selectedTags.isEmpty) {
      print(newTitle);
      print(newContent);
      print(_selectedTags);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('')));
    }

    print("EDITED CONTENT:");
    print(newTitle);
    print(newContent);
    print(_selectedTags);

    Uri url = Uri.parse('$backendUrl/edit-entry');

    final entryData = {
      'newTitle': newTitle,
      'newContent': newContent,
      'newTags': _selectedTags,
      "entryId": int.parse(widget.blockId!),
    };

    AuthService authService = AuthService();
    String? accessToken = await authService.getAccessToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken.toString(),
      },
      body: json.encode(entryData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Successfully edited entry')));

      setState(() {
        _retrieveEntry();
        _editMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ContributorsCircle(),
                              BlockTalkText(
                                text: "15 Contributors",
                                fontSize: 14.0,
                              ),
                            ],
                          ),
                          if (isAuthenticated)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _editMode = !_editMode;
                                  _entryContentController.text = _content;
                                  _entryTitleController.text = _title;
                                });
                              },
                              icon: const Icon(Icons.edit),
                              color: AppColors.primaryButtonColor,
                            ),
                        ],
                      ),
                      if (_editMode)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            BlockTalkDropdownButton(
                              items: globals.blockTalkTags
                                  .where(
                                    (tag) => tag["classification"] == 'Zoning',
                                  )
                                  .map((tag) => tag["name"].toString())
                                  .toList(),
                              onChanged: (value) {
                                _onSelectedTag(value);
                              },
                              currentChoice: _tags
                                  .firstWhere(
                                    (tag) => tag["classification"] == 'Zoning',
                                  )["name"]
                                  .toString(),
                              title: "Select Zoning Tag",
                            ),
                            SizedBox(height: 12),
                            BlockTalkDropdownButton(
                              items: globals.blockTalkTags
                                  .where(
                                    (tag) =>
                                        tag["classification"] == 'Progress',
                                  )
                                  .map((tag) => tag["name"].toString())
                                  .toList(),
                              onChanged: (value) {
                                _onSelectedTag(value);
                              },
                              currentChoice: _tags
                                  .firstWhere(
                                    (tag) =>
                                        tag["classification"] == 'Progress',
                                  )["name"]
                                  .toString(),
                              title: "Select Progress Tag",
                            ),
                            SizedBox(height: 12),
                            BlockTalkTextField(
                              controller: _entryTitleController,
                              labelText: "Edit your title",
                              maxLines: 1,
                            ),
                            SizedBox(height: 12),
                            BlockTalkTextField(
                              controller: _entryContentController,
                              labelText: "Edit your content",
                              maxLines: 15,
                            ),
                            SizedBox(height: 12),
                            BlockTalkButton(
                              text: "Edit Entry Content",
                              type: "outline",
                              onPressed: () => {_editEntry()},
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ..._tags.map(
                                    (tag) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0,
                                      ),
                                      child: BlockTalkPill(
                                        text: tag["name"]!,
                                        classification: tag["classification"]!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            BlockTalkText(text: _title, fontSize: 24.0),
                            SizedBox(height: 8),
                            BlockTalkText(
                              text: _content,
                              fontSize: 16.0,
                              isSelectable: true,
                              suggestImprovementFocusNode: commentFocusNode,
                              setClassificationValue: _setClassificationValue,
                              selectableCallback: _setHighlightedImprovementText
                            ),
                          ],
                        ),
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
                            icon: Icon(
                              Icons.arrow_upward_rounded,
                              color: _userInteraction == 'upvote'
                                  ? Colors.white
                                  : AppColors.primaryButtonColor,
                            ),
                          ),
                          VoteButton(
                            label: "Downvote",
                            votes: _downvotes,
                            hasAlreadyVoted: _userInteraction == 'downvote',
                            onPressed: (interactionType) {
                              voteEntry(interactionType.toLowerCase());
                            },
                            icon: Icon(
                              Icons.arrow_downward_rounded,
                              color: _userInteraction == 'downvote'
                                  ? Colors.white
                                  : AppColors.primaryButtonColor,
                            ),
                          ),
                        ],
                      ),
                      BlockTalkBanner(text: "Conversation"),
                      SizedBox(height: 12),
                      AddComment(
                        commentController: _commentController,
                        onSubmit: (comment, classification) {
                          if (comment.isNotEmpty) {
                            _addComment(comment, classification);
                            _commentController.clear();
                          }
                        },
                        onClassificationChanged: (value) {
                           _setClassificationValue(value);
                        },
                        disabled: !isAuthenticated,
                        focusNode: commentFocusNode,
                        selectedClassification: _selectedClassification,
                        commentClassifications: ['Opinion', 'Source', 'Improvement'],
                        highlightedText: _highlightedImprovementText
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _comments?.length ?? 0,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final comment = _comments?[index];
                          return Comment(
                            id: comment['id'] ?? 0,
                            entryId: int.parse(widget.blockId ?? '-1'),
                            parentId: null,
                            author: comment['username'] ?? 'Unknown',
                            text: comment['context'] ?? '',
                            classification: comment['type'] ?? 'opinion',
                            numOfReplies: comment['num_of_replies'] ?? 0,
                            textToImprove: comment['text_to_improve'],
                            addCommentIsDisabled: !isAuthenticated,
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