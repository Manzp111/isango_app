import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/widgets/auth/auth_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Form(child: child)),
    );

Color? _labelColorOf(WidgetTester tester, String label) {
  final widget = tester.widget<Text>(find.text(label));
  return widget.style?.color;
}

Finder _errorIconFor(String fieldLabel) {
  // The custom error icon lives inside the field whose label matches.
  return find.descendant(
    of: find.ancestor(
      of: find.text(fieldLabel),
      matching: find.byType(Column),
    ),
    matching: find.byWidgetPredicate(
      (w) =>
          w is Icon &&
          w.icon == Icons.error &&
          w.color == AppColors.criticalRed,
    ),
  );
}

void main() {
  group('AuthTextField — per-field reactive validation', () {
    testWidgets('initial state: no error, label is dark', (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(_wrap(
        AuthTextField(
          controller: c,
          label: 'Email',
          icon: Icons.mail_outline,
          validator: (v) => (v == null || v.isEmpty) ? 'required' : null,
        ),
      ));

      expect(_labelColorOf(tester, 'Email'), AppColors.nearBlackInk);
      expect(_errorIconFor('Email'), findsNothing);
    });

    testWidgets('typing invalid input turns label red and shows error icon',
        (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(_wrap(
        AuthTextField(
          controller: c,
          label: 'Email',
          icon: Icons.mail_outline,
          validator: (v) =>
              (v != null && v.contains('@')) ? null : 'invalid',
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(_labelColorOf(tester, 'Email'), AppColors.criticalRed);
      expect(_errorIconFor('Email'), findsOneWidget);
    });

    testWidgets('valid input clears the error visuals', (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(_wrap(
        AuthTextField(
          controller: c,
          label: 'Email',
          icon: Icons.mail_outline,
          validator: (v) =>
              (v != null && v.contains('@')) ? null : 'invalid',
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();
      expect(_labelColorOf(tester, 'Email'), AppColors.criticalRed);

      await tester.enterText(find.byType(TextFormField), 'a@b.c');
      await tester.pump();
      expect(_labelColorOf(tester, 'Email'), AppColors.nearBlackInk);
      expect(_errorIconFor('Email'), findsNothing);
    });

    testWidgets(
      'revalidateOn does NOT paint the field until the user has typed in it',
      (tester) async {
        final pwd = TextEditingController();
        final confirm = TextEditingController();

        await tester.pumpWidget(_wrap(
          AuthTextField(
            controller: confirm,
            label: 'Confirm Password',
            icon: Icons.lock_outline,
            revalidateOn: pwd,
            validator: (v) => v == pwd.text ? null : 'mismatch',
          ),
        ));

        // Password changes — confirm hasn't been typed in yet.
        pwd.text = 'abcd1234';
        await tester.pump();

        expect(
          _labelColorOf(tester, 'Confirm Password'),
          AppColors.nearBlackInk,
        );
        expect(_errorIconFor('Confirm Password'), findsNothing);
      },
    );

    testWidgets(
      'revalidateOn DOES update the field once the user has typed in it',
      (tester) async {
        final pwd = TextEditingController(text: 'abcd1234');
        final confirm = TextEditingController();

        await tester.pumpWidget(_wrap(
          AuthTextField(
            controller: confirm,
            label: 'Confirm Password',
            icon: Icons.lock_outline,
            revalidateOn: pwd,
            validator: (v) => v == pwd.text ? null : 'mismatch',
          ),
        ));

        // User types matching value first — no error.
        await tester.enterText(find.byType(TextFormField), 'abcd1234');
        await tester.pump();
        expect(
          _labelColorOf(tester, 'Confirm Password'),
          AppColors.nearBlackInk,
        );

        // Password changes — confirm should now show mismatch.
        pwd.text = 'something_else';
        await tester.pump();

        expect(
          _labelColorOf(tester, 'Confirm Password'),
          AppColors.criticalRed,
        );
        expect(_errorIconFor('Confirm Password'), findsOneWidget);
      },
    );
  });
}
