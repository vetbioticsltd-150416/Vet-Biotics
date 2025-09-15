import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Custom button with different styles and states
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height ?? UiConstants.buttonHeightM,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(theme),
        child: _buildContent(),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final baseStyle = ElevatedButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: UiConstants.spacingL, vertical: UiConstants.spacingM),
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(UiConstants.borderRadiusM)),
    );

    switch (style) {
      case CustomButtonStyle.primary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(theme.primaryColor),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        );

      case CustomButtonStyle.secondary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(theme.secondaryHeaderColor),
          foregroundColor: WidgetStateProperty.all(theme.primaryColor),
        );

      case CustomButtonStyle.outline:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(theme.primaryColor),
          side: WidgetStateProperty.all(BorderSide(color: theme.primaryColor, width: 1)),
        );

      case CustomButtonStyle.danger:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.red),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        );

      case CustomButtonStyle.success:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.green),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        );

      case CustomButtonStyle.disabled:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.grey),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: UiConstants.iconSizeM,
        height: UiConstants.iconSizeM,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: UiConstants.spacingS)],
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: UiConstants.fontSizeM),
        ),
        if (trailingIcon != null) ...[const SizedBox(width: UiConstants.spacingS), trailingIcon!],
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
    properties.add(EnumProperty<CustomButtonStyle>('style', style));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
    properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', borderRadius));
  }
}

/// Button style enum
enum CustomButtonStyle { primary, secondary, outline, danger, success, disabled }

/// Custom text button
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const CustomTextButton({super.key, required this.text, this.onPressed, this.textStyle, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: UiConstants.spacingM, vertical: UiConstants.spacingS),
      ),
      child: Text(
        text,
        style:
            textStyle ??
            TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500, fontSize: UiConstants.fontSizeM),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
    properties.add(DiagnosticsProperty<TextStyle?>('textStyle', textStyle));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
  }
}

/// Custom icon button
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = UiConstants.iconSizeM,
    this.color,
    this.padding,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color ?? theme.iconTheme.color,
      padding: padding ?? const EdgeInsets.all(UiConstants.spacingS),
      tooltip: tooltip,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
    properties.add(DoubleProperty('size', size));
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
    properties.add(StringProperty('tooltip', tooltip));
  }
}
