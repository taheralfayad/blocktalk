import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/add_entry.dart';
import 'pages/map.dart';
import 'pages/feed.dart';
import 'pages/entry.dart';

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
      name: 'add_entry',
      path: '/add_entry',
      pageBuilder: (context, state) => NoTransitionPage(child: AddEntryPage()),
    ),
    GoRoute(
      name: 'entry',
      path: '/entry/:blockId',
      pageBuilder: (context, state) {
         final String? blockId = state.pathParameters['blockId'];
         return NoTransitionPage(child: EntryPage(blockId: blockId));
      }
    )
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

