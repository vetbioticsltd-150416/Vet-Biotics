import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Error boundary widget that catches and handles errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, FlutterErrorDetails)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({super.key, required this.child, this.errorBuilder, this.onError});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Catch Flutter framework errors
    FlutterError.onError = (details) {
      setState(() {
        _errorDetails = details;
        _hasError = true;
      });
      widget.onError?.call();
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _errorDetails != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _errorDetails!);
      }

      return EnhancedErrorView(
        title: 'Đã xảy ra lỗi không mong muốn',
        message: 'Ứng dụng gặp sự cố. Vui lòng khởi động lại ứng dụng.',
        icon: Icons.bug_report,
        iconColor: Colors.red,
        onRetry: () {
          setState(() {
            _hasError = false;
            _errorDetails = null;
          });
        },
      );
    }

    return widget.child;
  }
}

/// Async error boundary for handling async errors
class AsyncErrorBoundary extends StatefulWidget {
  final Future<void> Function() asyncFunction;
  final Widget Function() successBuilder;
  final Widget Function(Object, StackTrace?)? errorBuilder;
  final Widget? loadingBuilder;

  const AsyncErrorBoundary({
    super.key,
    required this.asyncFunction,
    required this.successBuilder,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<AsyncErrorBoundary> createState() => _AsyncErrorBoundaryState();
}

class _AsyncErrorBoundaryState extends State<AsyncErrorBoundary> {
  bool _isLoading = true;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _executeAsyncFunction();
  }

  Future<void> _executeAsyncFunction() async {
    try {
      await widget.asyncFunction();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = null;
          _stackTrace = null;
        });
      }
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = error;
          _stackTrace = stackTrace;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingBuilder ?? const EnhancedLoadingIndicator();
    }

    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }

      return EnhancedErrorView(title: 'Lỗi xử lý dữ liệu', message: _error.toString(), onRetry: _executeAsyncFunction);
    }

    return widget.successBuilder();
  }
}

/// Network-aware widget that shows offline state
class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;

  const NetworkAwareWidget({super.key, required this.child, this.offlineWidget});

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  final bool _isOnline = true; // In a real app, you'd check connectivity

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      return widget.offlineWidget ?? const NetworkErrorView();
    }

    return widget.child;
  }
}

/// Retry button with exponential backoff
class RetryButton extends StatefulWidget {
  final Future<void> Function() onRetry;
  final String text;
  final Duration initialDelay;
  final int maxRetries;

  const RetryButton({
    super.key,
    required this.onRetry,
    this.text = 'Thử lại',
    this.initialDelay = const Duration(seconds: 1),
    this.maxRetries = 3,
  });

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  bool _isRetrying = false;
  int _retryCount = 0;

  Future<void> _handleRetry() async {
    if (_isRetrying || _retryCount >= widget.maxRetries) return;

    setState(() => _isRetrying = true);

    try {
      // Exponential backoff delay
      final delay = widget.initialDelay * (1 << _retryCount);
      await Future.delayed(delay);

      await widget.onRetry();

      if (mounted) {
        setState(() => _retryCount = 0);
      }
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isRetrying ? null : _handleRetry,
      child: _isRetrying
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 8),
                Text('Đang thử lại... (${_retryCount + 1}/${widget.maxRetries})'),
              ],
            )
          : Text(widget.text),
    );
  }
}


