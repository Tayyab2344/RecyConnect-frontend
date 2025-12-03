import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/static_data.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/models/order_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class BrowseMarketplaceScreen extends StatefulWidget {
  const BrowseMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<BrowseMarketplaceScreen> createState() => _BrowseMarketplaceScreenState();
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
  final double _maxPrice = 10000;
  final double _maxWeight = 1000;

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
          _errorMessage = null;
        });
      }
    } catch (e) {
      print('Error loading items: $e');
      if (mounted) {
        final userFriendlyError = ErrorMessageHelper.getUserFriendlyError(e);
        setState(() {
          _isLoading = false;
          _errorMessage = userFriendlyError;
        });
        
        ErrorMessageHelper.showErrorSnackBar(
          context,
          message: userFriendlyError,
          onRetry: _loadItems,
        );
      }
    }
  }

  void _filterItems() {
    _loadItems();
  }

  Future<void> _handleBuyNow(Listing item) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to buy this item?'),
            const SizedBox(height: 12),
            Text('Item: ${item.materialType} (${item.estimatedWeight} kg)'),
            Text('Seller: ${item.user?.name ?? "Unknown"}'),
            const SizedBox(height: 12),
            const Text('Payment Method: Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Buy'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final newOrder = Order(
          id: 0, // Backend assigns
          buyerId: 0, // Backend should assign from token
          sellerId: item.userId,
          materialType: item.materialType,
          weight: item.estimatedWeight,
          pickupAddress: item.pickupAddress,
          latitude: item.latitude,
          longitude: item.longitude,
          locationMethod: item.locationMethod,
          paymentMethod: 'COD',
          status: 'PENDING',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _orderService.createOrder(newOrder);

        // Close loading
        if (mounted) Navigator.pop(context);
        
        // Close details sheet
        if (mounted) Navigator.pop(context);

        // Show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh listings (item might be removed or status changed)
          _loadItems();
        }
      } catch (e) {
        // Close loading
        if (mounted) Navigator.pop(context);
        
        if (mounted) {
          ErrorMessageHelper.showErrorSnackBar(
            context,
            message: 'Failed to place order: ${e.toString()}',
          );
        }
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Price Range
                Text(
                  'Price Range (Rs)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: _maxPrice,
                  divisions: 100,
                  activeColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  labels: RangeLabels(
                    'Rs ${_priceRange.start.round()}',
                    'Rs ${_priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setModalState(() => _priceRange = values);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rs 0', style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)),
                    Text('Rs ${_maxPrice.round()}+', style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Weight Range
                Text(
                  'Weight Range (kg/gal)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                RangeSlider(
                  values: _weightRange,
                  min: 0,
                  max: _maxWeight,
                  divisions: 100,
                  activeColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  labels: RangeLabels(
                    '${_weightRange.start.round()}',
                    '${_weightRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setModalState(() => _weightRange = values);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0', style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)),
                    Text('${_maxWeight.round()}+', style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)),
                  ],
                ),
                
                const Spacer(),
                
                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Update main state ranges
                      setState(() {
                        _priceRange = _priceRange;
                        _weightRange = _weightRange;
                      });
                      _filterItems();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Marketplace'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search materials or sellers...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      ),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      // Debounce could be added here
                      _filterItems();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : Colors.grey.shade200,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    ),
                    onPressed: _showFilterDialog,
                  ),
                ),
              ],
            ),
          ),

          // Material Filter Chips
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMaterialChip('All', isDark),
                const SizedBox(width: 8),
                _buildMaterialChip('Plastic', isDark),
                const SizedBox(width: 8),
                _buildMaterialChip('Paper', isDark),
                const SizedBox(width: 8),
                _buildMaterialChip('Metal', isDark),
                const SizedBox(width: 8),
                _buildMaterialChip('E-Waste', isDark),
              ],
            ),
          ),

          // Listings Count & Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_items.length} Listings available',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _sortBy,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: _isLoading
                ? // Skeleton loading (better UX than spinner)
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 6, // Show 6 skeleton cards
                    itemBuilder: (context, index) => const ListItemSkeleton(),
                  )
                : _errorMessage != null
                    ? // Error state with retry
                      ErrorStateWidget(
                        title: 'Failed to load listings',
                        message: _errorMessage!,
                        onRetry: _loadItems,
                      )
                    : _items.isEmpty
                        ? // Empty state based on context
                          _searchQuery.isNotEmpty || _filterMaterial != null
                              ? SearchNoResultsEmptyState(
                                  searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
                                )
                              : EmptyStateWidget(
                                  icon: Icons.storefront_outlined,
                                  iconColor: AppTheme.primaryGreen,
                                  title: 'No listings available',
                                  message: 'Check back later for new items\nor try different filters.',
                                )
                        : // Show items
                          RefreshIndicator(
                            onRefresh: _loadItems,
                            color: AppTheme.primaryGreen,
                            child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildProductCard(item, isDark);
                        },
                      ),
                            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialChip(String material, bool isDark) {
    final isSelected = _filterMaterial == material || (_filterMaterial == null && material == 'All');
    final colors = _getMaterialChipColor(material);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (material == 'All') {
            _filterMaterial = null;
          } else {
            _filterMaterial = isSelected ? null : material;
          }
          _filterItems();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors['background']
              : (isDark ? AppTheme.darkCardSurface : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? colors['border']!
                : (isDark
                    ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                    : Colors.grey.shade300),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colors['border']!.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            material,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? colors['text']
                  : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, Color> _getMaterialChipColor(String material) {
    switch (material) {
      case 'All':
        return {
          'background': const Color(0xFFE8F5E9),
          'border': const Color(0xFF4CAF50),
          'text': const Color(0xFF2E7D32),
        };
      case 'Plastic':
        return {
          'background': const Color(0xFFE3F2FD),
          'border': const Color(0xFF2196F3),
          'text': const Color(0xFF1976D2),
        };
      case 'Paper':
        return {
          'background': const Color(0xFFFFF3E0),
          'border': const Color(0xFFFFA726),
          'text': const Color(0xFFF57C00),
        };
      case 'Metal':
        return {
          'background': const Color(0xFFF5F5F5),
          'border': const Color(0xFF9E9E9E),
          'text': const Color(0xFF616161),
        };
      case 'E-Waste':
        return {
          'background': const Color(0xFFF3E5F5),
          'border': const Color(0xFF9C27B0),
          'text': const Color(0xFF7B1FA2),
        };
      default:
        return {
          'background': Colors.grey.shade100,
          'border': Colors.grey.shade400,
          'text': Colors.grey.shade700,
        };
    }
  }

  Widget _buildProductCard(Listing item, bool isDark) {
    final materialType = item.materialType;
    final chipColors = _getMaterialChipColor(materialType);
    final imageUrl = _getMaterialImageUrl(materialType);

    return GestureDetector(
      onTap: () => _showListingDetails(item, isDark),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? AppTheme.darkSurface : Colors.grey.shade200,
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipColors['background'],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        materialType,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: chipColors['text'],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.estimatedWeight} kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        _formatDate(item.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Seller Info
                  if (item.user != null)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray,
                          child: Icon(Icons.person, size: 12, color: isDark ? Colors.white : Colors.grey),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.user!.name ?? 'Unknown Seller',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    item.notes ?? 'No description available',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location and Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.pickupAddress,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // View Details Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkPrimaryGreen.withOpacity(0.1) : AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showListingDetails(Listing item, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Listing Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _getMaterialImageUrl(item.materialType),
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 240,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.image, size: 50)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Main Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.materialType,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.estimatedWeight} kg',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Seller Info Section
                    Text(
                      'Seller Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.person, 'Name', item.user?.name ?? 'Unknown', isDark),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.email, 'Email', item.user?.email ?? 'Hidden', isDark),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.phone, 'Contact', item.user?.contactNo ?? 'Hidden', isDark),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Location Section
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : Colors.grey.shade200,
                        ),
                      ),
                      child: _buildDetailRow(Icons.location_on, 'Address', item.pickupAddress, isDark),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Notes Section
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          item.notes!,
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
            
            // Buy Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleBuyNow(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkPrimaryGreen.withOpacity(0.1) : AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMaterialImageUrl(String materialType) {
    switch (materialType.toLowerCase()) {
      case 'plastic':
        return 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=400';
      case 'paper':
        return 'https://images.unsplash.com/photo-1594843310968-da9f82e6f8c8?w=400';
      case 'metal':
        return 'https://images.unsplash.com/photo-1602513787370-c4a2d8b8b186?w=400';
      case 'e-waste':
        return 'https://images.unsplash.com/photo-1595343426704-dd11ab53c3e2?w=400';
      default:
        return 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400';
    }
  }
}
