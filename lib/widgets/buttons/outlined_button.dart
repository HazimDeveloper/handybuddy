import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';

class OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final bool isLoading;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final EdgeInsetsGeometry padding;
  final bool isDisabled;
  final bool isFullWidth;
  final FontWeight fontWeight;
  final double fontSize;
  final Color? backgroundColor;

  const OutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.width,
    this.height = AppStyles.buttonHeight,
    this.borderRadius = 8.0,
    this.borderWidth = 1.5,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
    this.isDisabled = false,
    this.isFullWidth = false,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 16.0,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = isDisabled ? AppColors.borderLight : borderColor;
    final Color effectiveTextColor = isDisabled ? AppColors.textLight : textColor;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
        ),
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: borderColor.withOpacity(0.2),
          highlightColor: borderColor.withOpacity(0.1),
          child: Padding(
            padding: padding,
            child: _buildButtonContent(effectiveTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color effectiveTextColor) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            strokeWidth: 2.0,
          ),
        ),
      );
    }

    List<Widget> rowChildren = [];

    // Add prefix icon if provided
    if (prefixIcon != null) {
      rowChildren.add(Icon(
        prefixIcon,
        color: effectiveTextColor,
        size: fontSize + 4,
      ));
      rowChildren.add(const SizedBox(width: 8));
    }

    // Add text
    rowChildren.add(
      Text(
        text,
        style: TextStyle(
          color: effectiveTextColor,
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
        color: effectiveTextColor,
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

// Small Outlined Button Variant
class SmallOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final double? width;
  final bool isLoading;
  final IconData? icon;
  final bool isDisabled;
  final bool isFullWidth;
  final Color? backgroundColor;

  const SmallOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.width,
    this.isLoading = false,
    this.icon,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      text: text,
      onPressed: onPressed,
      borderColor: borderColor,
      textColor: textColor,
      width: width,
      height: AppStyles.buttonSmallHeight,
      prefixIcon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isFullWidth: isFullWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      fontSize: 14.0,
      backgroundColor: backgroundColor,
    );
  }
}

// Large Outlined Button Variant
class LargeOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final double? width;
  final bool isLoading;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isDisabled;
  final bool isFullWidth;
  final Color? backgroundColor;

  const LargeOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.width,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      text: text,
      onPressed: onPressed,
      borderColor: borderColor,
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
      backgroundColor: backgroundColor,
    );
  }
}

// Icon Outlined Button Variant
class IconOutlinedButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color iconColor;
  final double size;
  final double borderWidth;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;

  const IconOutlinedButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.borderColor = AppColors.primary,
    this.iconColor = AppColors.primary,
    this.size = 40.0,
    this.borderWidth = 1.5,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = isDisabled ? AppColors.borderLight : borderColor;
    final Color effectiveIconColor = isDisabled ? AppColors.textLight : iconColor;
    
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size / 2),
          side: BorderSide(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
        ),
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          splashColor: borderColor.withOpacity(0.2),
          highlightColor: borderColor.withOpacity(0.1),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: size / 3,
                    height: size / 3,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveIconColor),
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: size / 2,
                  ),
                ),
        ),
      ),
    );
  }
}

// Dashed Outlined Button Variant
class DashedOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final List<double> dashPattern;
  final IconData? icon;
  final bool isDisabled;
  final bool isFullWidth;
  final Color? backgroundColor;

  const DashedOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.width,
    this.height = AppStyles.buttonHeight,
    this.borderRadius = 8.0,
    this.dashPattern = const [6, 3],
    this.icon,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = isDisabled ? AppColors.borderLight : borderColor;
    final Color effectiveTextColor = isDisabled ? AppColors.textLight : textColor;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: CustomPaint(
        painter: DashedBorderPainter(
          strokeWidth: 1.5,
          radius: borderRadius,
          color: effectiveBorderColor,
          dashPattern: dashPattern,
        ),
        child: Material(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: borderColor.withOpacity(0.2),
            highlightColor: borderColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: effectiveTextColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: effectiveTextColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Painter for Dashed Border
class DashedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double radius;
  final Color color;
  final List<double> dashPattern;
  
  DashedBorderPainter({
    this.strokeWidth = 1.5,
    this.radius = 8.0,
    this.color = AppColors.primary,
    this.dashPattern = const [6, 3],
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            strokeWidth / 2,
            strokeWidth / 2,
            size.width - strokeWidth,
            size.height - strokeWidth,
          ),
          Radius.circular(radius),
        ),
      );
    
    final Path dashPath = Path();
    
    final double dashWidth = dashPattern[0];
    final double dashSpace = dashPattern[1];
    
    double distance = 0.0;
    final PathMetrics metrics = path.computeMetrics();
    
    for (final PathMetric pathMetric in metrics) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    
    canvas.drawPath(dashPath, paint);
  }
  
  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.dashPattern != dashPattern;
  }
}

// Rounded Outlined Button Variant
class RoundedOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isDisabled;
  final Color? backgroundColor;

  const RoundedOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.width,
    this.height = AppStyles.buttonHeight,
    this.icon,
    this.isDisabled = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      text: text,
      onPressed: onPressed,
      borderColor: borderColor,
      textColor: textColor,
      width: width,
      height: height,
      borderRadius: height / 2, // Fully rounded
      prefixIcon: icon,
      isDisabled: isDisabled,
      backgroundColor: backgroundColor,
    );
  }
}

// Chip Outlined Button Variant
class ChipOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isSelected;
  final Color? selectedBackgroundColor;
  final Color? selectedTextColor;
  final bool isDisabled;

  const ChipOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.prefixIcon,
    this.suffixIcon,
    this.isSelected = false,
    this.selectedBackgroundColor,
    this.selectedTextColor,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = isSelected 
        ? (selectedBackgroundColor ?? AppColors.primary) 
        : borderColor;
    final effectiveTextColor = isSelected 
        ? (selectedTextColor ?? Colors.white) 
        : textColor;
    final effectiveBackgroundColor = isSelected 
        ? (selectedBackgroundColor ?? AppColors.primary) 
        : null;

    return OutlinedButton(
      text: text,
      onPressed: onPressed,
      borderColor: effectiveBorderColor,
      textColor: effectiveTextColor,
      height: 36.0,
      borderRadius: 18.0, // Fully rounded for chip style
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      fontSize: 14.0,
      isDisabled: isDisabled,
      backgroundColor: effectiveBackgroundColor,
    );
  }
}