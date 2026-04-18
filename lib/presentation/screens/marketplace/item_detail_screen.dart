import 'package:flutter/material.dart';
import '../../../core/theme/marketplace_theme.dart';
import '../../../core/models/listing_model.dart';
import '../../widgets/marketplace/glass_card.dart';
import '../../widgets/marketplace/neon_button.dart';
import '../individual/marketplace/checkout_screen.dart'; // Route to the checkout screen

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> itemMap;

  const ItemDetailScreen({Key? key, required this.itemMap}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final Listing item;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    item = Listing.fromJson(widget.itemMap);
  }

  void _onBuyPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: MarketplaceTheme.getBackgroundGradient(isDark),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Image Area
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        children: [
                          PageView.builder(
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemCount: item.hasNetworkImages
                                ? item.imageUrls.length
                                : (item.decodedImages.isNotEmpty ? item.decodedImages.length : 1),
                            itemBuilder: (context, index) {
                              if (item.hasNetworkImages) {
                                return Image.network(
                                  item.imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 250,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: isDark
                                            ? MarketplaceTheme.darkAccentCyan
                                            : MarketplaceTheme.lightAccent,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 60,
                                        color: isDark
                                            ? MarketplaceTheme.darkAccentCyan
                                            : MarketplaceTheme.lightAccent,
                                      ),
                                    );
                                  },
                                );
                              } else if (item.decodedImages.isNotEmpty) {
                                return Image.memory(
                                  item.decodedImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 250,
                                );
                              } else {
                                return Center(
                                  child: Icon(
                                    Icons.recycling,
                                    size: 80,
                                    color: isDark
                                        ? MarketplaceTheme.darkAccentCyan
                                        : MarketplaceTheme.lightAccent,
                                  ),
                                );
                              }
                            },
                          ),
                          // Dot Indicators
                          if ((item.hasNetworkImages && item.imageUrls.length > 1) ||
                              (!item.hasNetworkImages && item.decodedImages.length > 1))
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  item.hasNetworkImages ? item.imageUrls.length : item.decodedImages.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentImageIndex == index ? 10 : 8,
                                    height: _currentImageIndex == index ? 10 : 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == index
                                          ? (isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent)
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Content Area
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? MarketplaceTheme.darkAccentGreen
                                        .withOpacity(0.2)
                                    : MarketplaceTheme.lightAccent
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.materialType.toUpperCase(),
                                style: TextStyle(
                                  color: isDark
                                      ? MarketplaceTheme.darkAccentGreen
                                      : MarketplaceTheme.lightAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.displayTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seller: ${item.user?.name ?? "Unknown"}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Price Calculation Mock
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Text(
                              'Rs ${(item.estimatedWeight * 20).toStringAsFixed(0)}', // Mock rate 20
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? MarketplaceTheme.darkAccentGreen
                                    : MarketplaceTheme.lightAccent,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        NeonButton(
                          text: 'BUY NOW',
                          height: 56,
                          onPressed: () => _onBuyPressed(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

