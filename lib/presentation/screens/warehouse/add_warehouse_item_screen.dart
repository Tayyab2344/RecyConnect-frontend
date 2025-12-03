import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';

class AddWarehouseItemScreen extends StatefulWidget {
  const AddWarehouseItemScreen({super.key});

  @override
  State<AddWarehouseItemScreen> createState() => _AddWarehouseItemScreenState();
}

class _AddWarehouseItemScreenState extends State<AddWarehouseItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _materialController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _processingCostController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _supplierController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  
  File? _selectedImage;
  String _aiCategory = '';
  double _profitPerKg = 0;
  double _profitMargin = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _materialController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _processingCostController.dispose();
    _sellingPriceController.dispose();
    _supplierController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    final purchase = double.tryParse(_purchasePriceController.text) ?? 0;
    final processing = double.tryParse(_processingCostController.text) ?? 0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0;
    
    setState(() {
      _profitPerKg = selling - (purchase + processing);
      _profitMargin = selling > 0 ? (_profitPerKg / selling) * 100 : 0;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isProcessing = true;
      });
      
      // Simulate AI classification
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _aiCategory = 'PET'; // Mock AI classification
        _categoryController.text = _aiCategory;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        elevation: 0,
        title: Text(
          'Add Inventory Item',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(isDark),
              const SizedBox(height: 24),
              _buildMaterialDetailsSection(isDark),
              const SizedBox(height: 24),
              _buildFinancialSection(isDark),
              const SizedBox(height: 24),
              _buildProfitCalculator(isDark),
              const SizedBox(height: 24),
              _buildSupplierSection(isDark),
              const SizedBox(height: 32),
              _buildSubmitButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Upload Material Photo',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI will classify the material',
                          style: TextStyle(
                            fontSize: 12,
                            color: (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
            ),
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI is classifying...',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ],
          if (_aiCategory.isNotEmpty && !_isProcessing) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AI Detected: $_aiCategory',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaterialDetailsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Material Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Material Type', _materialController, 'e.g., Plastic', isDark),
          const SizedBox(height: 16),
          _buildTextField('Category', _categoryController, 'e.g., PET', isDark, readOnly: _aiCategory.isNotEmpty),
          const SizedBox(height: 16),
          _buildTextField('Quantity (kg)', _quantityController, '0', isDark, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField('Reorder Level (kg)', _reorderLevelController, '100', isDark, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildFinancialSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Purchase Price per kg',
            _purchasePriceController,
            '0',
            isDark,
            keyboardType: TextInputType.number,
            prefix: 'PKR',
            onChanged: (_) => _calculateProfit(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Processing Cost per kg',
            _processingCostController,
            '0',
            isDark,
            keyboardType: TextInputType.number,
            prefix: 'PKR',
            onChanged: (_) => _calculateProfit(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Selling Price per kg',
            _sellingPriceController,
            '0',
            isDark,
            keyboardType: TextInputType.number,
            prefix: 'PKR',
            onChanged: (_) => _calculateProfit(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitCalculator(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.darkPrimaryGreen, AppTheme.darkSecondaryGreen]
              : [AppTheme.primaryGreen, const Color(0xFF45A049)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Profit Calculator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Profit per kg',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PKR ${_profitPerKg.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Profit Margin',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_profitMargin.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supplier Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Supplier Name', _supplierController, 'e.g., ABC Traders', isDark),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    bool isDark, {
    TextInputType? keyboardType,
    String? prefix,
    Function(String)? onChanged,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onChanged: onChanged,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix != null ? '$prefix ' : null,
            hintStyle: TextStyle(
              color: (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight).withOpacity(0.5),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Item added successfully!\n'
                  'Profit: PKR ${_profitPerKg.toStringAsFixed(2)}/kg (${_profitMargin.toStringAsFixed(1)}% margin)',
                ),
                backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Add to Inventory',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
