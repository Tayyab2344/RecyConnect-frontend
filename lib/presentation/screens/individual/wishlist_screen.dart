import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/listing_model.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<int> _savedItemIds = [];
  final List<Map<String, dynamic>> _savedItems = [
    {
      'id': 1,
      'materialType': 'Plastic',
      'weight': 5.0,
      'location': 'Islamabad, Pakistan',
      'sellerName': 'John Doe',
      'addedDate': '2 days ago',
    },
    {
      'id': 2,
      'materialType': 'Metal',
      'weight': 8.0,
      'location': 'Rawalpindi, Pakistan',
      'sellerName': 'Jane Smith',
      'addedDate': '1 week ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  Future<void> _loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('wishlist');
    if (saved != null) {
      final List<dynamic> decoded = json.decode(saved);
      setState(() {
        _savedItemIds = decoded.cast<int>();
      });
    }
  }

  Future<void> _removeFromWishlist(int id) async {
    setState(() {
      _savedItemIds.remove(id);
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlist', json.encode(_savedItemIds));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from wishlist'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Color _getMaterialColor(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return const Color(0xFF2196F3);
      case 'paper':
        return const Color(0xFFFFA726);
      case 'metal':
        return const Color(0xFF9E9E9E);
      case 'e-waste':
        return const Color(0xFF9C27B0);
      default:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getMaterialIcon(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return Icons.recycling;
      case 'paper':
        return Icons.description;
      case 'metal':
        return Icons.build;
      case 'e-waste':
        return Icons.devices;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Saved Items'),
        elevation: 0,
        actions: [
          if (_savedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All'),
                    content: const Text('Remove all items from your wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  setState(() => _savedItemIds.clear());
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('wishlist');
                }
              },
            ),
        ],
      ),
      body: _savedItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 80,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Saved Items',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Save items from the marketplace to quickly find them later',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Browse Marketplace'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _savedItems.length,
              itemBuilder: (context, index) {
                final item = _savedItems[index];
                final materialColor = _getMaterialColor(item['materialType']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                          : AppTheme.lightGray,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Material Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: materialColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getMaterialIcon(item['materialType']),
                            color: materialColor,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Item Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: materialColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['materialType'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: materialColor,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.bookmark,
                                    size: 18,
                                    color: isDark
                                        ? AppTheme.darkPrimaryGreen
                                        : AppTheme.primaryGreen,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${item['weight']} kg',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: isDark
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.textLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['sellerName'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: isDark
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.textLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['location'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Saved ${item['addedDate']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppTheme.darkTextSecondary.withOpacity(0.7)
                                      : AppTheme.textLight.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Remove Button
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => _removeFromWishlist(item['id']),
                              icon: const Icon(Icons.close),
                              color: AppTheme.errorRed,
                              iconSize: 20,
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.chevron_right,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textLight,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
