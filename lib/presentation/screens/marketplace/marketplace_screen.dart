import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/models/listing_model.dart';
import '../../../core/theme/app_colors.dart';
// Note: Removed design_tokens.dart assuming it's replaced by direct values or not widely used in this new custom UI due to specific Glass requirements.
// import '../../../core/theme/design_tokens.dart'; 

/// futuristic Marketplace Screen
/// Features: Glassmorphism, Neon/Pastel Themes, Sticky Headers, Role-Based Layouts.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  final ListingService _listingService = ListingService();
  late Future<Map<String, dynamic>> _listingsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  
  // Role-based filtering is handled server-side via JWT token.

  final List<CategoryItem> _categories = [
    CategoryItem('All', Icons.grid_view_rounded),
    CategoryItem('Plastic', Icons.local_drink_rounded),
    CategoryItem('Metal', Icons.settings_rounded),
    CategoryItem('Paper', Icons.description_rounded),
    CategoryItem('E-Waste', Icons.memory_rounded),
    CategoryItem('Glass', Icons.wine_bar_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _listingsFuture = _listingService.getListings(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        // 'All' means no filter — pass null so backend returns all materials
        material: (_selectedCategory == null || _selectedCategory == 'All') ? null : _selectedCategory,
        isMarketplace: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          // 1. Background Gradient
          _buildBackground(isDark),

          // 2. Main Content (Scrollable)
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Sticky Header (Search & Filter)
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: MarketplaceHeaderDelegate(
                    minHeight: 140,
                    maxHeight: 140,
                    child: _buildStickyHeader(isDark),
                  ),
                ),

                // Grid Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: _buildListingsGrid(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F2027), // Deep Navy
                  const Color(0xFF203A43), // Charcoal
                  const Color(0xFF2C5364), // Dark Teal
                ]
              : [
                  const Color(0xFFFFFFFF), // White
                  AppColors.pastelMint,    // Soft Mint
                  AppColors.pastelTeal.withValues(alpha: 0.3), // Faint Teal
                ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(bool isDark) {
    return GlassContainer(
      isDark: isDark,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search recyclables...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                    size: 24,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                  _loadItems();
                },
              ),
            ),
            const SizedBox(height: 12),
            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == (cat.name == 'All' ? null : cat.name);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildCategoryChip(cat, isSelected, isDark),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(CategoryItem cat, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = cat.name == 'All' ? null : cat.name;
        });
        _loadItems();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.neonCyan.withValues(alpha: 0.2) : AppColors.primaryGreen)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.neonCyan : Colors.transparent)
                : (isDark ? Colors.white12 : Colors.black12),
          ),
          boxShadow: isSelected && !isDark
              ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Icon(cat.icon, size: 16, 
               color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.darkGrey)),
            const SizedBox(width: 6),
            Text(
              cat.name,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.darkGrey),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsGrid(bool isDark) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _listingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
              child: Center(
                  child: CircularProgressIndicator(color: isDark ? AppColors.neonCyan : AppColors.primaryGreen)));
        }
        
        // Error or Empty handling simplified for brevity
        final listings = (snapshot.data?['listings'] as List<Listing>?) ?? [];
        if (listings.isEmpty) {
           return SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.only(top: 50),
               child: Center(
                 child: Text("No items found", 
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
               ),
             ),
           );
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // Taller cards
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildListingCard(listings[index], isDark),
            childCount: listings.length,
          ),
        );
      },
    );
  }

  Widget _buildListingCard(Listing listing, bool isDark) {
    return GlassContainer(
      isDark: isDark,
      borderRadius: BorderRadius.circular(20),
      border: isDark ? Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
             flex: 4,
             child: Stack(
               fit: StackFit.expand,
               children: [
                 ClipRRect(
                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                   child: listing.hasNetworkImages
                       ? Image.network(
                           listing.imageUrls.first,
                           fit: BoxFit.cover,
                           width: double.infinity,
                           loadingBuilder: (context, child, loadingProgress) {
                             if (loadingProgress == null) return child;
                             return Container(
                               color: isDark ? Colors.black26 : Colors.grey.shade200,
                               child: Center(
                                 child: CircularProgressIndicator(
                                   strokeWidth: 2,
                                   color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                                 ),
                               ),
                             );
                           },
                           errorBuilder: (context, error, stackTrace) {
                             return Container(
                               color: isDark ? Colors.black26 : Colors.grey.shade200,
                               child: Center(
                                 child: Icon(Icons.broken_image_outlined,
                                     color: isDark ? Colors.white24 : Colors.grey),
                               ),
                             );
                           },
                         )
                       : listing.decodedImages.isNotEmpty
                           ? Image.memory(listing.decodedImages.first, fit: BoxFit.cover)
                           : Container(
                               color: isDark ? Colors.black26 : Colors.grey.shade200,
                               child: Icon(Icons.image, color: isDark ? Colors.white24 : Colors.grey),
                             ),
                 ),
                 // Material Badge
                 Positioned(
                   top: 8, left: 8,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.black.withValues(alpha: 0.6),
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: isDark ? AppColors.neonGreen : Colors.transparent, width: 0.5),
                     ),
                     child: Text(
                       listing.materialType,
                       style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                     ),
                   ),
                 )
               ],
             ),
          ),
          // Content
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                     listing.materialType.toUpperCase(), 
                     style: TextStyle(
                       color: isDark ? Colors.white : AppColors.darkText,
                       fontWeight: FontWeight.bold,
                       fontSize: 14,
                     ),
                   ),
                   // Weight & Price
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         "${listing.estimatedWeight}kg", 
                         style: TextStyle(
                           color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(
                           color: AppColors.primaryGreen.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(4),
                         ),
                         child: Row(
                           children: [
                             const Icon(Icons.eco, size: 10, color: AppColors.primaryGreen),
                             const SizedBox(width: 2),
                             // Simulated Eco Points calc
                             Text("${(listing.estimatedWeight * 10).toInt()} Pts", 
                                style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen)),
                           ],
                         ),
                       )
                     ],
                   ),
                   // Action Button
                   SizedBox(
                     width: double.infinity,
                     height: 32,
                     child: ElevatedButton(
                       onPressed: () {},
                       style: ElevatedButton.styleFrom(
                         backgroundColor: isDark ? Colors.transparent : AppColors.primaryGreen,
                         shadowColor: Colors.transparent,
                         side: isDark ? const BorderSide(color: AppColors.neonGreen) : BorderSide.none,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         padding: EdgeInsets.zero,
                       ),
                       child: Text(
                         "Buy",
                         style: TextStyle(
                            fontSize: 12, 
                            color: isDark ? AppColors.neonGreen : Colors.white,
                            fontWeight: FontWeight.bold
                         ),
                       ),
                     ),
                   )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS
// ---------------------------------------------------------------------------

class GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const GlassContainer({
    super.key, 
    required this.child, 
    required this.isDark, 
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
               ? Colors.black.withValues(alpha: 0.4) 
               : Colors.white.withValues(alpha: 0.7),
            borderRadius: borderRadius,
            border: border ?? Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class MarketplaceHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  MarketplaceHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(MarketplaceHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
           minHeight != oldDelegate.minHeight ||
           child != oldDelegate.child;
  }
}

class CategoryItem {
  final String name;
  final IconData icon;
  CategoryItem(this.name, this.icon);
}
