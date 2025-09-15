import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Custom text field with validation and various input types
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final bool filled;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final FocusNode? focusNode;
  final bool autofocus;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.autovalidateMode,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.filled = false,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController?>('controller', controller));
    properties.add(StringProperty('labelText', labelText));
    properties.add(StringProperty('hintText', hintText));
    properties.add(StringProperty('helperText', helperText));
    properties.add(StringProperty('errorText', errorText));
    properties.add(DiagnosticsProperty<TextInputType?>('keyboardType', keyboardType));
    properties.add(EnumProperty<TextInputAction?>('textInputAction', textInputAction));
    properties.add(DiagnosticsProperty<bool>('obscureText', obscureText));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(DiagnosticsProperty<bool>('readOnly', readOnly));
    properties.add(IntProperty('maxLines', maxLines));
    properties.add(IntProperty('minLines', minLines));
    properties.add(IntProperty('maxLength', maxLength));
    properties.add(IterableProperty<TextInputFormatter>('inputFormatters', inputFormatters));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onSuffixIconPressed', onSuffixIconPressed));
    properties.add(ObjectFlagProperty<ValueChanged<String>?>.has('onChanged', onChanged));
    properties.add(ObjectFlagProperty<ValueChanged<String>?>.has('onSubmitted', onSubmitted));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<FormFieldValidator<String>?>.has('validator', validator));
    properties.add(EnumProperty<AutovalidateMode?>('autovalidateMode', autovalidateMode));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('contentPadding', contentPadding));
    properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', borderRadius));
    properties.add(ColorProperty('fillColor', fillColor));
    properties.add(DiagnosticsProperty<bool>('filled', filled));
    properties.add(DiagnosticsProperty<TextStyle?>('style', style));
    properties.add(DiagnosticsProperty<TextStyle?>('labelStyle', labelStyle));
    properties.add(DiagnosticsProperty<TextStyle?>('hintStyle', hintStyle));
    properties.add(DiagnosticsProperty<TextStyle?>('errorStyle', errorStyle));
    properties.add(DiagnosticsProperty<TextStyle?>('helperStyle', helperStyle));
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode));
    properties.add(DiagnosticsProperty<bool>('autofocus', autofocus));
  }
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      style: widget.style ?? TextStyle(fontSize: UiConstants.fontSizeM, color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: UiConstants.spacingM, vertical: UiConstants.spacingM),
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        filled: widget.filled,
        fillColor: widget.fillColor ?? theme.inputDecorationTheme.fillColor,
        border: _buildBorder(theme, false),
        enabledBorder: _buildBorder(theme, false),
        focusedBorder: _buildBorder(theme, true),
        errorBorder: _buildBorder(theme, false, isError: true),
        focusedErrorBorder: _buildBorder(theme, true, isError: true),
        disabledBorder: _buildBorder(theme, false, isDisabled: true),
        labelStyle:
            widget.labelStyle ??
            TextStyle(
              fontSize: UiConstants.fontSizeM,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
        hintStyle:
            widget.hintStyle ??
            TextStyle(
              fontSize: UiConstants.fontSizeM,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
        errorStyle: widget.errorStyle ?? TextStyle(fontSize: UiConstants.fontSizeS, color: theme.colorScheme.error),
        helperStyle:
            widget.helperStyle ??
            TextStyle(
              fontSize: UiConstants.fontSizeS,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, size: UiConstants.iconSizeM),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      if (widget.onSuffixIconPressed != null) {
        return IconButton(icon: widget.suffixIcon!, onPressed: widget.onSuffixIconPressed);
      }
      return widget.suffixIcon;
    }

    return null;
  }

  InputBorder _buildBorder(ThemeData theme, bool isFocused, {bool isError = false, bool isDisabled = false}) {
    Color borderColor;

    if (isDisabled) {
      borderColor = theme.disabledColor;
    } else if (isError) {
      borderColor = theme.colorScheme.error;
    } else if (isFocused) {
      borderColor = theme.primaryColor;
    } else {
      borderColor = theme.inputDecorationTheme.border?.borderSide.color ?? theme.dividerColor;
    }

    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(UiConstants.borderRadiusM),
      borderSide: BorderSide(color: borderColor, width: isFocused ? 2.0 : 1.0),
    );
  }
}

/// Custom password text field
class PasswordTextField extends CustomTextField {
  const PasswordTextField({
    super.key,
    super.controller,
    super.labelText = 'Mật khẩu',
    super.hintText = 'Nhập mật khẩu',
    super.validator,
    super.onChanged,
    super.onSubmitted,
    super.enabled,
    super.autovalidateMode,
    super.focusNode,
    super.autofocus,
  }) : super(obscureText: true, keyboardType: TextInputType.visiblePassword, textInputAction: TextInputAction.done);
}

/// Custom email text field
class EmailTextField extends CustomTextField {
  const EmailTextField({
    super.key,
    super.controller,
    super.labelText = 'Email',
    super.hintText = 'Nhập email',
    super.validator,
    super.onChanged,
    super.onSubmitted,
    super.enabled,
    super.autovalidateMode,
    super.focusNode,
    super.autofocus,
  }) : super(
         keyboardType: TextInputType.emailAddress,
         textInputAction: TextInputAction.next,
         prefixIcon: const Icon(Icons.email_outlined),
       );
}

/// Custom phone text field
class PhoneTextField extends CustomTextField {
  PhoneTextField({
    super.key,
    super.controller,
    super.labelText = 'Số điện thoại',
    super.hintText = 'Nhập số điện thoại',
    super.validator,
    super.onChanged,
    super.onSubmitted,
    super.enabled,
    super.autovalidateMode,
    super.focusNode,
    super.autofocus,
  }) : super(
         keyboardType: TextInputType.phone,
         textInputAction: TextInputAction.next,
         prefixIcon: const Icon(Icons.phone_outlined),
         inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
       );
}

/// Custom search text field
class SearchTextField extends CustomTextField {
  const SearchTextField({
    super.key,
    super.controller,
    super.hintText = 'Tìm kiếm...',
    super.onChanged,
    super.onSubmitted,
    super.enabled,
    super.focusNode,
    super.autofocus = true,
  }) : super(
         keyboardType: TextInputType.text,
         textInputAction: TextInputAction.search,
         prefixIcon: const Icon(Icons.search),
         borderRadius: const BorderRadius.all(Radius.circular(24)),
       );
}
