import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter fakeNewEntryRouter(Widget formWidget) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, state) => formWidget, // your creation form
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const Scaffold(
          body: Center(child: Text('Fake Home Screen')),
        ),
      ),
    ],
  );
}

GoRouter fakeEditEntryRouter(Widget rootWidget) {
  return GoRouter(
    initialLocation: '/dummy',
    routes: [
      GoRoute(
        path: '/dummy',
        builder: (ctx, state) => Scaffold(
          body: Center(
            child: ElevatedButton(
              // For the test to push /edit
              onPressed: () {
                ctx.push('/edit');
              },
              child: const Text('Go to Edit Screen'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/edit',
        builder: (ctx, state) => rootWidget,
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const Scaffold(
          body: Center(child: Text('Fake Home Screen')),
        ),
      ),
    ],
  );
}

GoRouter fakeDetailRouter(Widget detailWidget) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, state) => detailWidget,
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const Scaffold(
          body: Center(child: Text('Fake Home Screen')),
        ),
      ),
    ],
  );
}
