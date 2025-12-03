import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class WeightCalculatorScreen extends StatefulWidget {
  const WeightCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<WeightCalculatorScreen> createState() => _WeightCalculatorScreenState();
}

class _WeightCalculatorScreenState extends State<WeightCalculatorScreen> {
  String _selectedMaterial = 'Plastic';
  String _selectedBagSize = 'Small';
  final _volumeController = TextEditingController();
  double? _estimatedWeight;

  final List<String> _materialTypes = ['Plastic', 'Paper', 'Metal', 'E-Waste'];
  
  final List<String> _bagSizes = ['Small', 'Medium', 'Large', 'Extra Large'];

  // Static density values (kg per cubic meter)
  final Map<String, double> _materialDensities = {
    'Plastic': 0.92, // Light plastic density
    'Paper': 0.70, // Loose paper density
    'Metal': 2.70, // Aluminum density
    'E-Waste': 1.50, // Mixed electronics density
  };

  // Bag volume in liters
  final Map<String, double> _bagVolumes = {
    'Small': 20, // 20 liters
    'Medium': 50, // 50 liters
    'Large': 100, // 100 liters
    'Extra Large': 200, // 200 liters
  };

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  void _calculateWeight() {
    final volume = double.tryParse(_volumeController.text);
    
    if (volume == null || volume <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid volume'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final density = _materialDensities[_selectedMaterial]!;
    final bagVolume = _bagVolumes[_selectedBagSize]!;
    
    // Convert liters to cubic meters and calculate weight
    final volumeInCubicMeters = (volume * bagVolume) / 1000;
    final weight = volumeInCubicMeters * density;

    setState(() {
      _estimatedWeight = weight;
    });
  }

  void _reset() {
    setState(() {
      _volumeController.clear();
      _estimatedWeight = null;
      _selectedMaterial = 'Plastic';
      _selectedBagSize = 'Small';
    });
  }

  Color _getMaterialColor(String material) {
    switch (material) {
      case 'Plastic':
        return const Color(0xFF2196F3);
      case 'Paper':
        return const Color(0xFFFFA726);
      case 'Metal':
        return const Color(0xFF9E9E9E);
      case 'E-Waste':
        return const Color(0xFF9C27B0);
      default:
        return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Weight Calculator'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Estimate Material Weight',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Calculate approximate weight based on material type and volume',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 32),

            // Material Type Selection
            Text(
              'Material Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: _materialTypes.length,
              itemBuilder: (context, index) {
                final material = _materialTypes[index];
                final isSelected = _selectedMaterial == material;
                final color = _getMaterialColor(material);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMaterial = material;
                      _estimatedWeight = null;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : (isDark ? AppTheme.darkCardSurface : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : (isDark
                                ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                                : AppTheme.lightGray),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        material,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? color
                              : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Bag Size Selection
            Text(
              'Bag Size',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                      : AppTheme.lightGray,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBagSize,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                  items: _bagSizes.map((String size) {
                    return DropdownMenuItem<String>(
                      value: size,
                      child: Row(
                        children: [
                          Text(size),
                          const SizedBox(width: 8),
                          Text(
                            '(${_bagVolumes[size]} L)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBagSize = newValue!;
                      _estimatedWeight = null;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Number of Bags
            Text(
              'Number of Bags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _volumeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: 'Enter number of bags',
                prefixIcon: const Icon(Icons.shopping_bag),
                suffixText: 'bags',
                suffixStyle: TextStyle(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _calculateWeight,
                icon: const Icon(Icons.calculate),
                label: const Text(
                  'Calculate Weight',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Result Display
            if (_estimatedWeight != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppTheme.darkPrimaryGreen, AppTheme.darkSecondaryGreen]
                        : [const Color(0xFF00BFA5), const Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.darkPrimaryGreen : const Color(0xFF00BFA5))
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimated Weight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkBackground : Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_estimatedWeight!.toStringAsFixed(2)} kg',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkBackground : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_volumeController.text} × $_selectedBagSize bag(s) of $_selectedMaterial',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.darkBackground.withOpacity(0.8)
                            : Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFA726).withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFFF57C00),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Note: This is an estimate based on average density values. Actual weight may vary depending on material compression and moisture content.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
