import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/screens/auth/sign_up_screen.dart';

const _kTestSurface = Size(600, 1400);
const _signUpRoute = '/sign-up-under-test';

Future<void> _setSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(_kTestSurface);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _hostApp({
  WidgetBuilder? signUpBuilder,
  Map<String, WidgetBuilder> extraRoutes = const {},
}) {
  return MaterialApp(
    initialRoute: _signUpRoute,
    routes: {
      _signUpRoute: signUpBuilder ?? (_) => const SignUpScreen(),
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
  group('SignUpScreen', () {
    testWidgets('shows required-field errors when submitting empty form', (
      tester,
    ) async {
      await _setSurface(tester);
      await tester.pumpWidget(_hostApp());

      await _tapVisible(
        tester,
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.pump();

      expect(find.text('Display name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('shows password mismatch error when confirmation differs', (
      tester,
    ) async {
      await _setSurface(tester);
      await tester.pumpWidget(_hostApp());

      await tester.enterText(find.byType(TextFormField).at(0), 'Ada Lovelace');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'student@ur.ac.rw',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
      await tester.enterText(find.byType(TextFormField).at(3), 'different456');

      await _tapVisible(
        tester,
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Sign in link navigates to /login', (tester) async {
      await _setSurface(tester);
      await tester.pumpWidget(
        _hostApp(
          extraRoutes: {
            AppRoutes.login: (_) =>
                const Scaffold(body: Text('login-route-marker')),
          },
        ),
      );

      await _tapVisible(tester, find.widgetWithText(TextButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('login-route-marker'), findsOneWidget);
    });
  });
}
