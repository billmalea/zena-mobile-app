import 'package:flutter/material.dart';

/// ThinkingIndicator shows when Zena is processing a message
/// Matches web implementation with bouncing dots animation
class ThinkingIndicator extends StatelessWidget {
  final String message;

  const ThinkingIndicator({
    super.key,
    this.message = 'Zena is thinking...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF10B981), // emerald-500
                  Colors.teal.shade600,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFA7F3D0), // emerald-200
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA7F3D0).withOpacity(0.5), // emerald-200
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouncing dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BouncingDot(delay: 0),
                      const SizedBox(width: 4),
                      _BouncingDot(delay: 100),
                      const SizedBox(width: 4),
                      _BouncingDot(delay: 200),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Message text
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Color(0xFF10B981), // emerald-500
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouncing dot animation
class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation with delay
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981), // emerald-500
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// Searching indicator variant
class SearchingIndicator extends StatelessWidget {
  const SearchingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThinkingIndicator(
      message: 'Searching for rental properties...',
    );
  }
}

/// Analyzing indicator variant
class AnalyzingIndicator extends StatelessWidget {
  const AnalyzingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThinkingIndicator(
      message: 'Analyzing neighborhood data...',
    );
  }
}

/// Calculating indicator variant
class CalculatingIndicator extends StatelessWidget {
  const CalculatingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThinkingIndicator(
      message: 'Calculating affordability...',
    );
  }
}
