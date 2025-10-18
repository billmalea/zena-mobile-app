import 'package:flutter/material.dart';
import 'package:zena_mobile/widgets/common/shimmer_widget.dart';

/// Demo app to visually test skeleton screen widgets
/// Run with: flutter run test/skeleton_screens_demo.dart
void main() {
  runApp(const SkeletonScreensDemo());
}

class SkeletonScreensDemo extends StatelessWidget {
  const SkeletonScreensDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skeleton Screens Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skeleton Screens Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          PropertyCardDemo(),
          MessageBubbleDemo(),
          ConversationListDemo(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Property Card',
          ),
          NavigationDestination(
            icon: Icon(Icons.message),
            label: 'Message Bubble',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Conversation List',
          ),
        ],
      ),
    );
  }
}

class PropertyCardDemo extends StatelessWidget {
  const PropertyCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'ShimmerPropertyCard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ShimmerPropertyCard(),
        SizedBox(height: 16),
        ShimmerPropertyCard(),
      ],
    );
  }
}

class MessageBubbleDemo extends StatelessWidget {
  const MessageBubbleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'ShimmerMessageBubble',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text('User Message:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ShimmerMessageBubble(isUser: true),
        SizedBox(height: 16),
        Text('Assistant Message:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ShimmerMessageBubble(isUser: false),
        SizedBox(height: 16),
        ShimmerMessageBubble(isUser: false),
      ],
    );
  }
}

class ConversationListDemo extends StatelessWidget {
  const ConversationListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'ShimmerConversationList',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ShimmerConversationList(itemCount: 8),
        ),
      ],
    );
  }
}
