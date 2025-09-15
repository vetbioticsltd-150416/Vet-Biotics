import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Animated fade in widget
class AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DiagnosticsProperty<Duration>('delay', delay));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
  }
}

class _AnimatedFadeInState extends State<AnimatedFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      if (!themeProvider.animationsEnabled) {
        return widget.child;
      }

      return FadeTransition(opacity: _animation, child: widget.child);
    },
  );
}

/// Animated slide in widget
class AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const AnimatedSlideIn({
    super.key,
    required this.child,
    this.beginOffset = const Offset(0, 0.1),
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedSlideIn> createState() => _AnimatedSlideInState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Offset>('beginOffset', beginOffset));
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DiagnosticsProperty<Duration>('delay', delay));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
  }
}

class _AnimatedSlideInState extends State<AnimatedSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      if (!themeProvider.animationsEnabled) {
        return widget.child;
      }

      return SlideTransition(position: _animation, child: widget.child);
    },
  );
}

/// Animated scale widget
class AnimatedScaleIn extends StatefulWidget {
  final Widget child;
  final double beginScale;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const AnimatedScaleIn({
    super.key,
    required this.child,
    this.beginScale = 0.8,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutBack,
  });

  @override
  State<AnimatedScaleIn> createState() => _AnimatedScaleInState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('beginScale', beginScale));
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(DiagnosticsProperty<Duration>('delay', delay));
    properties.add(DiagnosticsProperty<Curve>('curve', curve));
  }
}

class _AnimatedScaleInState extends State<AnimatedScaleIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      if (!themeProvider.animationsEnabled) {
        return widget.child;
      }

      return ScaleTransition(scale: _animation, child: widget.child);
    },
  );
}

/// Enhanced loading indicator with animations
class EnhancedLoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;

  const EnhancedLoadingIndicator({super.key, this.message, this.size = 40, this.color});

  @override
  State<EnhancedLoadingIndicator> createState() => _EnhancedLoadingIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
    properties.add(DoubleProperty('size', size));
    properties.add(ColorProperty('color', color));
  }
}

class _EnhancedLoadingIndicatorState extends State<EnhancedLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      var color = widget.color ?? Theme.of(context).colorScheme.primary;

      if (!themeProvider.animationsEnabled) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(color)),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 16),
              Text(widget.message!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(color)),
                ),
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 200),
              child: Text(widget.message!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            ),
          ],
        ],
      );
    },
  );
}

/// Animated list item with staggered animation
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration staggerDelay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 100),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
    properties.add(DiagnosticsProperty<Duration>('baseDelay', baseDelay));
    properties.add(DiagnosticsProperty<Duration>('staggerDelay', staggerDelay));
  }
}

class _AnimatedListItemState extends State<AnimatedListItem> {
  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      if (!themeProvider.animationsEnabled) {
        return widget.child;
      }

      var delay = widget.baseDelay + (widget.staggerDelay * widget.index);

      return AnimatedFadeIn(
        delay: delay,
        child: AnimatedSlideIn(delay: delay, beginOffset: const Offset(0.1, 0), child: widget.child),
      );
    },
  );
}

/// Animated card with hover effect
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AnimatedCard({super.key, required this.child, this.onTap, this.elevation = 2, this.padding, this.borderRadius});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(DoubleProperty('elevation', elevation));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
    properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', borderRadius));
  }
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      if (!themeProvider.animationsEnabled) {
        return Card(
          elevation: widget.elevation,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: widget.borderRadius ?? BorderRadius.circular(12)),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            child: Padding(padding: widget.padding ?? const EdgeInsets.all(16), child: widget.child),
          ),
        );
      }

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: _elevationAnimation.value,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: widget.borderRadius ?? BorderRadius.circular(12)),
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              child: Padding(padding: widget.padding ?? const EdgeInsets.all(16), child: widget.child),
            ),
          ),
        ),
        child: widget.child,
      );
    },
  );
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFEBEBF4),
    this.highlightColor = const Color(0xFFF4F4F4),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(ColorProperty('baseColor', baseColor));
    properties.add(ColorProperty('highlightColor', highlightColor));
  }
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)..repeat();

    _animation = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      if (!themeProvider.animationsEnabled) {
        return widget.child;
      }

      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(_animation.value - 0.5, 0),
            end: Alignment(_animation.value + 0.5, 0),
            colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: widget.child,
        ),
        child: widget.child,
      );
    },
  );
}

/// Page transition wrapper for smooth navigation
class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;

  SmoothPageTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            if (!themeProvider.animationsEnabled) {
              return child ?? page;
            }

            const begin = Offset(1, 0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
}
