import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable Empty State Widget
/// 
/// Follows Nielsen's Heuristics:
/// - Visibility of System Status (shows why empty)
/// - Help Users Recognize, Diagnose and Recover (provides action)
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;
  final Color? iconColor;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.illustration,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Illustration
            if (illustration != null)
              illustration!
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primaryGreen).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: iconColor ?? AppTheme.primaryGreen,
                ),
              ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action Button (if provided)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16, // 44px minimum touch target
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(160, 48), // WCAG compliance
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

/// Predefined Empty States for Common Scenarios

class NoListingsEmptyState extends StatelessWidget {
  final VoidCallback? onCreateListing;

  const NoListingsEmptyState({Key? key, this.onCreateListing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.storefront_outlined,
      iconColor: AppTheme.primaryGreen,
      title: 'No listings yet',
      message: 'Start selling your recyclables to earn money!\nCreate your first listing to get started.',
      actionLabel: 'Create First Listing',
      onAction: onCreateListing,
    );
  }
}

class NoOrdersEmptyState extends StatelessWidget {
  final VoidCallback? onBrowseMarketplace;

  const NoOrdersEmptyState({Key? key, this.onBrowseMarketplace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      iconColor: Colors.blue,
      title: 'No orders yet',
      message: 'Browse the marketplace to start buying materials\nor wait for buyers to place orders.',
      actionLabel: 'Browse Marketplace',
      onAction: onBrowseMarketplace,
    );
  }
}

class NoInternetEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetEmptyState({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      iconColor: AppTheme.errorRed,
      title: 'No internet connection',
      message: 'Please check your connection and try again.\nMake sure WiFi or mobile data is enabled.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

class SearchNoResultsEmptyState extends StatelessWidget {
  final String? searchQuery;

  const SearchNoResultsEmptyState({Key? key, this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      iconColor: Colors.orange,
      title: 'No results found',
      message: searchQuery != null
          ? 'No results for "$searchQuery"\nTry different keywords or filters.'
          : 'No results match your search.\nTry adjusting your filters.',
    );
  }
}

class LocationDisabledEmptyState extends StatelessWidget {
  final VoidCallback? onEnableLocation;
  final VoidCallback? onEnterManually;

  const LocationDisabledEmptyState({
    Key? key,
    this.onEnableLocation,
    this.onEnterManually,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 64,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Location permission denied',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We need your location for accurate pickup.\nEnable in settings or enter manually.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Two action buttons
            if (onEnableLocation != null)
              ElevatedButton.icon(
                onPressed: onEnableLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Enable Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            if (onEnterManually != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onEnterManually,
                icon: const Icon(Icons.edit_location_alt),
                label: const Text('Enter Manually'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  side: BorderSide(color: AppTheme.primaryGreen),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
