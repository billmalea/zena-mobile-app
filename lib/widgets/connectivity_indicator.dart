import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

/// Simple connectivity indicator - shows a colored dot
/// Emerald/green dot when online, red dot when offline
class ConnectivityIndicator extends StatelessWidget {
  final double size;
  final bool showLabel;

  const ConnectivityIndicator({
    super.key,
    this.size = 8.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final isOnline = chatProvider.isOnline;
        final onlineColor = EmeraldColor.emerald;
        final offlineColor = Colors.red;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? onlineColor : offlineColor,
                boxShadow: [
                  BoxShadow(
                    color: (isOnline ? onlineColor : offlineColor).withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: isOnline ? onlineColor.shade700 : offlineColor.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Extension to add emerald color to Colors class
extension EmeraldColor on Colors {
  static const MaterialColor emerald = MaterialColor(
    0xFF10B981,
    <int, Color>{
      50: Color(0xFFECFDF5),
      100: Color(0xFFD1FAE5),
      200: Color(0xFFA7F3D0),
      300: Color(0xFF6EE7B7),
      400: Color(0xFF34D399),
      500: Color(0xFF10B981),
      600: Color(0xFF059669),
      700: Color(0xFF047857),
      800: Color(0xFF065F46),
      900: Color(0xFF064E3B),
    },
  );
}
