import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/admin_colors.dart';
import '../../widgets/admin/admin_drawer.dart';

// Data model for material pricing
class MaterialPricing {
  final String material;
  final IconData icon;
  final Color color;
  int buyingPrice;
  int sellingPrice;
  DateTime lastUpdated;

  // Default values for reset
  final int defaultBuyingPrice;
  final int defaultSellingPrice;

  MaterialPricing({
    required this.material,
    required this.icon,
    required this.color,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.lastUpdated,
    required this.defaultBuyingPrice,
    required this.defaultSellingPrice,
  });

  int get profitMargin => sellingPrice - buyingPrice;

  double get profitPercentage =>
      buyingPrice > 0 ? ((sellingPrice - buyingPrice) / buyingPrice * 100) : 0;

  bool get isValid => buyingPrice > 0 && sellingPrice > buyingPrice;

  void resetToDefaults() {
    buyingPrice = defaultBuyingPrice;
    sellingPrice = defaultSellingPrice;
    lastUpdated = DateTime.now();
  }
}

class AdminPricingScreen extends StatefulWidget {
  const AdminPricingScreen({super.key});

  @override
  State<AdminPricingScreen> createState() => _AdminPricingScreenState();
}

class _AdminPricingScreenState extends State<AdminPricingScreen> {
  late List<MaterialPricing> pricingData;
  late List<TextEditingController> buyingControllers;
  late List<TextEditingController> sellingControllers;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializePricingData();
    _initializeControllers();
  }

  void _initializePricingData() {
    pricingData = [
      MaterialPricing(
        material: 'Plastic',
        icon: Icons.water_drop,
        color: const Color(0xFF3B82F6),
        buyingPrice: 100,
        sellingPrice: 120,
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        defaultBuyingPrice: 100,
        defaultSellingPrice: 120,
      ),
      MaterialPricing(
        material: 'Paper',
        icon: Icons.description,
        color: const Color(0xFF10B981),
        buyingPrice: 50,
        sellingPrice: 65,
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        defaultBuyingPrice: 50,
        defaultSellingPrice: 65,
      ),
      MaterialPricing(
        material: 'Metal',
        icon: Icons.build,
        color: const Color(0xFFF59E0B),
        buyingPrice: 150,
        sellingPrice: 180,
        lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
        defaultBuyingPrice: 150,
        defaultSellingPrice: 180,
      ),
      MaterialPricing(
        material: 'E-Waste',
        icon: Icons.devices,
        color: const Color(0xFF8B5CF6),
        buyingPrice: 200,
        sellingPrice: 240,
        lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
        defaultBuyingPrice: 200,
        defaultSellingPrice: 240,
      ),
    ];
  }

  void _initializeControllers() {
    buyingControllers = pricingData
        .map((p) => TextEditingController(text: p.buyingPrice.toString()))
        .toList();
    sellingControllers = pricingData
        .map((p) => TextEditingController(text: p.sellingPrice.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in buyingControllers) {
      controller.dispose();
    }
    for (var controller in sellingControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _allValid => pricingData.every((p) => p.isValid);

  String? _getBuyingError(int index) {
    final price = pricingData[index].buyingPrice;
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  String? _getSellingError(int index) {
    final buying = pricingData[index].buyingPrice;
    final selling = pricingData[index].sellingPrice;
    if (selling <= 0) {
      return 'Price must be greater than 0';
    }
    if (selling <= buying) {
      return 'Must be greater than buying price';
    }
    return null;
  }

  void _onBuyingPriceChanged(int index, String value) {
    final parsed = int.tryParse(value) ?? 0;
    setState(() {
      pricingData[index].buyingPrice = parsed;
      _hasChanges = true;
    });
  }

  void _onSellingPriceChanged(int index, String value) {
    final parsed = int.tryParse(value) ?? 0;
    setState(() {
      pricingData[index].sellingPrice = parsed;
      _hasChanges = true;
    });
  }

  Future<void> _saveAllPrices() async {
    if (!_allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please fix errors before saving'),
            ],
          ),
          backgroundColor: AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Update timestamps
    final now = DateTime.now();
    for (var pricing in pricingData) {
      pricing.lastUpdated = now;
    }

    setState(() {
      _isSaving = false;
      _hasChanges = false;
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
          backgroundColor: AdminColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AdminColors.warning, size: 28),
            SizedBox(width: 12),
            Text('Reset Prices?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to reset all prices to default values? This cannot be undone.',
          style: TextStyle(color: AdminColors.textSecondary),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminColors.textSecondary,
              side: const BorderSide(color: AdminColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      for (int i = 0; i < pricingData.length; i++) {
        pricingData[i].resetToDefaults();
        buyingControllers[i].text = pricingData[i].buyingPrice.toString();
        sellingControllers[i].text = pricingData[i].sellingPrice.toString();
      }
      _hasChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 12),
            Text('Prices reset to defaults'),
          ],
        ),
        backgroundColor: AdminColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text(
          'Pricing Management',
          style: TextStyle(
            color: AdminColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AdminColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminColors.textWhite),
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
              onPressed: _hasChanges ? _saveAllPrices : null,
              tooltip: 'Save All Changes',
            ),
        ],
      ),
      drawer: const AdminDrawer(currentRoute: '/admin/pricing'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            _buildPageHeader(),
            const SizedBox(height: 20),

            // Info Card
            _buildInfoCard(),
            const SizedBox(height: 24),

            // Material Price Cards
            ..._buildPricingCards(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showResetConfirmation,
        backgroundColor: AdminColors.warning,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh),
        label: const Text('Reset to Defaults'),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Material Pricing',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Set buying and selling prices for waste materials',
          style: TextStyle(
            fontSize: 14,
            color: AdminColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AdminColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AdminColors.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Prices are per kilogram (PKR/kg)',
              style: TextStyle(
                color: AdminColors.info,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPricingCards() {
    return List.generate(pricingData.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildMaterialCard(index),
      );
    });
  }

  Widget _buildMaterialCard(int index) {
    final pricing = pricingData[index];
    final buyingError = _getBuyingError(index);
    final sellingError = _getSellingError(index);
    final hasError = buyingError != null || sellingError != null;

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: hasError ? AdminColors.error : pricing.color,
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
                    color: pricing.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    pricing.icon,
                    color: pricing.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Material Name and Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pricing.material,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: pricing.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Recyclable Material',
                        style: TextStyle(
                          fontSize: 11,
                          color: pricing.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pricing Section (2 columns)
            Row(
              children: [
                // Buying Price Column
                Expanded(
                  child: _buildPriceField(
                    label: 'BUYING PRICE',
                    controller: buyingControllers[index],
                    onChanged: (value) => _onBuyingPriceChanged(index, value),
                    error: buyingError,
                    color: pricing.color,
                  ),
                ),
                const SizedBox(width: 16),
                // Selling Price Column
                Expanded(
                  child: _buildPriceField(
                    label: 'SELLING PRICE',
                    controller: sellingControllers[index],
                    onChanged: (value) => _onSellingPriceChanged(index, value),
                    error: sellingError,
                    color: pricing.color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Profit Margin Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: pricing.isValid
                    ? AdminColors.success.withValues(alpha: 0.1)
                    : AdminColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    pricing.isValid
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 16,
                    color: pricing.isValid
                        ? AdminColors.success
                        : AdminColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Profit Margin: ${pricing.profitMargin} PKR/kg (${pricing.profitPercentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: pricing.isValid
                          ? AdminColors.success
                          : AdminColors.error,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Last Updated Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AdminColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated: ${_formatDate(pricing.lastUpdated)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdminColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required String? error,
    required Color color,
  }) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AdminColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AdminColors.textPrimary,
          ),
          decoration: InputDecoration(
            suffixText: 'PKR/kg',
            suffixStyle: const TextStyle(
              fontSize: 14,
              color: AdminColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AdminColors.error : AdminColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AdminColors.error : AdminColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AdminColors.error : AdminColors.primaryGreen,
                width: 2,
              ),
            ),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 11),
            filled: true,
            fillColor: hasError
                ? AdminColors.error.withValues(alpha: 0.05)
                : AdminColors.surfaceLight.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
