import 'package:flutter/material.dart';
import 'connectivity_indicator.dart';

/// Demo screen showing different connectivity indicator styles
/// Use this to preview and choose your preferred style
class ConnectivityIndicatorDemo extends StatelessWidget {
  const ConnectivityIndicatorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectivity Indicator Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Choose Your Style',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Size variations
          _buildSection(
            'Size Variations',
            [
              _buildExample('Small (8px)', const ConnectivityIndicator(size: 8)),
              _buildExample('Medium (10px)', const ConnectivityIndicator(size: 10)),
              _buildExample('Large (12px)', const ConnectivityIndicator(size: 12)),
              _buildExample('Extra Large (14px)', const ConnectivityIndicator(size: 14)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // With labels
          _buildSection(
            'With Labels',
            [
              _buildExample(
                'Small with label',
                const ConnectivityIndicator(size: 8, showLabel: true),
              ),
              _buildExample(
                'Medium with label',
                const ConnectivityIndicator(size: 10, showLabel: true),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // App bar previews
          _buildSection(
            'App Bar Previews',
            [
              _buildAppBarPreview('Simple dot', const ConnectivityIndicator(size: 10)),
              _buildAppBarPreview(
                'Dot with label',
                const ConnectivityIndicator(size: 8, showLabel: true),
              ),
              _buildAppBarPreview('Large dot', const ConnectivityIndicator(size: 12)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recommendations
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Recommendations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('• Use size 10-12 for app bar'),
                  Text('• Add label only if space permits'),
                  Text('• Place in top-right corner of app bar'),
                  Text('• Emerald = Online, Red = Offline'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildExample(String label, Widget indicator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label),
          ),
          indicator,
        ],
      ),
    );
  }

  Widget _buildAppBarPreview(String label, Widget indicator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  indicator,
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
