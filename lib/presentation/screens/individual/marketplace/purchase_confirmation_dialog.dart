import 'package:flutter/material.dart';
import '../../../../core/theme/marketplace_theme.dart';
import '../../../../core/models/listing_model.dart';
import '../../../widgets/marketplace/glass_card.dart';
import '../../../widgets/marketplace/neon_button.dart';
import 'order_details_screen.dart';

class PurchaseConfirmationDialog extends StatelessWidget {
  final Listing item;

  const PurchaseConfirmationDialog({Key? key, required this.item})
      : super(key: key);

  void _onConfirm(BuildContext context) {
    Navigator.pop(context); // Close dialog
    // Navigate to Order Details (Simulating successful purchase)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: isDark
                  ? MarketplaceTheme.darkAccentGreen
                  : MarketplaceTheme.lightAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Purchase',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You are about to purchase ${item.estimatedWeight}kg of ${item.materialType} from ${item.user?.name ?? "Unknown"}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeonButton(
                    text: 'CONFIRM',
                    onPressed: () => _onConfirm(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
