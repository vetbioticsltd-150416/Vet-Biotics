import 'package:flutter/material.dart';
import 'package:shared/src/constants/ui_constants.dart';

/// Custom button with different styles and states
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle style;
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
    this.style = ButtonStyle.primary,
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
      case ButtonStyle.primary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(theme.primaryColor),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        );

      case ButtonStyle.secondary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(theme.secondaryHeaderColor),
          foregroundColor: WidgetStateProperty.all(theme.primaryColor),
        );

      case ButtonStyle.outline:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(theme.primaryColor),
          side: WidgetStateProperty.all(BorderSide(color: theme.primaryColor, width: 1)),
        );

      case ButtonStyle.danger:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.red),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        );

      case ButtonStyle.success:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.green),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        );

      case ButtonStyle.disabled:
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
}

/// Button style enum
enum ButtonStyle { primary, secondary, outline, danger, success, disabled }

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
}
