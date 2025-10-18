import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/widgets/common/shimmer_widget.dart';

void main() {
  group('ShimmerWidget', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      const testText = 'Test Child';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerWidget(
              child: Text(testText),
            ),
          ),
        ),
      );
      
      expect(find.text(testText), findsOneWidget);
    });
    
    testWidgets('applies shimmer effect when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerWidget(
              enabled: true,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
      
      // Verify ShaderMask is present (shimmer effect)
      expect(find.byType(ShaderMask), findsOneWidget);
      // Verify ShimmerWidget is present
      expect(find.byType(ShimmerWidget), findsOneWidget);
    });
    
    testWidgets('does not apply shimmer effect when disabled', (WidgetTester tester) async {
      const testText = 'Test Child';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerWidget(
              enabled: false,
              child: Text(testText),
            ),
          ),
        ),
      );
      
      // When disabled, ShaderMask should not be present
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text(testText), findsOneWidget);
    });
    
    testWidgets('animation repeats continuously', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerWidget(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
      
      // Pump frames to verify animation is running
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShimmerWidget), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShimmerWidget), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShimmerWidget), findsOneWidget);
    });
    
    testWidgets('disposes animation controller properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerWidget(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
      
      // Remove the widget to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );
      
      // If dispose wasn't called properly, this would throw an error
      expect(tester.takeException(), isNull);
    });
  });

  group('ShimmerPropertyCard', () {
    testWidgets('renders property card skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPropertyCard(),
          ),
        ),
      );
      
      // Verify ShimmerPropertyCard is present
      expect(find.byType(ShimmerPropertyCard), findsOneWidget);
      
      // Verify ShimmerWidget is wrapping the content
      expect(find.byType(ShimmerWidget), findsOneWidget);
      
      // Verify Card is present
      expect(find.byType(Card), findsOneWidget);
    });
    
    testWidgets('has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPropertyCard(),
          ),
        ),
      );
      
      // Verify image placeholder exists
      final imagePlaceholder = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxHeight == 200,
      );
      expect(imagePlaceholder, findsAtLeastNWidgets(1));
      
      // Verify multiple placeholder containers exist
      expect(find.byType(Container), findsWidgets);
    });
  });
  
  group('ShimmerMessageBubble', () {
    testWidgets('renders message bubble skeleton for user', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerMessageBubble(isUser: true),
          ),
        ),
      );
      
      // Verify ShimmerMessageBubble is present
      expect(find.byType(ShimmerMessageBubble), findsOneWidget);
      
      // Verify ShimmerWidget is wrapping the content
      expect(find.byType(ShimmerWidget), findsOneWidget);
      
      // Verify Align widget is present
      expect(find.byType(Align), findsOneWidget);
    });
    
    testWidgets('renders message bubble skeleton for assistant', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerMessageBubble(isUser: false),
          ),
        ),
      );
      
      // Verify ShimmerMessageBubble is present
      expect(find.byType(ShimmerMessageBubble), findsOneWidget);
      
      // Verify ShimmerWidget is wrapping the content
      expect(find.byType(ShimmerWidget), findsOneWidget);
    });
    
    testWidgets('has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerMessageBubble(),
          ),
        ),
      );
      
      // Verify multiple placeholder containers exist (for text lines)
      expect(find.byType(Container), findsWidgets);
      
      // Verify Column is present for text lines
      expect(find.byType(Column), findsOneWidget);
    });
  });
  
  group('ShimmerConversationList', () {
    testWidgets('renders conversation list skeleton with default item count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerConversationList(),
          ),
        ),
      );
      
      // Verify ShimmerConversationList is present
      expect(find.byType(ShimmerConversationList), findsOneWidget);
      
      // Verify ListView is present
      expect(find.byType(ListView), findsOneWidget);
      
      // Verify multiple ShimmerWidgets are present (one per item)
      expect(find.byType(ShimmerWidget), findsWidgets);
      
      // Verify ListTile widgets are present
      expect(find.byType(ListTile), findsWidgets);
    });
    
    testWidgets('renders correct number of items', (WidgetTester tester) async {
      const itemCount = 3;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerConversationList(itemCount: itemCount),
          ),
        ),
      );
      
      // Verify correct number of ListTile widgets
      expect(find.byType(ListTile), findsNWidgets(itemCount));
    });
    
    testWidgets('has correct layout structure for each item', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerConversationList(itemCount: 1),
          ),
        ),
      );
      
      // Verify ListTile is present
      expect(find.byType(ListTile), findsOneWidget);
      
      // Verify multiple placeholder containers exist
      expect(find.byType(Container), findsWidgets);
      
      // Verify Column is present for subtitle lines
      expect(find.byType(Column), findsWidgets);
    });
  });
}
