# Connectivity Indicator - Integration Guide

Simple, elegant connectivity indicator using colored dots instead of banners.

## What It Looks Like

- 🟢 **Emerald/Green dot** = Online
- 🔴 **Red dot** = Offline

## Quick Integration

### Option 1: Simple Dot in App Bar (Recommended)

```dart
import 'package:zena_mobile/widgets/connectivity_indicator.dart';

AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(size: 10),
    SizedBox(width: 16),
  ],
)
```

### Option 2: Dot with Label

```dart
AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(
      size: 8,
      showLabel: true, // Shows "Online" or "Offline" text
    ),
    SizedBox(width: 16),
  ],
)
```

### Option 3: Dot Next to Title

```dart
AppBar(
  title: Row(
    children: [
      Text('Chat'),
      SizedBox(width: 12),
      ConnectivityIndicator(size: 8),
    ],
  ),
)
```

### Option 4: Larger Dot for Better Visibility

```dart
AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(size: 12), // Larger dot
    SizedBox(width: 16),
  ],
)
```

## Customization

### Size
```dart
ConnectivityIndicator(size: 8)  // Small
ConnectivityIndicator(size: 10) // Medium (default)
ConnectivityIndicator(size: 12) // Large
ConnectivityIndicator(size: 14) // Extra large
```

### With Label
```dart
ConnectivityIndicator(
  size: 8,
  showLabel: true, // Shows text next to dot
)
```

## Colors

The indicator uses:
- **Online**: Emerald green (#10B981) with glow effect
- **Offline**: Red with glow effect

Both colors have a subtle shadow/glow for better visibility.

## How It Works

The indicator automatically updates in real-time by listening to the `ChatProvider`:

```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    final isOnline = chatProvider.isOnline;
    // Updates automatically when connectivity changes
  },
)
```

## Examples

See `lib/widgets/connectivity_app_bar_example.dart` for complete examples:
- `ChatAppBarExample` - Simple dot
- `ChatAppBarWithLabelExample` - Dot with label
- `ChatAppBarWithTitleIndicatorExample` - Dot next to title
- `ChatAppBarLargeIndicatorExample` - Larger dot

## Testing

1. Add the indicator to your app bar
2. Turn on airplane mode → Dot turns red
3. Turn off airplane mode → Dot turns emerald/green
4. Changes happen instantly (thanks to connectivity_plus)

## Advantages Over Banner

✅ Subtle and non-intrusive
✅ Always visible
✅ No screen space wasted
✅ Professional appearance
✅ Real-time updates
✅ Customizable size
✅ Optional label

## File Location

- Widget: `lib/widgets/connectivity_indicator.dart`
- Examples: `lib/widgets/connectivity_app_bar_example.dart`
