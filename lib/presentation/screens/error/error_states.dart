import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// Reusable Error State Component
class ErrorStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;
  final double iconSize;

  const ErrorStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
    this.iconSize = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultIconColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? defaultIconColor,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// No Internet Connection Screen
class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      body: ErrorStateWidget(
        icon: Icons.cloud_off,
        title: 'You seem offline',
        message:
            'Please check your internet connection and try again. Make sure Wi-Fi or mobile data is turned on.',
        buttonText: 'Retry',
        onButtonPressed: onRetry ?? () => Navigator.pop(context),
        iconColor: const Color(0xFF9E9E9E),
      ),
    );
  }
}

// GPS Not Available Screen
class GpsNotAvailableScreen extends StatelessWidget {
  final VoidCallback? onManualEntry;
  final VoidCallback? onRetry;

  const GpsNotAvailableScreen({
    Key? key,
    this.onManualEntry,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Location Required'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 100,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to access location',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'GPS is not available or permission was denied. Please enable GPS in your device settings or enter your location manually.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry ?? () => Navigator.pop(context),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Enable GPS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onManualEntry ?? () => Navigator.pop(context),
                icon: const Icon(Icons.edit_location),
                label: const Text(
                  'Enter Location Manually',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Upload Failed Screen
class UploadFailedScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? errorMessage;

  const UploadFailedScreen({
    Key? key,
    this.onRetry,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Upload Failed'),
        elevation: 0,
      ),
      body: ErrorStateWidget(
        icon: Icons.cloud_upload,
        title: 'Upload Failed',
        message: errorMessage ??
            'Image upload failed. Please check your internet connection and try again.',
        buttonText: 'Try Again',
        onButtonPressed: onRetry ?? () => Navigator.pop(context),
        iconColor: AppTheme.errorRed,
      ),
    );
  }
}

// Something Went Wrong Screen
class SomethingWentWrongScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? errorMessage;

  const SomethingWentWrongScreen({
    Key? key,
    this.onRetry,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Error'),
        elevation: 0,
      ),
      body: ErrorStateWidget(
        icon: Icons.error_outline,
        title: 'Oops! Something went wrong',
        message: errorMessage ??
            'We encountered an unexpected error. Please try again. If the problem persists, contact support.',
        buttonText: 'Retry',
        onButtonPressed: onRetry ?? () => Navigator.pop(context),
        iconColor: AppTheme.errorRed,
      ),
    );
  }
}

// Invalid File Format Screen
class InvalidFileFormatScreen extends StatelessWidget {
  final VoidCallback? onSelectAnother;
  final String? supportedFormats;

  const InvalidFileFormatScreen({
    Key? key,
    this.onSelectAnother,
    this.supportedFormats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Invalid File'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 80,
              color: const Color(0xFFFF5722),
            ),
            const SizedBox(height: 24),
            Text(
              'Invalid File Format',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The file you selected is not supported.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                      .withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Supported Formats',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    supportedFormats ?? 'PNG, JPG, JPEG (Max 5MB)',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSelectAnother ?? () => Navigator.pop(context),
                icon: const Icon(Icons.photo_library),
                label: const Text(
                  'Select Another File',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
