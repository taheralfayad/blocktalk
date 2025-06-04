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
    return Container (
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
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
                      likes: 50871,
                      comments: 1571,
                      shares: 1000,
                      imageUrl: "assets/avatar.jpg",
                    );
                  },
                ),
              ),
            Navbar(selectedIndex: 0),
          ]
        )
      )
    );
  }
}