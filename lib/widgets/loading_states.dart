import 'package:flutter/material.dart';

/// Yeniden kullanılabilir loading state widget'ları
class LoadingStates {
  
  /// Skeleton loading for list items
  static Widget skeletonListTile({
    bool showAvatar = true,
    bool showSubtitle = true,
    bool showTrailing = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: showAvatar 
          ? _SkeletonBox(width: 40, height: 40, borderRadius: 20)
          : null,
        title: _SkeletonBox(height: 16, width: double.infinity),
        subtitle: showSubtitle 
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _SkeletonBox(height: 12, width: 200),
            )
          : null,
        trailing: showTrailing 
          ? _SkeletonBox(width: 24, height: 24)
          : null,
      ),
    );
  }

  /// Skeleton loading for cards
  static Widget skeletonCard({
    double height = 120,
    bool showImage = false,
  }) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage) ...[
              _SkeletonBox(height: 60, width: double.infinity),
              const SizedBox(height: 12),
            ],
            _SkeletonBox(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            _SkeletonBox(height: 12, width: 150),
            const SizedBox(height: 8),
            _SkeletonBox(height: 12, width: 100),
          ],
        ),
      ),
    );
  }

  /// Loading list with skeleton items
  static Widget skeletonList({
    int itemCount = 5,
    bool showAvatar = true,
    bool showSubtitle = true,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => skeletonListTile(
        showAvatar: showAvatar,
        showSubtitle: showSubtitle,
      ),
    );
  }

  /// Loading grid with skeleton cards
  static Widget skeletonGrid({
    int itemCount = 6,
    int crossAxisCount = 2,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.5,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => skeletonCard(),
    );
  }

  /// Centered loading indicator with message
  static Widget centeredLoading({
    String message = 'Yükleniyor...',
    bool showMessage = true,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (showMessage) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Loading overlay for buttons
  static Widget buttonLoading({
    required String text,
    bool isLoading = false,
    VoidCallback? onPressed,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading 
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon ?? Icons.check),
      label: Text(isLoading ? 'İşleniyor...' : text),
    );
  }

  /// Shimmer effect for skeleton loading
  static Widget shimmerLoading({
    required Widget child,
    bool isLoading = true,
  }) {
    if (!isLoading) return child;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      child: child,
    );
  }

  /// Error state with retry button
  static Widget errorState({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ],
      ),
    );
  }

  /// Empty state
  static Widget emptyState({
    required String message,
    IconData icon = Icons.inbox_outlined,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton box widget for creating loading placeholders
class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
color: Colors.grey.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
