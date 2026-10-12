import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TactileButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final double height;
  final double borderRadius;
  final Gradient? gradient;
  final Color? textColor;

  const TactileButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.height = 50,
    this.borderRadius = 12,
    this.gradient,
    this.textColor,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

typedef LuxuryButton = TactileButton;

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Skinny Brown & Noir styling
    final primaryFill = isDark
        ? const Color(0xFFC59B6D) // Warm bronze gold in dark mode
        : const Color(0xFF8C5E38); // Skinny saddle brown in light mode

    final primaryText = isDark ? const Color(0xFF0F0E0D) : Colors.white;

    final secondaryBg = isDark
        ? const Color(0xFF1E1D1A)
        : const Color(0xFFF2EFE9);

    final secondaryBorder = isDark
        ? const Color(0xFF33302A)
        : const Color(0xFFE2DDD3);

    final secondaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: widget.onPressed != null && !widget.isLoading
            ? (_) {
                setState(() => _isPressed = true);
                HapticFeedback.selectionClick();
              }
            : null,
        onTapUp: widget.onPressed != null && !widget.isLoading
            ? (_) {
                setState(() => _isPressed = false);
              }
            : null,
        onTapCancel: () {
          setState(() => _isPressed = false);
        },
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: widget.isSecondary ? secondaryBg : primaryFill,
            border: widget.isSecondary
                ? Border.all(color: secondaryBorder, width: 1.0)
                : null,
            boxShadow: widget.isSecondary
                ? null
                : [
                    BoxShadow(
                      color: primaryFill.withValues(alpha: isDark ? 0.2 : 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isSecondary ? secondaryText : primaryText,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 18,
                        color: widget.textColor ?? (widget.isSecondary ? secondaryText : primaryText),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.textColor ?? (widget.isSecondary ? secondaryText : primaryText),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
