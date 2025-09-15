import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Custom loading indicator with different styles
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;
  final LoadingStyle style;

  const LoadingIndicator({
    super.key,
    this.size = UiConstants.iconSizeL,
    this.color,
    this.message,
    this.style = LoadingStyle.spinner,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: size, height: size, child: _buildIndicator(theme)),
        if (message != null) ...[
          const SizedBox(height: UiConstants.spacingM),
          Text(
            message!,
            style: TextStyle(fontSize: UiConstants.fontSizeM, color: theme.textTheme.bodyMedium?.color),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildIndicator(ThemeData theme) {
    final indicatorColor = color ?? theme.primaryColor;

    switch (style) {
      case LoadingStyle.spinner:
        return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(indicatorColor), strokeWidth: 3);

      case LoadingStyle.linear:
        return LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(indicatorColor));

      case LoadingStyle.dots:
        return _DotsIndicator(color: indicatorColor, size: size);

      case LoadingStyle.pulse:
        return _PulseIndicator(color: indicatorColor, size: size);

      case LoadingStyle.wave:
        return _WaveIndicator(color: indicatorColor, size: size);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
    properties.add(ColorProperty('color', color));
    properties.add(StringProperty('message', message));
    properties.add(EnumProperty<LoadingStyle>('style', style));
  }
}

/// Loading style enum
enum LoadingStyle { spinner, linear, dots, pulse, wave }

/// Dots loading indicator
class _DotsIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsIndicator({required this.color, required this.size});

  @override
  State<_DotsIndicator> createState() => _DotsIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
  }
}

class _DotsIndicatorState extends State<_DotsIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

    _animations = List.generate(
      3,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 0.8 + index * 0.2, curve: Curves.easeInOut),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      3,
      (index) => AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) => Container(
          width: widget.size / 6,
          height: widget.size / 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animations[index].value),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}

/// Pulse loading indicator
class _PulseIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseIndicator({required this.color, required this.size});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
  }
}

class _PulseIndicatorState extends State<_PulseIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, child) => Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: _animation.value),
        shape: BoxShape.circle,
      ),
    ),
  );
}

/// Wave loading indicator
class _WaveIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _WaveIndicator({required this.color, required this.size});

  @override
  State<_WaveIndicator> createState() => _WaveIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
  }
}

class _WaveIndicatorState extends State<_WaveIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

    _animations = List.generate(
      5,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 0.6 + index * 0.1, curve: Curves.easeInOut),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      5,
      (index) => AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) => Container(
          width: widget.size / 8,
          height: widget.size * _animations[index].value,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(1)),
        ),
      ),
    ),
  );
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final LoadingStyle style;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.style = LoadingStyle.spinner,
  });

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      if (isLoading)
        Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: LoadingIndicator(message: message, style: style),
          ),
        ),
    ],
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(StringProperty('message', message));
    properties.add(EnumProperty<LoadingStyle>('style', style));
  }
}

/// Loading button state
class LoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final ButtonStyle? style;

  const LoadingButton({super.key, required this.onPressed, required this.child, this.style});

  @override
  State<LoadingButton> createState() => _LoadingButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Future<void> Function()>.has('onPressed', onPressed));
    properties.add(DiagnosticsProperty<ButtonStyle?>('style', style));
  }
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: _isLoading ? null : _handlePress,
    style: widget.style,
    child: _isLoading
        ? const SizedBox(
            width: UiConstants.iconSizeM,
            height: UiConstants.iconSizeM,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          )
        : widget.child,
  );
}
