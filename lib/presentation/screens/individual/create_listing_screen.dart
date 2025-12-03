import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/listing_model.dart';


class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();
  
  // Form Controllers
  String _selectedMaterial = '';
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  
  // State Variables
  List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  bool _aiSuggestionAccepted = false;
  String _aiSuggestedMaterial = 'Paper';
  
  // Location State
  bool _isLocationDetected = false;
  bool _isDetectingLocation = false;
  String _detectedLocation = '';
  double? _latitude;
  double? _longitude;

  // Static Material Rates (Rs per kg)
  final Map<String, Map<String, dynamic>> _materials = {
    'Plastic': {
      'icon': Icons.recycling,
      'color': Color(0xFF2196F3),
      'rate': 20,
    },
    'Paper': {
      'icon': Icons.description,
      'color': Color(0xFFFFA726),
      'rate': 15,
    },
    'Metal': {
      'icon': Icons.build,
      'color': Color(0xFF757575),
      'rate': 40,
    },
    'E-Waste': {
      'icon': Icons.devices,
      'color': Color(0xFF9C27B0),
      'rate': 100,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUserLocation(); // Load location from user profile first
  }

  @override
  void dispose() {
    _weightController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  /// Load location from user's profile (city, area, address)
  Future<void> _loadUserLocation() async {
    setState(() => _isDetectingLocation = true);
    
    try {
      final response = await _authService.fetchProfile();
      
      if (response['success'] == true) {
        final userData = response['data']['data'];
        
        // Build human-readable location from city and area
        if (userData['city'] != null || userData['area'] != null || userData['address'] != null) {
          final locationParts = <String>[];
          if (userData['address'] != null) locationParts.add(userData['address']);
          if (userData['area'] != null) locationParts.add(userData['area']);
          if (userData['city'] != null) locationParts.add(userData['city']);
          
          if (locationParts.isNotEmpty) {
            setState(() {
              _isLocationDetected = true;
              _latitude = userData['latitude']?.toDouble();
              _longitude = userData['longitude']?.toDouble();
              _detectedLocation = locationParts.join(', ');
              
              // Auto-fill manual entry fields as well
              if (userData['address'] != null) {
                _addressController.text = userData['address'];
              }
              if (userData['city'] != null) {
                _cityController.text = userData['city'];
              }
            });
          }
        }
      }
    } catch (e) {
      // Failed to load user profile location, continue without it
    } finally {
      setState(() => _isDetectingLocation = false);
    }
  }

  /// Detect location using GPS (manual override)
  Future<void> _detectLocation() async {
    setState(() => _isDetectingLocation = true);
    
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      
      if (hasPermission) {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          setState(() {
            _isLocationDetected = true;
            _latitude = position['latitude'];
            _longitude = position['longitude'];
            // Show coordinates if GPS is used (fallback)
            _detectedLocation = '${position['latitude']!.toStringAsFixed(4)}, ${position['longitude']!.toStringAsFixed(4)}';
          });
        }
      }
    } catch (e) {
      // Location detection failed, user will enter manually
    } finally {
      setState(() => _isDetectingLocation = false);
    }
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 images allowed')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        final remaining = 3 - _selectedImages.length;
        _selectedImages.addAll(
          images.take(remaining).toList()
        );
      });
    }
  }

  double get _estimatedValue {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final rate = _selectedMaterial.isNotEmpty 
        ? (_materials[_selectedMaterial]?['rate'] ?? 0) 
        : 0;
    return weight * rate;
  }

  bool get _isFormValid {
    return _selectedMaterial.isNotEmpty &&
           _weightController.text.isNotEmpty &&
           (double.tryParse(_weightController.text) ?? 0) > 0 &&
           (double.tryParse(_weightController.text) ?? 0) <= 10 &&
           _selectedImages.isNotEmpty && // NEW: Require at least one image
           (_isLocationDetected || 
            (_addressController.text.isNotEmpty && _cityController.text.isNotEmpty));
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate images
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one photo of your recyclable items'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      // Prepare pickup address
      final pickupAddress = _isLocationDetected 
          ? _detectedLocation
          : '${_addressController.text}, ${_cityController.text}${_landmarkController.text.isNotEmpty ? ', ${_landmarkController.text}' : ''}';
      
      // Convert images to base64
      List<String> imageBase64List = [];
      try {
        print('DEBUG: Starting image conversion, total images: ${_selectedImages.length}');
        for (var i = 0; i < _selectedImages.length; i++) {
          final imageFile = _selectedImages[i];
          print('DEBUG: Reading image $i from path: ${imageFile.path}');
          final bytes = await imageFile.readAsBytes();
          print('DEBUG: Image $i bytes length: ${bytes.length}');
          final base64Image = base64Encode(bytes);
          print('DEBUG: Image $i base64 length: ${base64Image.length}');
          imageBase64List.add(base64Image);
        }
        print('DEBUG: Successfully converted all images to base64');
      } catch (e, stackTrace) {
        print('ERROR converting images: $e');
        print('Stack trace: $stackTrace');
        throw Exception('Failed to process images: $e');
      }
      
      // Create listing object
      print('DEBUG: Creating Listing object...');
      final listing = Listing(
        id: 0, // Will be set by backend
        userId: 0, // Will be set by backend
        materialType: _selectedMaterial.toLowerCase(),
        estimatedWeight: double.parse(_weightController.text),
        pickupAddress: pickupAddress,
        latitude: null, // Location coordinates would be set by backend/geocoding
        longitude: null,
        locationMethod: _isLocationDetected ? 'auto' : 'manual',
        notes: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        status: 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: imageBase64List, // Include base64 encoded images
      );
      print('DEBUG: Listing object created successfully');

      
      // Call API to create listing
      final _listingService = ListingService();
      print('DEBUG: Calling API to create listing...');
      final createdListing = await _listingService.createListing(listing);
      
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create listing: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 28),
            SizedBox(width: 12),
            Text('Success!'),
          ],
        ),
        content: const Text('Your listing has been created successfully!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
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
        title: const Text('Create Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Weight Limit'),
                  content: const Text(
                    'For individual listings, the maximum weight allowed is 10 kg. If you have more waste to recycle, please create multiple listings or contact a warehouse directly.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Suggestion Section
              if (!_aiSuggestionAccepted) _buildAISuggestionCard(isDark),
              if (!_aiSuggestionAccepted) const SizedBox(height: 20),

              // Material Type Section
              _buildSectionTitle('Select Material Type', isDark, required: true),
              const SizedBox(height: 12),
              _buildMaterialSelector(isDark),
              const SizedBox(height: 20),

              // Static Rate Display
              if (_selectedMaterial.isNotEmpty) ...[
                _buildRateDisplay(isDark),
                const SizedBox(height: 20),
              ],

              // Upload Images Section
              _buildSectionTitle('Upload / Capture Images', isDark, required: true),
              const SizedBox(height: 8),
              Text(
                'Add 1-3 images of your recyclable items',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildPhotoSection(isDark),
              const SizedBox(height: 20),

              // Estimated Weight Section
              _buildSectionTitle('Estimated Weight (KG)', isDark, required: true),
              const SizedBox(height: 12),
              _buildWeightInput(isDark),
              const SizedBox(height: 20),

              // Auto Price Estimate
              if (_selectedMaterial.isNotEmpty && _weightController.text.isNotEmpty)
                _buildPriceEstimateCard(isDark),
              if (_selectedMaterial.isNotEmpty && _weightController.text.isNotEmpty)
                const SizedBox(height: 20),

              // Location Section
              _buildSectionTitle('Pickup Location', isDark, required: true),
              const SizedBox(height: 12),
              _buildLocationSection(isDark),
              const SizedBox(height: 20),

              // Notes / Description
              _buildSectionTitle('Notes / Description', isDark),
              const SizedBox(height: 12),
              _buildDescriptionField(isDark),
              const SizedBox(height: 24),

              // Listing Summary Card (Live Preview)
              _buildListingSummaryCard(isDark),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isSubmitting ? _submitListing : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Listing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, {bool required = false}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppTheme.errorRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAISuggestionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.darkPrimaryGreen.withOpacity(0.1)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? AppTheme.darkPrimaryGreen.withOpacity(0.3)
              : AppTheme.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Suggestion',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Based on your history, we suggest: $_aiSuggestedMaterial',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _aiSuggestionAccepted = true;
                  });
                },
                child: const Text('Reject', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedMaterial = _aiSuggestedMaterial;
                    _aiSuggestionAccepted = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialSelector(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final materialName = _materials.keys.elementAt(index);
        final material = _materials[materialName]!;
        final isSelected = _selectedMaterial == materialName;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedMaterial = materialName),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? (material['color'] as Color).withOpacity(0.1)
                  : (isDark ? AppTheme.darkCardSurface : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? (material['color'] as Color)
                    : (isDark 
                        ? AppTheme.darkSecondaryGreen.withOpacity(0.3) 
                        : AppTheme.lightGray),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (material['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  material['icon'] as IconData,
                  size: 36,
                  color: material['color'] as Color,
                ),
                const SizedBox(height: 8),
                Text(
                  materialName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRateDisplay(bool isDark) {
    final material = _materials[_selectedMaterial]!;
    final rate = material['rate'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (material['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (material['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            material['icon'] as IconData,
            color: material['color'] as Color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Rate for $_selectedMaterial',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs $rate per kg',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: material['color'] as Color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
              : AppTheme.lightGray,
        ),
      ),
      child: Column(
        children: [
          if (_selectedImages.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppTheme.darkSurface
                      : AppTheme.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                        .withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                          .withOpacity(0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add photos (1-3 images)',
                      style: TextStyle(
                        color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                            .withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length + (_selectedImages.length < 3 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _selectedImages.length) {
                        return GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                            ),
                          ),
                        );
                      }
                      
                      return Container(
                        width: 100,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(_selectedImages[index].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.errorRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
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
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildWeightInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Enter weight',
            suffixText: 'kg',
            suffixStyle: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter weight';
            }
            final weight = double.tryParse(value);
            if (weight == null) {
              return 'Please enter a valid number';
            }
            if (weight <= 0) {
              return 'Weight must be greater than 0';
            }
            if (weight > 10) {
              return 'Individuals cannot list more than 10 kg';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Weight must be between 0.1 kg and 10 kg',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceEstimateCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.darkPrimaryGreen, AppTheme.darkSecondaryGreen]
              : [Color(0xFF00BFA5), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.darkPrimaryGreen : Color(0xFF00BFA5))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Value',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkBackground : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs ${_estimatedValue.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkBackground : Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_weightController.text} kg × Rs ${_materials[_selectedMaterial]?['rate']}/kg',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkBackground.withOpacity(0.8) : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkBackground : Colors.white).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward,
              color: isDark ? AppTheme.darkBackground : Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(bool isDark) {
    if (_isDetectingLocation) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                : AppTheme.lightGray,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(
              'Detecting location...',
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLocationDetected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                .withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location detected automatically',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _isLocationDetected = false);
                  },
                  child: const Text('Change', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _detectedLocation,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'GPS Enabled',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Manual Location Entry
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
              : AppTheme.lightGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_location_alt,
                color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Enter Location Manually',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              hintText: 'Enter your street address',
            ),
            onChanged: (value) {
              // Schedule setState for next frame to avoid "setState during build" error
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
            },
            validator: (value) {
              if (!_isLocationDetected && (value == null || value.isEmpty)) {
                return 'Address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              hintText: 'Enter your city',
            ),
            onChanged: (value) {
              // Schedule setState for next frame to avoid "setState during build" error
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
            },
            validator: (value) {
              if (!_isLocationDetected && (value == null || value.isEmpty)) {
                return 'City is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _landmarkController,
            decoration: const InputDecoration(
              labelText: 'Nearby Landmark (Optional)',
              hintText: 'e.g., Near City Mall',
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _detectLocation,
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('Try Auto-Detect Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: 'Add any extra details about your recyclable item...',
      ),
    );
  }

  Widget _buildListingSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.darkCardSurface
            : AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
              .withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Listing Summary (Live Preview)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Material',
            _selectedMaterial,
            isDark,
            isComplete: true,
          ),
          _buildSummaryRow(
            'Weight',
            _weightController.text.isNotEmpty ? '${_weightController.text} kg' : 'Not entered',
            isDark,
            isComplete: _weightController.text.isNotEmpty,
          ),
          _buildSummaryRow(
            'Estimated Value',
            _estimatedValue > 0 
                ? 'Rs ${_estimatedValue.toStringAsFixed(0)}' 
                : 'Rs 0',
            isDark,
            isComplete: _estimatedValue > 0,
          ),
          _buildSummaryRow(
            'Pickup Location',
            _isLocationDetected 
                ? 'Auto-detected' 
                : (_addressController.text.isNotEmpty ? 'Manual Entry' : 'Not provided'),
            isDark,
            isComplete: _isLocationDetected || _addressController.text.isNotEmpty,
          ),
          _buildSummaryRow(
            'Images',
            '${_selectedImages.length} photo${_selectedImages.length != 1 ? 's' : ''}',
            isDark,
            isComplete: _selectedImages.isNotEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isComplete = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: isComplete 
                    ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                    : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isComplete
                  ? (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark)
                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
