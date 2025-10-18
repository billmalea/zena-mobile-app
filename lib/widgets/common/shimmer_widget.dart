import 'package:flutter/material.dart';

/// A widget that applies a shimmer effect to its child.
/// Used for loading states to indicate content is being fetched.
class ShimmerWidget extends StatefulWidget {
  /// The child widget to apply the shimmer effect to
  final Widget child;

  /// Whether the shimmer effect is enabled
  final bool enabled;

  const ShimmerWidget({
    super.key,
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
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If shimmer is disabled, just return the child
    if (!widget.enabled) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define shimmer colors based on theme
    final baseColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final highlightColor =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Skeleton screen for property card loading state
/// Mimics the layout of PropertyCard widget
class ShimmerPropertyCard extends StatelessWidget {
  const ShimmerPropertyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

    return ShimmerWidget(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: shimmerColor,
            ),

            // Content padding
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location placeholder
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price placeholder
                  Container(
                    height: 24,
                    width: 120,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details row placeholder (bedrooms, bathrooms, type)
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 40,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 16,
                        width: 40,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 16,
                        width: 60,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amenities placeholder
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(4, (index) {
                      return Container(
                        height: 28,
                        width: 70,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Button placeholder
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton screen for message bubble loading state
/// Mimics the layout of MessageBubble widget
class ShimmerMessageBubble extends StatelessWidget {
  final bool isUser;

  const ShimmerMessageBubble({
    super.key,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final shimmerHighlight =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ShimmerWidget(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : shimmerColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft:
                  isUser ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight:
                  isUser ? const Radius.circular(4) : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First line of text
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: shimmerHighlight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),

              // Second line of text
              Container(
                height: 14,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: shimmerHighlight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton screen for conversation list item loading state
/// Mimics the layout of ConversationListItem widget
class ShimmerConversationList extends StatelessWidget {
  final int itemCount;

  const ShimmerConversationList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerWidget(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Container(
              height: 12,
              width: 50,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}
