import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recyconnect/core/models/listing_model.dart';
import 'package:recyconnect/core/services/auth_service.dart';
import 'package:recyconnect/core/services/image_classifier_service.dart';
import 'package:recyconnect/core/services/listing_service.dart';
import 'package:recyconnect/core/theme/marketplace_theme.dart';
import 'package:recyconnect/presentation/widgets/marketplace/glass_card.dart';
import 'package:recyconnect/presentation/widgets/marketplace/neon_button.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ListingService _listingService = ListingService();
  // Using Provider for AuthService instead of local instance


  // Scroll Controller
  final ScrollController _scrollController = ScrollController();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State Variables
  List<XFile> _selectedImages = [];
  String _selectedMaterial = 'Plastic';
  String _locationMethod = 'manual';
  bool _requestCollector = false;
  bool _isAnalyzing = false;
  bool _isSubmitting = false;

  // Animation for "AI Scanning"
  late AnimationController _scanController;

  // Material Rates (Mock Data)
  final Map<String, double> _materialRates = {
    'Plastic': 20.0,
    'Paper': 15.0,
    'Metal': 40.0,
    'E-Waste': 100.0,
    'Glass': 10.0,
    'Clothing': 25.0,
    'Other': 5.0,
  };

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadUserLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _addressController.dispose();
    _scanController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Logic Implementations ---

  Future<void> _loadUserLocation() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await authService.fetchProfile();
      if (response['success'] == true) {
        final data = response['data']['data'];
        final addressParts = <String>[];
        if (data['address'] != null) addressParts.add(data['address']);
        if (data['city'] != null) addressParts.add(data['city']);
        
        if (addressParts.isNotEmpty) {
          setState(() {
            _addressController.text = addressParts.join(', ');
            // Force manual so user can edit if they want, but it's pre-filled
            _locationMethod = 'manual';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _pickImages() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Photos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: MarketplaceTheme.lightAccent),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: MarketplaceTheme.lightAccent),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          // Only 1 image allowed — replace any existing
          _selectedImages = [image];
        });
        // Trigger real AI Classification
        _runAIClassification();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _runAIClassification() async {
    setState(() => _isAnalyzing = true);
    _scanController.repeat(reverse: true);

    try {
      final classifier = ImageClassifierService.instance;
      await classifier.initialize();

      if (_selectedImages.isNotEmpty && classifier.isReady) {
        final imageFile = File(_selectedImages.first.path);
        final result = await classifier.classifyImage(imageFile);

        if (!mounted) return;

        if (result != null) {
          setState(() {
            _isAnalyzing = false;
            _scanController.stop();
            _scanController.reset();
            _selectedMaterial = result.displayName;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI Detected: ${result.displayName} (${result.confidencePercent} confidence)',
                    ),
                  ),
                ],
              ),
              backgroundColor: MarketplaceTheme.lightAccent,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      }
    } catch (e) {
      print('AI Classification error: $e');
    }

    // Fallback if classification fails
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _scanController.stop();
      _scanController.reset();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not auto-detect material. Please select manually.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  double get _estimatedValue {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final rate = _materialRates[_selectedMaterial] ?? 0;
    return weight * rate;
  }

  Future<void> _publishListing() async {
    if (!_formKey.currentState!.validate()) {
       // Scroll to top to show errors if needed, or rely on field error text
       return;
    }
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Convert Images to Base64
      List<String> base64Images = [];
      for (var img in _selectedImages) {
        final bytes = await img.readAsBytes();
        base64Images.add(base64Encode(bytes));
      }

      // 2. Create Listing Object
      final listing = Listing(
        id: 0,
        userId: 0, // Backend sets this
        materialType: _selectedMaterial.toLowerCase(),
        estimatedWeight: double.parse(_weightController.text),
        pickupAddress: _addressController.text,
        locationMethod: _locationMethod,
        title: _titleController.text.trim(),
        notes: _descriptionController.text, // Mapping Description to Notes
        status: 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: base64Images,
      );

      // 3. API Call
      await _listingService.createListing(listing);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _buildSuccessDialog(ctx),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildSuccessDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent, 
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Listing Published!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your item is now live on the marketplace and ready for collectors.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                text: 'DONE',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(); // Exit screen
                  } else {
                    _resetForm(); // Reset if used as tab
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _weightController.clear();
      // Keep address if possible or clear
      _selectedImages.clear();
      _selectedMaterial = 'Plastic';
      _requestCollector = false;
    });
  }

  // --- UI Construction ---

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'New Listing',
          style: TextStyle(
            color: isDark ? MarketplaceTheme.darkTextPrimary : MarketplaceTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: isDark ? MarketplaceTheme.darkTextPrimary : MarketplaceTheme.lightTextPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: MarketplaceTheme.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable Form
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Upload Media', isDark),
                        _buildMediaUploadSection(isDark),
                        const SizedBox(height: 24),

                        _buildSectionHeader('Item Details', isDark),
                        _buildDetailsSection(isDark),
                        const SizedBox(height: 24),

                        _buildSectionHeader('Pricing & Logistics', isDark),
                        _buildPricingSection(isDark),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Live Preview & Action Bar (Fixed at bottom)
              _buildLivePreviewBar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMediaUploadSection(bool isDark) {
    return GlassCard(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: _selectedImages.isEmpty
          ? GestureDetector(
              onTap: _pickImages,
              child: DottedBorderPlaceholder(isDark: isDark, isAnalyzing: _isAnalyzing),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, 
                                    color: Colors.grey, size: 30),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),

                ],
              ),
            ),
    );
  }

  Widget _buildDetailsSection(bool isDark) {
    return Column(
      children: [
        // AI Detected Material Badge
        if (_isAnalyzing)
           const LinearProgressIndicator(
             backgroundColor: Colors.transparent,
             color: MarketplaceTheme.darkAccentCyan,
           ),
        
        // Material Dropdown
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMaterial,
              isExpanded: true,
              dropdownColor: isDark ? MarketplaceTheme.darkBackgroundEnd : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              items: _materialRates.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(_getMaterialIcon(value), 
                          color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent, size: 20),
                      const SizedBox(width: 12),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedMaterial = newValue!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Title Field
        _buildTextField(
          controller: _titleController,
          label: 'Listing Title',
          hint: 'e.g. 5kg of Copper Wires',
          icon: Icons.title,
          isDark: isDark,
          validator: (v) => v!.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 12),

        // Description Field
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Condition, details, etc.',
          icon: Icons.description_outlined,
          isDark: isDark,
          maxLines: 3,
        ),
        const SizedBox(height: 12),

        // Weight Field
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                hint: '0.0',
                icon: Icons.scale_outlined,
                isDark: isDark,
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() {}), // Trigger total recalc
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Invalid';
                  
                  // Role-based validation
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final userRole = authService.userRole;
                  // Fallback if role is not readily available synchronously
                  if (userRole == 'individual' && n > 20) return 'Max 20kg for individuals';
                  if ((userRole == 'warehouse' || userRole == 'company') && n < 10) return 'Min 10kg required';
                  
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: GlassCard(
                height: 60,
                child: Center(
                  child: Text(
                    'KG',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSection(bool isDark) {
    return Column(
      children: [
        // Rate Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: (isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Market Rate',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              Text(
                'Rs ${_materialRates[_selectedMaterial]}/kg',
                style: TextStyle(
                  color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pickup Address
        _buildTextField(
          controller: _addressController,
          label: 'Pickup Location',
          hint: 'Full Address',
          icon: Icons.location_on_outlined,
          isDark: isDark,
          validator: (v) => v!.isEmpty ? 'Address is required' : null,
        ),
      ],
    );
  }

  Widget _buildLivePreviewBar(bool isDark) {
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + safeAreaBottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.1),
             blurRadius: 10,
             offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live Preview Card (Mini)
          Row(
            children: [
               Container(
                 width: 50, height: 50,
                 decoration: BoxDecoration(
                   color: Colors.grey[300],
                   borderRadius: BorderRadius.circular(8),
                   image: _selectedImages.isNotEmpty 
                     ? DecorationImage(
                         image: FileImage(File(_selectedImages.first.path)),
                         fit: BoxFit.cover,
                       )
                     : null,
                 ),
                 child: _selectedImages.isEmpty 
                     ? const Icon(Icons.image, color: Colors.grey)
                     : null,
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       _titleController.text.isEmpty ? 'Listing Preview' : _titleController.text,
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                       style: TextStyle(
                         color: isDark ? Colors.white : Colors.black87,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     Text(
                       '${_weightController.text.isEmpty ? '0' : _weightController.text} kg ● $_selectedMaterial',
                       style: TextStyle(
                         color: isDark ? Colors.white54 : Colors.black54,
                         fontSize: 12,
                       ),
                     ),
                   ],
                 ),
               ),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                    Text(
                      'EST. VALUE',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                       'Rs ${_estimatedValue.toStringAsFixed(0)}',
                       style: TextStyle(
                         color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                         fontWeight: FontWeight.bold,
                         fontSize: 18,
                       ),
                    ),
                 ],
               ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Publish Button
          SizedBox(
            width: double.infinity,
            child: NeonButton(
              text: 'PUBLISH LISTING',
              isLoading: _isSubmitting,
              onPressed: _publishListing,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black45),
          hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black12),
          icon: Icon(icon, color: isDark ? Colors.white54 : Colors.black38),
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'Plastic': return Icons.local_drink;
      case 'Paper': return Icons.description;
      case 'Metal': return Icons.build;
      case 'E-Waste': return Icons.computer;
      case 'Glass': return Icons.wine_bar;
      case 'Clothing': return Icons.checkroom;
      case 'Other': return Icons.category;
      default: return Icons.recycling;
    }
  }
}

class DottedBorderPlaceholder extends StatelessWidget {
  final bool isDark;
  final bool isAnalyzing;

  const DottedBorderPlaceholder(
      {Key? key, required this.isDark, required this.isAnalyzing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black26, 
          style: BorderStyle.solid, // Simple border for now
          width: 1,
        ),
      ),
      child: Center(
        child: isAnalyzing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'AI Analyzing...',
                    style: TextStyle(
                      color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      size: 40,
                      color: isDark ? Colors.white54 : Colors.black45),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to Upload',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'AI will auto-detect details',
                    style: TextStyle(
                      color: isDark ? Colors.white24 : Colors.black26,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
