import 'package:flutter/material.dart';

/// User-Friendly Error Messages
/// 
/// Follows Nielsen's Heuristic #9: Help Users Recognize, Diagnose, and Recover from Errors
/// - Express in plain language (no codes)
/// - Precisely indicate problem
/// - Constructively suggest a solution

class ErrorMessageHelper {
  /// Convert technical errors to user-friendly messages
  static String getUserFriendlyError(dynamic error) {
    String errorStr = error.toString().toLowerCase();

    // Network errors
    if (errorStr.contains('socket') || errorStr.contains('network') || errorStr.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (errorStr.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }
    if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }
    if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'You don\'t have permission for this action.';
    }
    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'The requested item was not found.';
    }
    if (errorStr.contains('500') || errorStr.contains('server error')) {
      return 'Server error. Please try again later.';
    }

    // Validation errors
    if (errorStr.contains('validation')) {
      return 'Please check your input and try again.';
    }
    if (errorStr.contains('required')) {
      return 'Please fill in all required fields.';
    }
    if (errorStr.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (errorStr.contains('password')) {
      return 'Password must be at least 8 characters with uppercase, lowercase, and number.';
    }

    // Location errors
    if (errorStr.contains('location')) {
      return 'Unable to access location. Please enable permissions.';
    }

    // File upload errors
    if (errorStr.contains('file') || errorStr.contains('upload')) {
      return 'File upload failed. Please try a smaller image.';
    }

    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  /// Determine if an error is network-related
  static bool isNetworkError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('internet') ||
        lower.contains('timeout') ||
        lower.contains('connection') ||
        lower.contains('failed host');
  }

  /// Premium themed error SnackBar with icon, proper colors, and optional retry
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNetwork = isNetworkError(message);

    final bgColor = isDark
        ? (isNetwork ? const Color(0xFF2A1A00) : const Color(0xFF2A0A0A))
        : (isNetwork ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE));

    final borderColor = isNetwork
        ? Colors.orange.withValues(alpha: isDark ? 0.4 : 0.5)
        : Colors.red.withValues(alpha: isDark ? 0.3 : 0.4);

    final iconColor = isNetwork
        ? (isDark ? Colors.orange.shade300 : Colors.orange.shade700)
        : (isDark ? Colors.red.shade300 : Colors.red.shade600);

    final textColor = isDark
        ? (isNetwork ? Colors.orange.shade200 : Colors.red.shade200)
        : (isNetwork ? Colors.orange.shade900 : Colors.red.shade800);

    final icon = isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: bgColor,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: iconColor,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 0,
      ),
    );
  }

  /// Premium themed success SnackBar
  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A2A1A) : const Color(0xFFE8F5E9);
    final borderColor = isDark
        ? Colors.green.withValues(alpha: 0.3)
        : Colors.green.withValues(alpha: 0.4);
    final iconColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
    final textColor = isDark ? Colors.green.shade200 : Colors.green.shade900;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: bgColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 0,
      ),
    );
  }

  /// Premium themed warning SnackBar
  static void showWarningSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF2A1A00) : const Color(0xFFFFF8E1);
    final borderColor = isDark
        ? Colors.orange.withValues(alpha: 0.3)
        : Colors.orange.withValues(alpha: 0.4);
    final iconColor = isDark ? Colors.orange.shade300 : Colors.orange.shade700;
    final textColor = isDark ? Colors.orange.shade200 : Colors.orange.shade900;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: bgColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 0,
      ),
    );
  }

  /// Premium themed info SnackBar
  static void showInfoSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A1A2A) : const Color(0xFFE3F2FD);
    final borderColor = isDark
        ? Colors.blue.withValues(alpha: 0.3)
        : Colors.blue.withValues(alpha: 0.4);
    final iconColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    final textColor = isDark ? Colors.blue.shade200 : Colors.blue.shade900;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: bgColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 0,
      ),
    );
  }

  /// Show error dialog with more details
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNetwork = isNetworkError(message);

    final iconColor = isNetwork
        ? (isDark ? Colors.orange.shade300 : Colors.orange.shade700)
        : (isDark ? Colors.red.shade300 : Colors.red.shade600);
    final icon = isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2A3A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
            height: 1.5,
          ),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: isDark ? const Color(0xFF00D9A5) : const Color(0xFF1A8F3A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error State Widget (for full-screen errors)
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNetwork = ErrorMessageHelper.isNetworkError(message);
    
    final displayIcon = isNetwork ? Icons.wifi_off_rounded : icon;
    final iconColor = isNetwork
        ? (isDark ? Colors.orange.shade300 : Colors.orange.shade600)
        : (isDark ? Colors.red.shade300 : Colors.red.shade400);
    final iconBgColor = isNetwork
        ? (isDark ? Colors.orange.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.08))
        : (isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.08));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                displayIcon,
                size: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF00D9A5)
                      : const Color(0xFF1A8F3A),
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(160, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
