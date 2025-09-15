import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Error view widget for displaying error states
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? customAction;
  final ErrorViewType type;

  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.subtitle,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryText,
    this.customAction,
    this.type = ErrorViewType.card,
  });

  factory ErrorView.network({String? message, VoidCallback? onRetry, ErrorViewType type = ErrorViewType.fullscreen}) =>
      ErrorView(
        title: 'Không có kết nối',
        message: message ?? 'Vui lòng kiểm tra kết nối internet và thử lại',
        icon: Icons.wifi_off,
        onRetry: onRetry,
        retryText: 'Thử lại',
        type: type,
      );

  factory ErrorView.server({String? message, VoidCallback? onRetry, ErrorViewType type = ErrorViewType.card}) =>
      ErrorView(
        title: 'Lỗi máy chủ',
        message: message ?? 'Có lỗi xảy ra từ máy chủ. Vui lòng thử lại sau',
        icon: Icons.cloud_off,
        onRetry: onRetry,
        retryText: 'Thử lại',
        type: type,
      );

  factory ErrorView.notFound({String? message, VoidCallback? onRetry, ErrorViewType type = ErrorViewType.card}) =>
      ErrorView(
        title: 'Không tìm thấy',
        message: message ?? 'Không tìm thấy dữ liệu bạn yêu cầu',
        icon: Icons.search_off,
        onRetry: onRetry,
        retryText: 'Quay lại',
        type: type,
      );

  factory ErrorView.permission({String? message, VoidCallback? onRetry, ErrorViewType type = ErrorViewType.card}) =>
      ErrorView(
        title: 'Không có quyền truy cập',
        message: message ?? 'Bạn không có quyền truy cập vào tính năng này',
        icon: Icons.lock_outline,
        onRetry: onRetry,
        retryText: 'Yêu cầu quyền',
        type: type,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (type) {
      case ErrorViewType.fullscreen:
        return _buildFullscreenError(theme);
      case ErrorViewType.card:
        return _buildCardError(theme);
      case ErrorViewType.inline:
        return _buildInlineError(theme);
    }
  }

  Widget _buildFullscreenError(ThemeData theme) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.error),
            const SizedBox(height: UiConstants.spacingXL),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UiConstants.spacingM),
            Text(message, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: UiConstants.spacingS),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: UiConstants.spacingXL),
            if (customAction != null)
              customAction!
            else if (onRetry != null)
              CustomButton(text: retryText ?? 'Thử lại', onPressed: onRetry, style: CustomButtonStyle.primary),
          ],
        ),
      ),
    ),
  );

  Widget _buildCardError(ThemeData theme) => Card(
    margin: const EdgeInsets.all(UiConstants.spacingM),
    child: Padding(
      padding: const EdgeInsets.all(UiConstants.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: UiConstants.spacingL),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UiConstants.spacingS),
          Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: UiConstants.spacingS),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: UiConstants.spacingL),
          if (customAction != null)
            customAction!
          else if (onRetry != null)
            CustomButton(text: retryText ?? 'Thử lại', onPressed: onRetry, style: CustomButtonStyle.outline),
        ],
      ),
    ),
  );

  Widget _buildInlineError(ThemeData theme) => Container(
    padding: const EdgeInsets.all(UiConstants.spacingM),
    decoration: BoxDecoration(
      color: theme.colorScheme.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(UiConstants.borderRadiusM),
      border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.error),
        const SizedBox(width: UiConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(message, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error.withValues(alpha: 0.7)),
                ),
              ],
            ],
          ),
        ),
        if (customAction != null) ...[
          const SizedBox(width: UiConstants.spacingM),
          customAction!,
        ] else if (onRetry != null) ...[
          const SizedBox(width: UiConstants.spacingM),
          CustomIconButton(
            icon: Icons.refresh,
            onPressed: onRetry,
            color: theme.colorScheme.error,
            tooltip: retryText ?? 'Thử lại',
          ),
        ],
      ],
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('message', message));
    properties.add(StringProperty('subtitle', subtitle));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
    properties.add(StringProperty('retryText', retryText));
    properties.add(EnumProperty<ErrorViewType>('type', type));
  }
}

/// Error view type enum
enum ErrorViewType { fullscreen, card, inline }
