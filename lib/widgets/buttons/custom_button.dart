import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final EdgeInsetsGeometry padding;
  final bool isDisabled;
  final bool isFullWidth;
  final double elevation;
  final FontWeight fontWeight;
  final double fontSize;
  final BorderSide? borderSide;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.width,
    this.height = AppStyles.buttonHeight,
    this.borderRadius = 8.0,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
    this.isDisabled = false,
    this.isFullWidth = false,
    this.elevation = 2.0,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 16.0,
    this.borderSide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: isDisabled 
              ? AppColors.buttonDisabled 
              : backgroundColor,
          padding: padding,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
          disabledBackgroundColor: AppColors.buttonDisabled,
          disabledForegroundColor: AppColors.textLight,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
          strokeWidth: 2.0,
        ),
      );
    }

    List<Widget> rowChildren = [];

    // Add prefix icon if provided
    if (prefixIcon != null) {
      rowChildren.add(Icon(
        prefixIcon,
        color: isDisabled ? AppColors.textLight : textColor,
        size: fontSize + 4,
      ));
      rowChildren.add(const SizedBox(width: 8));
    }

    // Add text
    rowChildren.add(
      Text(
        text,
        style: TextStyle(
          color: isDisabled ? AppColors.textLight : textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );

    // Add suffix icon if provided
    if (suffixIcon != null) {
      rowChildren.add(const SizedBox(width: 8));
      rowChildren.add(Icon(
        suffixIcon,
        color: isDisabled ? AppColors.textLight : textColor,
        size: fontSize + 4,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowChildren,
    );
  }
}

// Small Button Variant
class SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final bool isLoading;
  final IconData? icon;
  final bool isDisabled;
  final bool isFullWidth;
  final BorderSide? borderSide;

  const SmallButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.width,
    this.isLoading = false,
    this.icon,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.borderSide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: AppStyles.buttonSmallHeight,
      prefixIcon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isFullWidth: isFullWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      fontSize: 14.0,
      borderSide: borderSide,
    );
  }
}

// Large Button Variant
class LargeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final bool isLoading;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isDisabled;
  final bool isFullWidth;
  final BorderSide? borderSide;

  const LargeButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.width,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.borderSide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: AppStyles.buttonLargeHeight,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isFullWidth: isFullWidth,
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0),
      fontSize: 18.0,
      borderSide: borderSide,
    );
  }
}

// Icon Button Variant
class IconButtonCustom extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final bool isLoading;
  final bool isDisabled;
  final double elevation;
  final BorderSide? borderSide;

  const IconButtonCustom({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.iconColor = Colors.white,
    this.size = 40.0,
    this.isLoading = false,
    this.isDisabled = false,
    this.elevation = 2.0,
    this.borderSide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: iconColor,
          backgroundColor: isDisabled 
              ? AppColors.buttonDisabled 
              : backgroundColor,
          padding: EdgeInsets.zero,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size / 2),
            side: borderSide ?? BorderSide.none,
          ),
          minimumSize: Size(size, size),
          maximumSize: Size(size, size),
        ),
        child: isLoading
            ? SizedBox(
                width: size / 3,
                height: size / 3,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  strokeWidth: 2.0,
                ),
              )
            : Icon(
                icon,
                color: isDisabled ? AppColors.textLight : iconColor,
                size: size / 2,
              ),
      ),
    );
  }
}

// Gradient Button Variant
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final Color textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? prefixIcon;
  final bool isDisabled;
  final bool isFullWidth;
  final double fontSize;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradientColors = AppColors.primaryGradient,
    this.textColor = Colors.white,
    this.width,
    this.height = AppStyles.buttonHeight,
    this.borderRadius = 8.0,
    this.isLoading = false,
    this.prefixIcon,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.fontSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? const LinearGradient(
                colors: [AppColors.buttonDisabled, AppColors.buttonDisabled],
              )
            : LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withOpacity(0.2),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      strokeWidth: 2.0,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefixIcon != null) ...[
                        Icon(
                          prefixIcon,
                          color: isDisabled ? AppColors.textLight : textColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: isDisabled ? AppColors.textLight : textColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// Fab style Button
class FabButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color backgroundColor;
  final Color iconColor;
  final bool isExtended;
  final bool isLoading;
  final bool isDisabled;

  const FabButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor = AppColors.primary,
    this.iconColor = Colors.white,
    this.isExtended = false,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: isDisabled || isLoading ? null : onPressed,
        backgroundColor: isDisabled ? AppColors.buttonDisabled : backgroundColor,
        foregroundColor: iconColor,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  strokeWidth: 2.0,
                ),
              )
            : Icon(icon),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      backgroundColor: isDisabled ? AppColors.buttonDisabled : backgroundColor,
      foregroundColor: iconColor,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                strokeWidth: 2.0,
              ),
            )
          : Icon(icon),
    );
  }
}