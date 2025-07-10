import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/navbar.dart';
import '../components/block.dart';
import '../components/carousel.dart';
import '../components/location_items.dart';

import '../design-system/colors.dart';
import '../design-system/text.dart';
import '../design-system/button.dart';

import '../services/auth_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  List<Widget> _buildBlockCarouselItems() {
    return [
      Block(
        blockId: "block_1",
        blockText: "This is a sample block text.",
        name: "User 1",
        username: "user_1",
        text: "This is some sample text for block 1.",
        upvotes: 50871,
        downvotes: 1571,
        conversations: 1000,
        imageUrl: "assets/avatar.jpg",
      ),
      Block(
        blockId: "block_2",
        blockText: "This is another sample block text.",
        name: "User 2",
        username: "user_2",
        text: "This is some sample text for block 2.",
        upvotes: 30000,
        downvotes: 500,
        conversations: 500,
        imageUrl: "assets/avatar.jpg",
      ),
    ];
  }


  List<Widget> _buildActiveLocationsCarousel() {
    return [
      LocationDisplay(
        locationName: "Orlando, FL",
      ),
      LocationDisplay(
        locationName: "Seattle, WA",
      ),
      LocationDisplay(
        locationName: "Minneapolis, MN",
      ),
    ];
  }

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/avatar.jpg'),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'taheralfayad',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    BlockTalkText(
                      text: 'Your most recent contributions',
                      fontSize: 20,
                    ),
                    SizedBox(height: 16),
                    Carousel(
                      items: _buildBlockCarouselItems(),
                      height: 160,
                    ),
                    SizedBox(height: 16),

                    Center(
                      child: BlockTalkButton(
                        text: 'Add New Entry',
                        type: "solid",
                        onPressed: () {
                          context.go('/add_entry');
                        },
                      ),
                    ),
                    SizedBox(height: 24),

                    BlockTalkText(
                      text: 'Your Recent Activity',
                      fontSize: 20,
                    ),
                    SizedBox(height: 8),
                    BlockTalkText(
                      text: 'Your entries: 25',
                      fontSize: 16,
                    ),
                    SizedBox(height: 8),
                    BlockTalkText(
                      text: 'Contributions to conversation: 15',
                      fontSize: 16,
                    ),
                    SizedBox(height: 8),
                    BlockTalkText(
                      text: 'Views on entries you contributed to: 5000',
                    ),
                    SizedBox(height: 24),

                    BlockTalkText(
                      text: 'You are primarily active in the following areas:',
                      fontSize: 20,
                    ),
                    SizedBox(height: 16),
                    Carousel(
                      items: _buildActiveLocationsCarousel(),
                      height: 120,
                      viewportFraction: 0.6,
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: BlockTalkButton(
                        text: 'Sign Out',
                        type: "solid",
                        onPressed: () {
                          AuthService().logOut();
                          context.go('/login');
                        }
                      )
                    )
                  ],
                ),
              ),
            ),
            Navbar(selectedIndex: 3),
          ],
        ),
      ),
    ),
  );
}

}
