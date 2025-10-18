import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

/// Debug widget to display connectivity status
/// Shows real-time connectivity status and queued message count
class ConnectivityDebugWidget extends StatelessWidget {
  const ConnectivityDebugWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: chatProvider.isOnline 
                ? Colors.green.shade100 
                : Colors.red.shade100,
            border: Border.all(
              color: chatProvider.isOnline 
                  ? Colors.green.shade700 
                  : Colors.red.shade700,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    chatProvider.isOnline 
                        ? Icons.cloud_done 
                        : Icons.cloud_off,
                    size: 20,
                    color: chatProvider.isOnline 
                        ? Colors.green.shade700 
                        : Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    chatProvider.isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: chatProvider.isOnline 
                          ? Colors.green.shade900 
                          : Colors.red.shade900,
                    ),
                  ),
                ],
              ),
              if (chatProvider.hasQueuedMessages) ...[
                const SizedBox(height: 4),
                Text(
                  'Queued messages: ${chatProvider.queuedMessageCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
