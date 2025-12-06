import 'package:flutter/material.dart';
import '../../../core/theme/marketplace_theme.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/models/order_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/marketplace/glass_card.dart';
import '../../widgets/marketplace/neon_button.dart';
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
        title: const Text('Marketplace'),
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
                    ? const Center(child: CircularProgressIndicator())
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
                                    childAspectRatio: 0.75,
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              child: Row(
                children: [
                   Icon(Icons.search,
                      color: isDark ? Colors.white70 : Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search items...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87),
                      onChanged: (val) {
                        _searchQuery = val;
                        // Add debounce in real app
                        _loadItems();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Categories
          SizedBox(
            height: 40,
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
    final activeColor =
        isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterMaterial = label == 'All' ? null : label;
          _loadItems();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? activeColor : (isDark ? Colors.black26 : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.white70 : Colors.black87),
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
          // Image / Icon Placeholder
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: isDark ? Colors.black12 : Colors.grey.shade100,
              child: Icon(
                _getIconForMaterial(item.materialType),
                size: 48,
                color: isDark ? MarketplaceTheme.darkAccentCyan : Colors.grey,
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
                      Text(
                        item.materialType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? MarketplaceTheme.darkAccentGreen
                              : MarketplaceTheme.lightAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.estimatedWeight} kg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
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
