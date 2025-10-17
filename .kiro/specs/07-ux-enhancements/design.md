# Design Document

## Overview

The UX Enhancements & Polish specification covers improvements that enhance the overall user experience. These include suggested queries, shimmer loading states, theme toggle, animations, haptic feedback, and accessibility improvements. While not critical, these features significantly improve the app's polish and usability.

**Current State:** Basic empty state and error handling exist. Need to add polish features.

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│                    App Level                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Theme Provider                                  │  │
│  │  (Light/Dark/System)                             │  │
│  └──────────────────────────────────────────────────┘  │
│                         │                               │
│                         ▼                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Chat Screen                                     │  │
│  │  ├─ Empty State (with Suggested Queries)        │  │
│  │  ├─ Shimmer Loading States                      │  │
│  │  ├─ Enhanced Error States                       │  │
│  │  ├─ Animations & Transitions                    │  │
│  │  └─ Haptic Feedback                             │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Suggested Queries Widget

**Location:** `lib/widgets/chat/suggested_queries.dart`

**Purpose:** Display suggested queries on empty state

**Interface:**
```dart
class SuggestedQueries extends StatelessWidget {
  final Function(String) onQuerySelected;
  final List<String> suggestions;
  
  const SuggestedQueries({
    required this.onQuerySelected,
    this.suggestions = defaultSuggestions,
  });
  
  static const List<String> defaultSuggestions = [
    "Find me a 2-bedroom apartment in Westlands under 50k",
    "I want to list my property",
    "Show me bedsitters near Ngong Road",
    "What's the difference between a bedsitter and studio?",
    "Help me calculate what I can afford",
    "Tell me about Kilimani neighborhood",
  ];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Try asking:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...suggestions.map((query) => _buildQueryChip(context, query)),
      ],
    );
  }
  
  Widget _buildQueryChip(BuildContext context, String query) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onQuerySelected(query),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: Text(query)),
              Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Shimmer Loading Widget

**Location:** `lib/widgets/common/shimmer_widget.dart`

**Purpose:** Shimmer effect for loading states

**Interface:**
```dart
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;
  
  const ShimmerWidget({
    required this.child,
    this.enabled = true,
  });
  
  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Skeleton screens
class ShimmerPropertyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 200, color: Colors.grey[300]),
            SizedBox(height: 12),
            Container(height: 20, width: 200, color: Colors.grey[300]),
            SizedBox(height: 8),
            Container(height: 16, width: 150, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
```

### 3. Theme Provider

**Location:** `lib/providers/theme_provider.dart`

**Purpose:** Manage app theme (light/dark/system)

**Interface:**
```dart
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider(this._prefs) {
    _loadThemeMode();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void _loadThemeMode() {
    final savedMode = _prefs.getString(_themeKey);
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
      ? ThemeMode.dark 
      : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
```

### 4. Enhanced Empty State

**Location:** `lib/widgets/chat/enhanced_empty_state.dart`

**Purpose:** Welcoming empty state with features and suggestions

**Interface:**
```dart
class EnhancedEmptyState extends StatelessWidget {
  final String? userName;
  final Function(String) onQuerySelected;
  
  const EnhancedEmptyState({
    this.userName,
    required this.onQuerySelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 40),
          
          // Logo
          Icon(
            Icons.home_work,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          
          SizedBox(height: 24),
          
          // Welcome message
          Text(
            'Hi${userName != null ? ' $userName' : ''}! 👋',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 8),
          
          Text(
            'I\'m your AI rental assistant',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: 32),
          
          // Features
          Text(
            'I can help you:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 16),
          
          _buildFeature(Icons.search, 'Find properties'),
          _buildFeature(Icons.add_home, 'List your property'),
          _buildFeature(Icons.calculate, 'Calculate affordability'),
          _buildFeature(Icons.location_city, 'Get neighborhood info'),
          
          SizedBox(height: 32),
          
          // Suggested queries
          SuggestedQueries(onQuerySelected: onQuerySelected),
        ],
      ),
    );
  }
  
  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
```

### 5. Enhanced Error States

**Location:** `lib/widgets/common/error_state.dart`

**Purpose:** User-friendly error display with retry

**Interface:**
```dart
enum ErrorType {
  network,
  auth,
  server,
  validation,
  unknown,
}

class ErrorState extends StatelessWidget {
  final String message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  
  const ErrorState({
    required this.message,
    this.type = ErrorType.unknown,
    this.onRetry,
    this.onDismiss,
  });
  
  IconData get _icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.auth:
        return Icons.lock;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.validation:
        return Icons.warning;
      default:
        return Icons.error;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
              ),
            if (onDismiss != null)
              TextButton(
                onPressed: onDismiss,
                child: Text('Dismiss'),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 6. Haptic Feedback Helper

**Location:** `lib/utils/haptic_helper.dart`

**Purpose:** Centralized haptic feedback

**Interface:**
```dart
import 'package:flutter/services.dart';

enum HapticType {
  light,
  medium,
  heavy,
  selection,
}

class HapticHelper {
  static void trigger(HapticType type) {
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }
  
  static void onButtonPress() => trigger(HapticType.light);
  static void onSuccess() => trigger(HapticType.medium);
  static void onError() => trigger(HapticType.heavy);
  static void onSelection() => trigger(HapticType.selection);
}
```

### 7. Animations

**Message Send Animation:**
```dart
class AnimatedMessageBubble extends StatefulWidget {
  final Message message;
  
  @override
  State<AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MessageBubble(message: widget.message),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Testing Strategy

### Widget Tests
- Test suggested queries render
- Test shimmer animation
- Test theme toggle
- Test error states
- Test animations

### Integration Tests
- Test theme persists
- Test haptic feedback triggers
- Test accessibility features

### Manual Tests
- Test suggested queries on empty state
- Test theme switching
- Test loading states
- Test animations
- Test haptic feedback
- Test with screen reader

## Implementation Notes

### Phase 1: Suggested Queries & Empty State (Day 1)
- Create SuggestedQueries widget
- Create EnhancedEmptyState
- Test on empty chat

### Phase 2: Loading & Error States (Day 1-2)
- Create ShimmerWidget
- Create skeleton screens
- Create ErrorState widget
- Test all states

### Phase 3: Theme & Polish (Day 2-3)
- Create ThemeProvider
- Add theme toggle
- Add animations
- Add haptic feedback
- Test accessibility

## Dependencies

```yaml
dependencies:
  shared_preferences: ^2.2.0  # For theme persistence
  # No additional packages needed for basic animations
```

## Accessibility Guidelines

1. **Semantic Labels:** All interactive elements have labels
2. **Contrast:** WCAG AA compliant (4.5:1 for normal text)
3. **Touch Targets:** Minimum 48x48 pixels
4. **Focus Indicators:** Visible focus states
5. **Screen Reader:** Proper semantic structure

## Performance Optimizations

1. **Image Caching:** Use cached_network_image
2. **List Optimization:** Use ListView.builder
3. **Lazy Loading:** Load content on demand
4. **Debouncing:** Debounce search input
5. **Memory Management:** Dispose controllers properly
