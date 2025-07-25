import 'package:flutter/material.dart';

class CustomSocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor; // New: Optional border color
  final double height;
  final double borderRadius;
  final double iconPadding; // New: Padding between icon and text
  final TextStyle? textStyle; // New: Optional custom text style
  final bool isLoading; // New: For loading state feedback
  final bool isDisabled; // New: For disabled state feedback

  const CustomSocialButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.borderColor, // Default to null, will apply if set
    this.height = 50,
    this.borderRadius = 8,
    this.iconPadding = 12, // Default padding for modern look
    this.textStyle,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool effectiveIsDisabled = isDisabled || isLoading;

    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        icon: isLoading
            ? SizedBox(
                width: 24, // Match icon size
                height: 24, // Match icon size
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      textColor), // Spinner color matches text
                  strokeWidth: 2,
                ),
              )
            : icon,
        label: Text(
          isLoading ? 'Loading...' : label, // Show "Loading..." text
          style: textStyle ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: effectiveIsDisabled ? textColor.withOpacity(0.5) : textColor, // Dim text when disabled
                    fontWeight: FontWeight.w600,
                  ),
        ),
        onPressed: effectiveIsDisabled ? null : onPressed, // Disable onPressed when loading or explicitly disabled
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveIsDisabled
              ? backgroundColor.withOpacity(0.7) // Slightly dim background when disabled
              : backgroundColor,
          foregroundColor: effectiveIsDisabled
              ? textColor.withOpacity(0.7) // Dim foreground when disabled
              : textColor,
          elevation: effectiveIsDisabled ? 0 : 2, // No elevation when disabled
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null
                ? BorderSide(
                    color: effectiveIsDisabled
                        ? borderColor!.withOpacity(0.5)
                        : borderColor!,
                    width: 1.0,
                  )
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16), // Consistent horizontal padding
          textStyle: textStyle ?? Theme.of(context).textTheme.titleMedium, // Ensure button text uses a theme style
          // Explicitly set icon padding via material tap target size or custom layout
          // For ElevatedButton.icon, `icon` and `label` are already arranged with default spacing.
          // If more control is needed, you might consider Row for custom layout.
        ).copyWith(
          // MaterialStateProperty for hover/focus
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return textColor.withOpacity(0.08); // Subtle hover effect
              }
              if (states.contains(MaterialState.pressed)) {
                return textColor.withOpacity(0.12); // Pressed effect
              }
              if (states.contains(MaterialState.focused)) {
                return textColor.withOpacity(0.12); // Focus effect
              }
              return null; // Defer to the widget's default.
            },
          ),
        ),
      ),
    );
  }
}