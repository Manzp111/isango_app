import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/screens/auth/sign_in_screen.dart';

const _kTestSurface = Size(600, 1200);
const _signInRoute = '/sign-in-under-test';

Future<void> _setSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(_kTestSurface);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _hostApp({
  WidgetBuilder? signInBuilder,
  Map<String, WidgetBuilder> extraRoutes = const {},
}) {
  return MaterialApp(
    initialRoute: _signInRoute,
    routes: {
      _signInRoute: signInBuilder ?? (_) => const SignInScreen(),
      ...extraRoutes,
    },
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  group('SignInScreen', () {
    testWidgets('shows inline validation errors for empty fields', (
      tester,
    ) async {
      await _setSurface(tester);
      await tester.pumpWidget(_hostApp());

      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows email format error for malformed email', (tester) async {
      await _setSurface(tester);
      await tester.pumpWidget(_hostApp());

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('Sign up link navigates to /signup', (tester) async {
      await _setSurface(tester);
      await tester.pumpWidget(
        _hostApp(
          extraRoutes: {
            AppRoutes.signUp: (_) =>
                const Scaffold(body: Text('signup-route-marker')),
          },
        ),
      );

      await _tapVisible(tester, find.widgetWithText(TextButton, 'Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('signup-route-marker'), findsOneWidget);
    });

    testWidgets('shows visible loading state while auth hook is in flight', (
      tester,
    ) async {
      await _setSurface(tester);
      final completer = Completer<void>();
      Future<void> hook({
        required String email,
        required String password,
      }) {
        return completer.future;
      }

      await tester.pumpWidget(
        _hostApp(
          signInBuilder: (_) => SignInScreen(onSignIn: hook),
          extraRoutes: {
            AppRoutes.home: (_) => const Scaffold(body: Text('home-marker')),
          },
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'student@ur.ac.rw',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('home-marker'), findsOneWidget);
    });

    testWidgets('renders submission error when auth hook throws', (
      tester,
    ) async {
      await _setSurface(tester);
      Future<void> failingHook({
        required String email,
        required String password,
      }) async {
        throw const SignInException('Invalid credentials');
      }

      await tester.pumpWidget(
        _hostApp(signInBuilder: (_) => SignInScreen(onSignIn: failingHook)),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'student@ur.ac.rw',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
