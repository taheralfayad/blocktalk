import 'package:flutter/material.dart';

import '../design-system/colors.dart';
import '../design-system/text.dart';

import '../components/block.dart';
import '../components/navbar.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Block(
                      blockId: "block_$index",
                      blockText: "This is a sample block text for index $index",
                      name: "User $index",
                      username: "user_$index",
                      text: "This is some sample text for block $index.",
                      upvotes: 50871,
                      downvotes: 1571,
                      conversations: 1000,
                      imageUrl: "assets/avatar.jpg",
                    );
                  },
                ),
              ),
              Navbar(selectedIndex: 0),
            ],
          ),
        ),
      ),
    );
  }
}
