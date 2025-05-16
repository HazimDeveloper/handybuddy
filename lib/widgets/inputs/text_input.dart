import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';

class TextInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? labelColor;
  final Color? textColor;
  final double borderRadius;
  final String? initialValue;
  final bool showCounter;
  final bool showClearButton;
  final bool autofocus;
  final AutovalidateMode autovalidateMode;
  final bool dense;
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;
  final String? helperText;
  final String? counterText;
  final TextCapitalization textCapitalization;
  final bool expands;
  final bool showBorder;
  final Function(bool hasFocus)? onFocusChanged;
  final String? labelText;
  final Widget? label2;

  const TextInput({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.onTap,
    this.onSubmitted,
    this.margin,
    this.contentPadding,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.labelColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.initialValue,
    this.showCounter = false,
    this.showClearButton = false,
    this.autofocus = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.dense = false,
    this.suffixIconConstraints,
    this.prefixIconConstraints,
    this.helperText,
    this.counterText,
    this.textCapitalization = TextCapitalization.none,
    this.expands = false,
    this.showBorder = true,
    this.onFocusChanged,
    this.labelText,
    this.label2,
  }) : super(key: key);

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _obscureText = false;
  bool _hasText = false;
  bool _hasFocus = false;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
    
    _focusNode.addListener(_handleFocusChange);
    
    if (widget.autofocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    
    super.dispose();
  }
  
  @override
  void didUpdateWidget(TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.initialValue != null && widget.controller == null && 
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue!;
    }
  }
  
  void _handleTextChange() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }
  
  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
    
    if (widget.onFocusChanged != null) {
      widget.onFocusChanged!(_focusNode.hasFocus);
    }
  }
  
  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  
  void _clearText() {
    _controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPasswordField = widget.obscureText;
    final bool showLabel = widget.label != null || widget.labelText != null;
    
    // Build the input field
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label row (if provided)
          if (showLabel || widget.label2 != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  if (showLabel)
                    Text(
                      widget.label ?? widget.labelText ?? '',
                      style: AppStyles.labelStyle.copyWith(
                        color: widget.labelColor ?? AppColors.textSecondary,
                      ),
                    ),
                  if (showLabel && widget.label2 != null)
                    const Spacer(),
                  if (widget.label2 != null)
                    widget.label2!,
                ],
              ),
            ),
            
          // Text field
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: _obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            validator: widget.validator,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onSubmitted,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            expands: widget.expands,
            autovalidateMode: widget.autovalidateMode,
            autofocus: widget.autofocus,
            style: AppStyles.bodyTextStyle.copyWith(
              color: widget.textColor ?? AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hint,
              errorText: widget.errorText,
              helperText: widget.helperText,
              counterText: widget.counterText,
              filled: true,
              fillColor: widget.fillColor ?? 
                  (widget.enabled ? Colors.white : AppColors.backgroundLight),
              contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              isDense: widget.dense,
              border: widget.showBorder ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor ?? AppColors.borderLight,
                  width: 1.0,
                ),
              ) : InputBorder.none,
              enabledBorder: widget.showBorder ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor ?? AppColors.borderLight,
                  width: 1.0,
                ),
              ) : InputBorder.none,
              focusedBorder: widget.showBorder ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.focusedBorderColor ?? AppColors.primary,
                  width: 2.0,
                ),
              ) : InputBorder.none,
              errorBorder: widget.showBorder ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.0,
                ),
              ) : InputBorder.none,
              focusedErrorBorder: widget.showBorder ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 2.0,
                ),
              ) : InputBorder.none,
              prefixIcon: widget.prefix,
              prefixIconConstraints: widget.prefixIconConstraints,
              suffixIcon: _buildSuffix(isPasswordField),
              suffixIconConstraints: widget.suffixIconConstraints,
              counterStyle: AppStyles.captionStyle,
              errorStyle: AppStyles.captionStyle.copyWith(
                color: AppColors.error,
              ),
              helperStyle: AppStyles.captionStyle,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the suffix icon based on field type and state
  Widget? _buildSuffix(bool isPasswordField) {
    // If a custom suffix is provided, use it
    if (widget.suffix != null) {
      return widget.suffix;
    }
    
    // For password fields, show the toggle visibility button
    if (isPasswordField) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
        ),
        onPressed: _toggleObscureText,
        splashRadius: 20,
      );
    }
    
    // For non-empty text fields with clearable option, show the clear button
    if (widget.showClearButton && _hasText) {
      return IconButton(
        icon: const Icon(
          Icons.clear,
          color: AppColors.textSecondary,
        ),
        onPressed: _clearText,
        splashRadius: 20,
      );
    }
    
    return null;
  }
}

// Email Input
class EmailInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final EdgeInsetsGeometry? margin;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool showClearButton;
  final String? initialValue;

  const EmailInput({
    Key? key,
    this.controller,
    this.focusNode,
    this.label = 'Email',
    this.hint = 'Enter your email address',
    this.errorText,
    this.onChanged,
    this.validator,
    this.onTap,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.margin,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    this.showClearButton = true,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextInput(
      controller: controller,
      focusNode: focusNode,
      label: label,
      hint: hint,
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      margin: margin,
      prefix: const Icon(
        Icons.email_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces in email
      ],
      autofocus: autofocus,
      showClearButton: showClearButton,
      initialValue: initialValue,
    );
  }
}

// Password Input
class PasswordInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final EdgeInsetsGeometry? margin;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const PasswordInput({
    Key? key,
    this.controller,
    this.focusNode,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.errorText,
    this.onChanged,
    this.validator,
    this.onTap,
    this.onSubmitted,
    this.enabled = true,
    this.margin,
    this.textInputAction = TextInputAction.done,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextInput(
      controller: controller,
      focusNode: focusNode,
      label: label,
      hint: hint,
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      obscureText: true,
      enabled: enabled,
      margin: margin,
      prefix: const Icon(
        Icons.lock_outline,
        color: AppColors.textSecondary,
        size: 20,
      ),
      autofocus: autofocus,
    );
  }
}

// Phone Number Input
class PhoneInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final EdgeInsetsGeometry? margin;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final String? initialValue;

  const PhoneInput({
    Key? key,
    this.controller,
    this.focusNode,
    this.label = 'Phone Number',
    this.hint = 'Enter your phone number',
    this.errorText,
    this.onChanged,
    this.validator,
    this.onTap,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.margin,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextInput(
      controller: controller,
      focusNode: focusNode,
      label: label,
      hint: hint,
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      margin: margin,
      prefix: const Icon(
        Icons.phone_android,
        color: AppColors.textSecondary,
        size: 20,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
      autofocus: autofocus,
      showClearButton: true,
      initialValue: initialValue,
    );
  }
}

// Multiline Text Area Input
class TextAreaInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final EdgeInsetsGeometry? margin;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final bool autofocus;
  final String? initialValue;

  const TextAreaInput({
    Key? key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.validator,
    this.onTap,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.margin,
    this.maxLines = 5,
    this.minLines = 3,
    this.maxLength,
    this.showCounter = true,
    this.autofocus = false,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextInput(
      controller: controller,
      focusNode: focusNode,
      label: label,
      hint: hint,
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      enabled: enabled,
      readOnly: readOnly,
      margin: margin,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCounter: showCounter,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      autofocus: autofocus,
      initialValue: initialValue,
    );
  }
}