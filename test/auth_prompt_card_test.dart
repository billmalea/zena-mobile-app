import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/chat/tool_cards/auth_prompt_card.dart';

void main() {
  group('AuthPromptCard', () {
    testWidgets('renders basic auth prompt', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPromptCard(
              message: 'Please sign in to save properties',
              onSignIn: () {},
              onSignUp: () {},
            ),
          ),
        ),
      );

      expect(find.text('Authentication Required'), findsOneWidget);
      expect(find.text('Please sign in to save properties'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Benefits of having an account:'), findsOneWidget);
    });

    testWidgets('sign in button triggers callback', (WidgetTester tester) async {
      bool signInCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPromptCard(
              message: 'Test message',
              onSignIn: () {
                signInCalled = true;
              },
              onSignUp: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(signInCalled, true);
    });

    testWidgets('sign up button triggers callback', (WidgetTester tester) async {
      bool signUpCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPromptCard(
              message: 'Test message',
              onSignIn: () {},
              onSignUp: () {
                signUpCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(signUpCalled, true);
    });

    testWidgets('shows continue as guest button when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPromptCard(
              message: 'Test message',
              onSignIn: () {},
              onSignUp: () {},
              onContinueAsGuest: () {},
            ),
          ),
        ),
      );

      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('hides continue as guest button when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPromptCard(
              message: 'Test message',
              onSignIn: () {},
              onSignUp: () {},
            ),
          ),
        ),
      );

      expect(find.text('Continue as Guest'), findsNothing);
    });

    testWidgets('continue as guest button triggers callback', (WidgetTester tester) async {
      bool guestCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPromptCard(
              message: 'Test message',
              onSignIn: () {},
              onSignUp: () {},
              onContinueAsGuest: () {
                guestCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continue as Guest'));
      await tester.pump();

      expect(guestCalled, true);
    });

    testWidgets('displays all benefit items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPromptCard(
              message: 'Test message',
              onSignIn: () {},
              onSignUp: () {},
            ),
          ),
        ),
      );

      expect(find.text('Save your favorite properties'), findsOneWidget);
      expect(find.text('Track your search history'), findsOneWidget);
      expect(find.text('Get notified about new listings'), findsOneWidget);
      expect(find.text('Manage payments and commissions'), findsOneWidget);
    });

    testWidgets('displays security message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPromptCard(
              message: 'Test message',
              onSignIn: () {},
              onSignUp: () {},
            ),
          ),
        ),
      );

      expect(find.text('Your data is secure and protected'), findsOneWidget);
    });
  });
}
