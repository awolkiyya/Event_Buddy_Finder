import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final txtColor = textColor ?? Colors.white;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: txtColor,
                strokeWidth: 2,
              ),
            )
          : Icon(icon, color: txtColor),
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isLoading
            ? const SizedBox.shrink(key: ValueKey('loading'))
            : Text(
                label,
                key: const ValueKey('button_label'),
                style: TextStyle(color: txtColor, fontWeight: FontWeight.w600),
              ),
      ),
      style: ElevatedButton.styleFrom(
        padding: padding,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 2,
      ),
    );
  }
}
