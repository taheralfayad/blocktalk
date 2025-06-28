import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

import 'pages/add_entry.dart';
import 'pages/map.dart';
import 'pages/feed.dart';
import 'pages/entry.dart';
import 'pages/login.dart';
import 'pages/user.dart';

void main() {
  runApp(ProviderScope(child: BlockTalkApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name:
          'home', // Optional, add name to your routes. Allows you navigate by name instead of path
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
      },
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      pageBuilder: (context, state) => NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      name: 'user',
      path: '/user',
      pageBuilder: (context, state) => NoTransitionPage(child: UserPage()),
    )
  ],
);

class BlockTalkApp extends ConsumerStatefulWidget {
  const BlockTalkApp({super.key});

  @override
  ConsumerState<BlockTalkApp> createState() => _BlockTalkAppState();
}

class _BlockTalkAppState extends ConsumerState<BlockTalkApp> {
  @override
  void initState() {
    AuthService authService = AuthService();
    _checkAuthentication(ref);
  }

  void _checkAuthentication(WidgetRef ref) async {
    String? refreshToken = await AuthService().getRefreshToken();

    print("Refresh tok from checkAuth" + refreshToken.toString());

    if (refreshToken == null || refreshToken.isEmpty) {
      ref.read(isAuthenticatedProvider.notifier).state = false;
    } else {
      await AuthService().getAccessToken();
      ref.read(isAuthenticatedProvider.notifier).state = true;
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
