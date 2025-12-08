import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin/admin_drawer.dart';

// Data model for material pricing
class MaterialPricing {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  int minPrice;
  int maxPrice;
  DateTime lastUpdated;

  MaterialPricing({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.minPrice,
    required this.maxPrice,
    required this.lastUpdated,
  });

  bool get isValid => minPrice > 0 && maxPrice > minPrice;

  String get priceRange => '$minPrice - $maxPrice PKR/kg';
}

class AdminPricingScreen extends StatefulWidget {
  const AdminPricingScreen({super.key});

  @override
  State<AdminPricingScreen> createState() => _AdminPricingScreenState();
}

class _AdminPricingScreenState extends State<AdminPricingScreen> {
  late List<MaterialPricing> materials;
  late List<TextEditingController> minControllers;
  late List<TextEditingController> maxControllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeMaterials();
    _initializeControllers();
  }

  void _initializeMaterials() {
    materials = [
      MaterialPricing(
        id: '1',
        name: 'Plastic',
        icon: Icons.water_drop,
        color: const Color(0xFF3B82F6),
        minPrice: 80,
        maxPrice: 120,
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MaterialPricing(
        id: '2',
        name: 'Paper',
        icon: Icons.description,
        color: const Color(0xFF10B981),
        minPrice: 40,
        maxPrice: 60,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MaterialPricing(
        id: '3',
        name: 'Metal',
        icon: Icons.build,
        color: const Color(0xFFF59E0B),
        minPrice: 140,
        maxPrice: 180,
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MaterialPricing(
        id: '4',
        name: 'E-Waste',
        icon: Icons.devices,
        color: const Color(0xFF8B5CF6),
        minPrice: 180,
        maxPrice: 240,
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  void _initializeControllers() {
    minControllers = materials
        .map((m) => TextEditingController(text: m.minPrice.toString()))
        .toList();
    maxControllers = materials
        .map((m) => TextEditingController(text: m.maxPrice.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in minControllers) {
      controller.dispose();
    }
    for (var controller in maxControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onMinPriceChanged(int index, String value) {
    final parsed = int.tryParse(value) ?? 0;
    setState(() {
      materials[index].minPrice = parsed;
    });
  }

  void _onMaxPriceChanged(int index, String value) {
    final parsed = int.tryParse(value) ?? 0;
    setState(() {
      materials[index].maxPrice = parsed;
    });
  }

  Future<void> _saveAllPrices() async {
    // Validate all materials
    for (var material in materials) {
      if (material.minPrice <= 0) {
        _showError('${material.name}: Min price must be greater than 0');
        return;
      }
      if (material.maxPrice <= material.minPrice) {
        _showError(
            '${material.name}: Max price must be greater than min price');
        return;
      }
    }

    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Update timestamps
    final now = DateTime.now();
    setState(() {
      for (var material in materials) {
        material.lastUpdated = now;
      }
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Prices updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getLastUpdatedText(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Just now';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Pricing Management',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAllPrices,
              tooltip: 'Save All Changes',
            ),
        ],
      ),
      drawer: const AdminDrawer(currentRoute: 'pricing'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            _buildPageHeader(theme, today),
            const SizedBox(height: 16),

            // Info Banner
            _buildInfoBanner(theme),
            const SizedBox(height: 24),

            // Material Price Cards
            ...List.generate(materials.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMaterialCard(theme, index),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(ThemeData theme, String today) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Material Prices",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Set estimated price ranges for waste materials',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Prices are estimated ranges per kilogram (PKR/kg)',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(ThemeData theme, int index) {
    final material = materials[index];
    final isValid = material.isValid;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: isValid ? material.color : Colors.red,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                // Material Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: material.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    material.icon,
                    color: material.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Material Name and Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: material.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Per KG',
                          style: TextStyle(
                            fontSize: 11,
                            color: material.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Today's Estimated Price Label
            Center(
              child: Column(
                children: [
                  Text(
                    "Today's Estimated Price",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Price Input Fields (Side by Side)
            Row(
              children: [
                // Min Price Field
                Expanded(
                  child: _buildPriceField(
                    theme: theme,
                    label: 'Min Price',
                    controller: minControllers[index],
                    onChanged: (value) => _onMinPriceChanged(index, value),
                    placeholder: '80',
                    color: material.color,
                  ),
                ),
                const SizedBox(width: 16),
                // Max Price Field
                Expanded(
                  child: _buildPriceField(
                    theme: theme,
                    label: 'Max Price',
                    controller: maxControllers[index],
                    onChanged: (value) => _onMaxPriceChanged(index, value),
                    placeholder: '120',
                    color: material.color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Price Range Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isValid
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isValid ? Icons.check_circle : Icons.error,
                    size: 18,
                    color: isValid ? theme.colorScheme.primary : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isValid
                        ? 'Range: ${material.minPrice} - ${material.maxPrice} PKR/kg'
                        : 'Invalid range!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isValid ? theme.colorScheme.primary : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Last Updated
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Last updated: ${_getLastUpdatedText(material.lastUpdated)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit,
                  size: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required String placeholder,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
            suffixText: 'PKR/kg',
            suffixStyle: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }
}
