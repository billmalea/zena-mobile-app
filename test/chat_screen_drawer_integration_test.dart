import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zena_mobile/providers/chat_provider.dart';
import 'package:zena_mobile/providers/conversation_provider.dart';
import 'package:zena_mobile/screens/chat/chat_screen.dart';
import 'package:zena_mobile/services/chat_service.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';
import 'package:zena_mobile/models/conversation.dart';
import 'package:zena_mobile/models/message.dart';

void main() {
  group('ChatScreen Drawer Integration Tests', () {
    late ChatProvider chatProvider;
    late ConversationProvider conversationProvider;
    late ChatService chatService;
    late SubmissionStateManager stateManager;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: '.env.local');

      // Initialize SharedPreferences mock before Supabase
      SharedPreferences.setMockInitialValues({});

      // Initialize Supabase with test credentials
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      chatService = ChatService();
      stateManager = SubmissionStateManager(prefs);
      chatProvider = ChatProvider(stateManager);
      conversationProvider = ConversationProvider(chatService);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
          ChangeNotifierProvider<ConversationProvider>.value(
              value: conversationProvider),
        ],
        child: const MaterialApp(
          home: ChatScreen(),
        ),
      );
    }

    testWidgets('should display menu button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify menu button exists
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byTooltip('Conversations'), findsOneWidget);
    });

    testWidgets('should open drawer when menu button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify drawer is not visible initially
      expect(find.text('Conversations'), findsNothing);

      // Tap menu button
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer is now visible
      expect(find.text('Conversations'), findsOneWidget);
    });

    testWidgets(
        'should display default title "Zena" when no conversation is active',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify default title
      expect(find.text('Zena'), findsOneWidget);
    });

    testWidgets('should display drawer with conversation list',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer is open
      expect(find.text('Conversations'), findsOneWidget);

      // Verify drawer content is displayed
      // Note: In a real test with mock data, we would verify conversation items
      // For now, we verify the drawer structure exists
    });

    testWidgets('should display new conversation button in drawer',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify new conversation button exists
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byTooltip('New Conversation'), findsOneWidget);
    });

    testWidgets('should have scaffold key for drawer control',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify drawer exists
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNotNull);
    });
  });
}
