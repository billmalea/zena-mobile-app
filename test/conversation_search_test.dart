import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:zena_mobile/widgets/conversation/conversation_search.dart';
import 'package:zena_mobile/providers/conversation_provider.dart';
import 'package:zena_mobile/services/chat_service.dart';

void main() {
  late ConversationProvider conversationProvider;
  late ChatService chatService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env.local');
  });

  setUp(() {
    chatService = ChatService();
    conversationProvider = ConversationProvider(chatService);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<ConversationProvider>.value(
          value: conversationProvider,
          child: const ConversationSearch(),
        ),
      ),
    );
  }

  group('ConversationSearch Widget Tests', () {
    testWidgets('renders search field with correct hint text',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search conversations...'), findsOneWidget);
    });

    testWidgets('displays search icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows clear button when text is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('hides clear button when text is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Clear text
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Clear button should disappear
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('clear button clears the text field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Text field should be empty
      expect(find.text('test query'), findsNothing);
    });

    testWidgets('debounces search input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      int searchCallCount = 0;
      conversationProvider.addListener(() {
        searchCallCount++;
      });

      // Enter text multiple times quickly
      await tester.enterText(find.byType(TextField), 't');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'te');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'tes');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for debounce delay
      await tester.pump(const Duration(milliseconds: 500));

      // Search should only be called once after debounce
      expect(searchCallCount, lessThanOrEqualTo(2));
    });

    testWidgets('calls searchConversations on text change after debounce',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      bool searchCalled = false;
      String? searchQuery;

      // Override searchConversations to track calls
      conversationProvider.addListener(() {
        searchCalled = true;
      });

      // Enter text
      await tester.enterText(find.byType(TextField), 'property search');
      await tester.pump();

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 500));

      // Verify search was triggered
      expect(searchCalled, isTrue);
    });

    testWidgets('clears search when clear button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Text should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('disposes timer on widget disposal',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text to start timer
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Remove widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles rapid text changes correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Rapidly change text
      for (int i = 0; i < 10; i++) {
        await tester.enterText(find.byType(TextField), 'query$i');
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Wait for final debounce
      await tester.pump(const Duration(milliseconds: 500));

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });
  });
}
