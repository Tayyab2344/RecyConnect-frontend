import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/marketplace_theme.dart';
import '../../../core/models/listing_model.dart';
import '../../widgets/marketplace/glass_card.dart';
import '../../widgets/marketplace/neon_button.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../individual/marketplace/checkout_screen.dart'; // Route to the checkout screen

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> itemMap;

  const ItemDetailScreen({super.key, required this.itemMap});

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

  void _onBuyPressed(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(item: item),
      ),
    );
    
    if (result == true) {
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
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
                              final isNetwork = item.hasNetworkImages;
                              final hasDecoded = item.decodedImages.isNotEmpty;
                              
                              if (!isNetwork && !hasDecoded) {
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

                              final imageProvider = isNetwork
                                  ? CachedNetworkImageProvider(item.imageUrls[index]) as ImageProvider
                                  : MemoryImage(item.decodedImages[index]) as ImageProvider;
                              
                              final heroTag = 'market_item_${item.id}_$index';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenImageViewer(
                                        imageProvider: imageProvider,
                                        heroTag: heroTag,
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: heroTag,
                                  child: isNetwork
                                      ? CachedNetworkImage(
                                          imageUrl: item.imageUrls[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 250,
                                          progressIndicatorBuilder: (context, url, downloadProgress) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: downloadProgress.progress,
                                                color: isDark
                                                    ? MarketplaceTheme.darkAccentCyan
                                                    : MarketplaceTheme.lightAccent,
                                              ),
                                            );
                                          },
                                          errorWidget: (context, url, error) {
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
                                        )
                                      : Image.memory(
                                          item.decodedImages[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 250,
                                        ),
                                ),
                              );
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
                                          : Colors.white.withValues(alpha: 0.5),
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
                                        .withValues(alpha: 0.2)
                                    : MarketplaceTheme.lightAccent
                                        .withValues(alpha: 0.2),
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
                        Row(
                          children: [
                            Text(
                              'Seller: ${item.user?.name ?? "Unknown"}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF00B894) : const Color(0xFF2E7D32)).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: (isDark ? const Color(0xFF00B894) : const Color(0xFF2E7D32)).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                (item.user?.role ?? 'User').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF00B894) : const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                            if (item.user?.currentLevel != null) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.military_tech_outlined, size: 16, color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent),
                            ],
                          ],
                        ),
                        if (item.user?.badges != null && item.user!.badges!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: item.user!.badges!.map<Widget>((b) {
                              final String badgeName = b['badgeName'] ?? 'Badge';
                              IconData icon = Icons.workspace_premium;
                              Color color = Colors.green;
                              if (badgeName.contains('First')) {
                                icon = Icons.local_mall;
                                color = Colors.orange;
                              } else if (badgeName.contains('Hero')) {
                                icon = Icons.emoji_events;
                                color = Colors.amber;
                              } else if (badgeName.contains('Trusted')) {
                                icon = Icons.verified_user;
                                color = Colors.deepPurple;
                              } else if (badgeName.contains('Master')) {
                                icon = Icons.workspace_premium;
                                color = Colors.teal;
                              } else if (badgeName.contains('Bronze')) {
                                icon = Icons.shield_outlined;
                                color = Colors.brown;
                              } else if (badgeName.contains('Silver')) {
                                icon = Icons.shield_outlined;
                                color = Colors.grey;
                              } else if (badgeName.contains('Gold')) {
                                icon = Icons.workspace_premium;
                                color = Colors.amber;
                              } else if (badgeName.contains('Platinum')) {
                                icon = Icons.diamond_outlined;
                                color = Colors.teal;
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: color.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, size: 10, color: color),
                                    const SizedBox(width: 3),
                                    Text(
                                      badgeName,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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

