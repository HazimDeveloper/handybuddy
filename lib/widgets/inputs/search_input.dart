import 'dart:async';

import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/utils/form_validators.dart';

class SearchInput extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String> onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Color? backgroundColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final double? height;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;
  final bool showScanButton;
  final VoidCallback? onScanTap;
  final String? defaultSearchText;
  final bool enableValidation;
  final String? Function(String?)? validator;
  final bool debounce;
  final Duration debounceTime;
  final bool showShadow;
  final bool readOnly;
  final VoidCallback? onTap;

  const SearchInput({
    Key? key,
    this.hintText,
    required this.onSearch,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.controller,
    this.focusNode,
    this.backgroundColor,
    this.iconColor,
    this.margin,
    this.contentPadding,
    this.borderRadius,
    this.height,
    this.showFilterButton = false,
    this.onFilterTap,
    this.showScanButton = false,
    this.onScanTap,
    this.defaultSearchText,
    this.enableValidation = false,
    this.validator,
    this.debounce = false,
    this.debounceTime = const Duration(milliseconds: 500),
    this.showShadow = true,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    // Set default search text if provided
    if (widget.defaultSearchText != null && widget.defaultSearchText!.isNotEmpty) {
      _controller.text = widget.defaultSearchText!;
      _showClearButton = true;
    }
    
    // Add listener to show/hide clear button
    _controller.addListener(_textControllerListener);
    
    // Set focus if autofocus is true
    if (widget.autofocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }
  
  void _textControllerListener() {
    final hasText = _controller.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  @override
  void dispose() {
    // Only dispose controller and focus node if they were created internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    setState(() {
      _showClearButton = false;
    });
    
    widget.onClear?.call();
    if (!widget.debounce) {
      widget.onSearch('');
    }
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  void _handleTextChanged(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
    
    if (widget.debounce) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceTime, () {
        widget.onSearch(value);
      });
    }
  }

  void _handleSubmitted(String value) {
    // Validate if needed
    if (widget.enableValidation) {
      final validator = widget.validator ?? FormValidators.validateSearchQuery;
      final error = validator(value);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    
    // Cancel any pending debounce timer and perform search immediately
    _debounceTimer?.cancel();
    widget.onSearch(value);
    
    // Unfocus keyboard
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 48,
      margin: widget.margin ?? const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: widget.showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Search Icon
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search,
              color: widget.iconColor ?? AppColors.textSecondary,
              size: 20,
            ),
          ),
          
          // Search Input
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onChanged: _handleTextChanged,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText ?? AppTexts.searchForServices,
                hintStyle: AppStyles.bodyTextStyle.copyWith(
                  color: AppColors.textLight,
                ),
                contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
              style: AppStyles.bodyTextStyle,
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // Clear Button (conditionally shown)
          if (_showClearButton)
            IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.textLight,
                size: 20,
              ),
              splashRadius: 24,
              onPressed: _onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              tooltip: 'Clear',
            ),
          
          // Scan Button (optional)
          if (widget.showScanButton && widget.onScanTap != null)
            IconButton(
              icon: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.textSecondary,
                size: 20,
              ),
              splashRadius: 24,
              onPressed: widget.onScanTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              tooltip: 'Scan',
            ),
          
          // Filter Button (optional)
          if (widget.showFilterButton && widget.onFilterTap != null)
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.textSecondary,
                size: 20,
              ),
              splashRadius: 24,
              onPressed: widget.onFilterTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              tooltip: 'Filter',
            ),
        ],
      ),
    );
  }
}