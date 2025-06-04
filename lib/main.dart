import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'design-system/colors.dart';
import 'design-system/text.dart';

import 'components/navbar.dart';
import 'components/block.dart';

import 'pages/add_entry.dart';
import 'pages/map.dart';
import 'pages/feed.dart';

void main() {
  runApp(const BlockTalkApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: 'home', // Optional, add name to your routes. Allows you navigate by name instead of path
      path: '/',
      pageBuilder: (context, state) => NoTransitionPage(child: FeedPage()),
    ),
    GoRoute(
      name: 'map',
      path: '/map',
      pageBuilder: (context, state) => NoTransitionPage(child: MapPage()),
    ),
    GoRoute(
      name: 'entry',
      path: '/entry',
      pageBuilder: (context, state) => NoTransitionPage(child: AddEntryPage()),
    ),
  ],
);


class BlockTalkApp extends StatelessWidget {
  const BlockTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

