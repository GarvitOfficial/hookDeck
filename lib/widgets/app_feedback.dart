import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppFeedback {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final Color accentColor = isError
        ? AppTheme.subtleError
        : (isSuccess ? AppTheme.successGreen : AppTheme.bronzeGold);

    final IconData icon = isError
        ? Icons.error_outline_rounded
        : (isSuccess ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded);

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.2),
        ),
        backgroundColor: const Color(0xFF23211D),
        content: Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFF7F5F2),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }
}
