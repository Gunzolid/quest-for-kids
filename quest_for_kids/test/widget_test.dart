import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_for_kids/features/auth/presentation/login_screen.dart';
import 'package:quest_for_kids/main.dart';

void main() {
  testWidgets('App starts and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We must wrap the app in a ProviderScope because it uses Riverpod.
    await tester.pumpWidget(
      const ProviderScope(
        child: QuestForKidsApp(),
      ),
    );

    // Verify that the LoginScreen is displayed.
    expect(find.byType(LoginScreen), findsOneWidget);

    // Verify that the login buttons are present.
    expect(find.text('Login as Parent'), findsOneWidget);
    expect(find.text('Login as Child'), findsOneWidget);
  });
}
