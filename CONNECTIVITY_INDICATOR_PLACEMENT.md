# Connectivity Indicator - Placement Guide

## Recommended Placement: Top-Right Corner

```dart
AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(size: 10),  // ← Add here
    SizedBox(width: 16),              // ← Spacing from edge
  ],
)
```

### Visual Layout:
```
┌─────────────────────────────────────┐
│ ← Chat                          🟢  │  ← App Bar
└─────────────────────────────────────┘
```

## Alternative Placements

### 1. Next to Title (Left Side)
```dart
AppBar(
  title: Row(
    children: [
      Text('Chat'),
      SizedBox(width: 12),
      ConnectivityIndicator(size: 8),  // ← Smaller size recommended
    ],
  ),
)
```

Visual:
```
┌─────────────────────────────────────┐
│ ← Chat 🟢                           │
└─────────────────────────────────────┘
```

### 2. With Other Actions
```dart
AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(size: 10),
    SizedBox(width: 16),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
)
```

Visual:
```
┌─────────────────────────────────────┐
│ ← Chat                      🟢  ⋮   │
└─────────────────────────────────────┘
```

### 3. With Label (If Space Permits)
```dart
AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(size: 8, showLabel: true),
    SizedBox(width: 16),
  ],
)
```

Visual:
```
┌─────────────────────────────────────┐
│ ← Chat              🟢 Online       │
└─────────────────────────────────────┘
```

## Size Recommendations by Placement

| Placement | Recommended Size | With Label |
|-----------|-----------------|------------|
| Top-right corner | 10-12px | Optional |
| Next to title | 8-10px | Not recommended |
| With other actions | 10px | Optional |
| Standalone | 12-14px | Recommended |

## Color Meanings

- 🟢 **Emerald/Green** = Connected to internet
- 🔴 **Red** = No internet connection

## Real-World Example

```dart
import 'package:flutter/material.dart';
import 'package:zena_mobile/widgets/connectivity_indicator.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          // Connectivity indicator
          ConnectivityIndicator(size: 10),
          SizedBox(width: 16),
          
          // Optional: Other actions
          // IconButton(
          //   icon: Icon(Icons.more_vert),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: YourChatContent(),
    );
  }
}
```

## What Users Will See

### When Online:
```
┌─────────────────────────────────────┐
│ ← Chat                          🟢  │  ← Emerald dot
└─────────────────────────────────────┘
│                                     │
│  Your messages here...              │
│                                     │
```

### When Offline:
```
┌─────────────────────────────────────┐
│ ← Chat                          🔴  │  ← Red dot
└─────────────────────────────────────┘
│                                     │
│  Your messages here...              │
│  (Messages will be queued)          │
│                                     │
```

## Behavior

1. **Instant Updates**: Dot changes color immediately when connectivity changes
2. **Always Visible**: No popups or banners blocking content
3. **Subtle**: Doesn't distract from main content
4. **Professional**: Clean, modern appearance

## Testing Visibility

If the dot is too small or hard to see:

```dart
// Increase size
ConnectivityIndicator(size: 12)  // or 14

// Add label
ConnectivityIndicator(size: 10, showLabel: true)
```

## Don't Do This ❌

```dart
// ❌ Too large
ConnectivityIndicator(size: 20)

// ❌ In the middle of screen
Center(child: ConnectivityIndicator())

// ❌ Multiple indicators
Row(
  children: [
    ConnectivityIndicator(),
    ConnectivityIndicator(),  // Don't duplicate
  ],
)
```

## Do This ✅

```dart
// ✅ Clean and simple
AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(size: 10),
    SizedBox(width: 16),
  ],
)

// ✅ With proper spacing
AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(size: 10),
    SizedBox(width: 12),  // Space between elements
    IconButton(icon: Icon(Icons.search), onPressed: () {}),
    SizedBox(width: 4),   // Space from edge
  ],
)
```

## Final Recommendation

**Best practice for most apps:**

```dart
AppBar(
  title: Text('Chat'),
  actions: [
    ConnectivityIndicator(size: 10),
    SizedBox(width: 16),
  ],
)
```

This provides:
- ✅ Clear visibility
- ✅ Professional appearance
- ✅ Doesn't interfere with content
- ✅ Always accessible
- ✅ Real-time updates
