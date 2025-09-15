import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Enhanced error view with retry functionality and better UX
class EnhancedErrorView extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? iconColor;
  final bool showRetryButton;

  const EnhancedErrorView({
    super.key,
    this.title = 'Đã xảy ra lỗi',
    this.message = 'Không thể tải dữ liệu. Vui lòng thử lại.',
    this.actionText,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) => AnimatedFadeIn(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with animation
            AnimatedScaleIn(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).colorScheme.error).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: iconColor ?? Theme.of(context).colorScheme.error),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Message
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 300),
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),

            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 32),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 400),
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(actionText ?? 'Thử lại'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('message', message));
    properties.add(StringProperty('actionText', actionText));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ColorProperty('iconColor', iconColor));
    properties.add(DiagnosticsProperty<bool>('showRetryButton', showRetryButton));
  }
}

/// Network error view
class NetworkErrorView extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) => EnhancedErrorView(
    title: 'Không có kết nối mạng',
    message: 'Vui lòng kiểm tra kết nối internet và thử lại.',
    icon: Icons.wifi_off,
    iconColor: Colors.orange,
    onRetry: onRetry,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
  }
}

/// Empty state view
class EnhancedEmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EnhancedEmptyView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => AnimatedFadeIn(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animation
            AnimatedScaleIn(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: iconColor ?? Theme.of(context).colorScheme.primary),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Message
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 300),
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),

            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  child: Text(actionText!),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('message', message));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('actionText', actionText));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onAction', onAction));
    properties.add(ColorProperty('iconColor', iconColor));
  }
}

/// Success view
class EnhancedSuccessView extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData icon;

  const EnhancedSuccessView({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.icon = Icons.check_circle,
  });

  @override
  Widget build(BuildContext context) => AnimatedFadeIn(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon with animation
            AnimatedScaleIn(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 64, color: Colors.green),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Message
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 300),
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),

            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(actionText!),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('message', message));
    properties.add(StringProperty('actionText', actionText));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onAction', onAction));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
  }
}
