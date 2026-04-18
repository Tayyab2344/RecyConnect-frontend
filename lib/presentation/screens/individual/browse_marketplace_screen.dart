import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/marketplace_theme.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/models/order_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/marketplace/glass_card.dart';
import '../../widgets/marketplace/neon_button.dart';
import '../../widgets/recycle_loader.dart';
import 'marketplace/item_detail_screen.dart';

class BrowseMarketplaceScreen extends StatefulWidget {
  const BrowseMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<BrowseMarketplaceScreen> createState() =>
      _BrowseMarketplaceScreenState();
}

class _BrowseMarketplaceScreenState extends State<BrowseMarketplaceScreen> {
  final ListingService _listingService = ListingService();
  final OrderService _orderService = OrderService();
  List<Listing> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  String? _filterMaterial;
  String _searchQuery = '';
  String _sortBy = 'Most Recent';

  // Advanced Filters
  RangeValues _priceRange = const RangeValues(0, 10000);
  RangeValues _weightRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _listingService.getListings(
        material: _filterMaterial == 'All' ? null : _filterMaterial,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        isMarketplace: true,
      );

      if (mounted) {
        setState(() {
          _items = (result['listings'] as List<Listing>);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = ErrorMessageHelper.getUserFriendlyError(e);
        });
      }
    }
  }

  void _onItemTap(Listing item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    ).then((_) => _loadItems()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // For glass effect
      appBar: AppBar(
        title: Text(
          'Marketplace',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: Container(
            decoration: MarketplaceTheme.getGlassDecoration(
              isDark: isDark,
              radius: 0,
              opacity: 0.8,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              // TODO: Implement advanced filter dialog with glass theme
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: MarketplaceTheme.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildStickyFilterBar(isDark),
              Expanded(
                child: _isLoading
                    ? RecycleLoader.centered()
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _items.isEmpty
                            ? const Center(child: Text('No listings found'))
                            : RefreshIndicator(
                                onRefresh: _loadItems,
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.62,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                  ),
                                  itemCount: _items.length,
                                  itemBuilder: (context, index) {
                                    return _buildGlassItemCard(
                                        _items[index], isDark);
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyFilterBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Search Bar - Premium Glassmorphism Style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.8),
                    border: Border.all(
                      color: isDark
                          ? AppColors.neonCyan.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _loadItems();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Categories - Premium Chips Style
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('All', isDark),
                _buildCategoryChip('Plastic', isDark),
                _buildCategoryChip('Metal', isDark),
                _buildCategoryChip('Paper', isDark),
                _buildCategoryChip('E-Waste', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isDark) {
    final isSelected =
        _filterMaterial == label || (_filterMaterial == null && label == 'All');
    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterMaterial = label == 'All' ? null : label;
          _loadItems();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? [AppColors.neonGreen, AppColors.neonCyan]
                      : [AppColors.primaryGreen, const Color(0xFF45A049)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.8)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? accentColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? const Color(0xFF0A1628) : Colors.white)
                : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassItemCard(Listing item, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () => _onItemTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: item.hasNetworkImages
                    ? Image.network(
                        item.imageUrls.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
                              size: 36,
                              color: isDark ? MarketplaceTheme.darkAccentCyan : Colors.grey,
                            ),
                          );
                        },
                      )
                    : item.decodedImages.isNotEmpty
                        ? Image.memory(
                            item.decodedImages.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Center(
                            child: Icon(
                              _getIconForMaterial(item.materialType),
                              size: 48,
                              color: isDark ? MarketplaceTheme.darkAccentCyan : Colors.grey,
                            ),
                          ),
              ),
            ),
          ),
          // Info
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Text(
                        item.materialTypeDisplay.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? MarketplaceTheme.darkAccentGreen
                              : MarketplaceTheme.lightAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Title
                      Text(
                        item.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Seller name
                      if (item.user?.name != null)
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 12,
                                color: isDark ? Colors.white38 : Colors.black45),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Sold by ${item.user!.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : Colors.black45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      // Price & weight row
                      Row(
                        children: [
                          Text(
                            'Rs ${(item.estimatedWeight * 20).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? MarketplaceTheme.darkAccentGreen
                                  : MarketplaceTheme.lightAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '· ${item.estimatedWeight} kg',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  NeonButton(
                    text: 'BUY',
                    height: 36,
                    onPressed: () => _onItemTap(item),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMaterial(String type) {
    switch (type.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink;
      case 'metal':
        return Icons.build;
      case 'paper':
        return Icons.description;
      case 'e-waste':
        return Icons.computer;
      default:
        return Icons.recycling;
    }
  }
}
