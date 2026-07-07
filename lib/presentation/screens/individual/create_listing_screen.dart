import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:recyconnect/core/models/listing_model.dart';
import 'package:recyconnect/core/services/auth_service.dart';
import 'package:recyconnect/core/services/image_classifier_service.dart';
import 'package:recyconnect/core/services/listing_service.dart';
import 'package:recyconnect/core/services/location_service.dart';
import 'package:recyconnect/core/theme/marketplace_theme.dart';
import 'package:recyconnect/presentation/widgets/marketplace/glass_card.dart';
import 'package:recyconnect/presentation/widgets/marketplace/neon_button.dart';
import 'package:recyconnect/presentation/screens/marketplace/location_selection_screen.dart';
import 'package:flutter/foundation.dart';

class CreateListingScreen extends StatefulWidget {
  final Listing? listing;
  final String? initialMaterial;
  final bool triggerCamera;
  final bool requestCollector;

  const CreateListingScreen({
    super.key,
    this.listing,
    this.initialMaterial,
    this.triggerCamera = false,
    this.requestCollector = false,
  });

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
  List<String> _existingImages = [];
  String _selectedMaterial = 'Plastic';
  String _locationMethod = 'manual';
  bool _requestCollector = false;
  bool _isAnalyzing = false;
  bool _isSubmitting = false;

  double? _latitude;
  double? _longitude;
  double? _userGpsLatitude;
  double? _userGpsLongitude;
  String? _selectedCity;
  String? _selectedArea;

  bool get _isEditing => widget.listing != null;

  bool get _isGpsLocationVerified {
    if (_userGpsLatitude == null || _userGpsLongitude == null || _latitude == null || _longitude == null) {
      return false;
    }
    return (_userGpsLatitude! - _latitude!).abs() < 0.0001 &&
           (_userGpsLongitude! - _longitude!).abs() < 0.0001;
  }

  // Animation for "AI Scanning"
  late AnimationController _scanController;

  Map<String, double> _materialRates = {};
  bool _isLoadingRates = true;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _prefillForEdit();
    _loadRates();
    if (!_isEditing) {
      _initGPSLocation();
      if (widget.requestCollector) {
        _requestCollector = true;
      }
      if (widget.triggerCamera) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pickImages();
        });
      }
    }
  }

  void _prefillForEdit() {
    final listing = widget.listing;
    if (listing == null) return;

    _titleController.text = listing.title ?? '';
    _descriptionController.text = listing.notes ?? '';
    _weightController.text = listing.displayWeight.toStringAsFixed(
      listing.displayWeight.truncateToDouble() == listing.displayWeight ? 0 : 1,
    );
    _addressController.text = listing.pickupAddress;
    _selectedMaterial = listing.materialType;
    _locationMethod = listing.locationMethod ?? 'manual';
    _existingImages = listing.images ?? [];
    
    _latitude = listing.latitude;
    _longitude = listing.longitude;
    _selectedCity = listing.city;
    _selectedArea = listing.area;
    
    if (listing.metadata != null) {
      final gpsLoc = listing.userCurrentLocation;
      if (gpsLoc != null) {
        _userGpsLatitude = gpsLoc['latitude'];
        _userGpsLongitude = gpsLoc['longitude'];
      }
    }
  }

  Future<void> _loadRates() async {
    try {
      final rates = await _listingService.fetchMaterialRates();
      if (mounted) {
        setState(() {
          _materialRates = rates;
          if (!_isEditing && rates.isNotEmpty) {
            if (widget.initialMaterial != null) {
              _selectedMaterial = rates.keys.firstWhere(
                (key) => key.toLowerCase() == widget.initialMaterial!.toLowerCase(),
                orElse: () => rates.keys.first,
              );
            } else {
              _selectedMaterial = rates.keys.first;
            }
          } else if (_isEditing && rates.isNotEmpty) {
            _selectedMaterial = rates.keys.firstWhere(
              (key) => key.toLowerCase() == _selectedMaterial.toLowerCase(),
              orElse: () => rates.keys.first,
            );
          }
          _isLoadingRates = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRates = false);
        // Fallback or leave empty
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load material rates.')),
        );
      }
    }
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

  Future<void> _initGPSLocation() async {
    try {
      final locationService = LocationService();
      // Explicitly request location permission
      await locationService.requestLocationPermission();
      // Set a 4-second timeout to check GPS coordinates so UI loading is responsive
      final gpsData = await locationService.getCurrentLocationWithTimeout(
        timeout: const Duration(seconds: 4),
      );
      if (gpsData != null) {
        final lat = gpsData['latitude']!;
        final lng = gpsData['longitude']!;
        
        setState(() {
          _userGpsLatitude = lat;
          _userGpsLongitude = lng;
          _latitude = lat;
          _longitude = lng;
        });

        final addressData = await locationService.getAddressFromCoordinates(lat, lng);
        if (addressData != null) {
          final street = addressData['street'] ?? '';
          final subLocality = addressData['subLocality'] ?? '';
          final locality = addressData['locality'] ?? '';
          final province = addressData['administrativeArea'] ?? '';

          final List<String> parts = [
            if (street.isNotEmpty) street,
            if (subLocality.isNotEmpty) subLocality,
            if (locality.isNotEmpty) locality,
            if (province.isNotEmpty) province,
          ];

          setState(() {
            _addressController.text = parts.isNotEmpty ? parts.join(', ') : 'Current Location';
            _selectedCity = locality.isNotEmpty ? locality : null;
            _selectedArea = subLocality.isNotEmpty ? subLocality : null;
          });
        }
      } else {
        await _loadUserLocation();
      }
    } catch (_) {
      await _loadUserLocation();
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await authService.fetchProfile();
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final addressParts = <String>[];
        final address = data['address']?.toString().trim();
        final area = data['area']?.toString().trim();
        final city = data['city']?.toString().trim();
        if (address != null && address.isNotEmpty) addressParts.add(address);
        if (area != null && area.isNotEmpty && !addressParts.contains(area)) {
          addressParts.add(area);
        }
        if (city != null && city.isNotEmpty && !addressParts.contains(city)) {
          addressParts.add(city);
        }

        final latVal = data['latitude'];
        final lngVal = data['longitude'];
        double? lat;
        double? lng;
        if (latVal != null) {
          lat = latVal is String ? double.tryParse(latVal) : (latVal as num).toDouble();
        }
        if (lngVal != null) {
          lng = lngVal is String ? double.tryParse(lngVal) : (lngVal as num).toDouble();
        }

        // Forward geocode address to extract coordinates if they are null in user profile
        if (lat == null || lng == null) {
          final query = addressParts.join(', ');
          if (query.isNotEmpty) {
            try {
              final results = await LocationService().searchLocation(query);
              if (results.isNotEmpty) {
                lat = double.tryParse(results.first['lat']?.toString() ?? '');
                lng = double.tryParse(results.first['lon']?.toString() ?? '');
              }
            } catch (_) {}
          }
        }

        // Core fallback coordinates if everything fails, ensuring map doesn't show loading forever
        lat ??= 33.7687;
        lng ??= 72.3618;

        setState(() {
          _latitude = lat;
          _longitude = lng;
          _addressController.text = addressParts.isNotEmpty ? addressParts.join(', ') : 'Default Location';
          _locationMethod = data['locationMethod'] ?? 'manual';
          _selectedCity = city;
          _selectedArea = area;
        });
      }
    } catch (_) {}
  }

  Widget _buildLocationSection(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Location Status',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isGpsLocationVerified
                      ? Colors.green.withValues(alpha: 0.15)
                      : (isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isGpsLocationVerified
                        ? Colors.green.withValues(alpha: 0.4)
                        : (isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  _isGpsLocationVerified ? 'Location Verified ✅' : 'Custom Item Location 📍',
                  style: TextStyle(
                    color: _isGpsLocationVerified
                        ? Colors.green[400]
                        : (isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Address',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black45,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: isDark ? Colors.white54 : Colors.black38, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _addressController.text.isNotEmpty ? _addressController.text : 'No address selected',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_latitude != null && _longitude != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: FlutterMap(
                  key: ValueKey('$_latitude,$_longitude'),
                  options: MapOptions(
                    initialCenter: LatLng(_latitude!, _longitude!),
                    initialZoom: 14.5,
                    maxZoom: 18,
                    minZoom: 8,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.recyconnect.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_latitude!, _longitude!),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('CONFIRM LOCATION'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                side: BorderSide(
                  color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationSelectionScreen(
                      initialLocation: LatLng(_latitude ?? 33.7687, _longitude ?? 72.3618),
                      initialAddress: _addressController.text,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _latitude = result['latitude'];
                    _longitude = result['longitude'];
                    _addressController.text = result['address'];
                    _selectedCity = result['city'];
                    _selectedArea = result['area'];
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
  Future<void> _runAIClassification() async {
    setState(() => _isAnalyzing = true);
    _scanController.repeat(reverse: true);

    try {
      final classifier = ImageClassifierService.instance;
      await classifier.initialize();

      if (_selectedImages.isNotEmpty) {
        final imageFile = File(_selectedImages.first.path);
        final result = await classifier.classifyImage(imageFile);

        if (!mounted) return;

        if (result != null) {
          // If the item is detected as invalid/fake or unsupported
          if (result.isValidRecyclable == false) {
            setState(() {
              _isAnalyzing = false;
              _scanController.stop();
              _scanController.reset();
              _selectedImages.clear(); // Clear the invalid image so they must upload a valid one
            });

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Unsupported Item'),
                  ],
                ),
                content: Text(
                  result.validationMessage ?? 
                  'The uploaded image is not recognized as a supported recyclable material. '
                  'RecyConnect only accepts Plastic, Metal, E-Waste, and Paper.'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          // Find the exact key in _materialRates that matches the AI result,
          // using case-insensitive comparison to avoid DropdownButton crash.
          final matchedKey = _materialRates.keys.firstWhere(
            (k) => k.toLowerCase() == result.displayName.toLowerCase(),
            orElse: () => _materialRates.keys.isNotEmpty
                ? _materialRates.keys.first
                : _selectedMaterial,
          );
          setState(() {
            _isAnalyzing = false;
            _scanController.stop();
            _scanController.reset();
            _selectedMaterial = matchedKey;
            
            // Populate Title and Description with AI generated ones
            if (result.title != null && result.title!.isNotEmpty) {
              _titleController.text = result.title!;
            }
            if (result.description != null && result.description!.isNotEmpty) {
              _descriptionController.text = result.description!;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Image Classified: ${result.displayName} (${result.confidencePercent})',
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
      if (kDebugMode) print('AI Classification error: $e');
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
       return;
    }
    final authService = Provider.of<AuthService>(context, listen: false);
    final isWarehouse = authService.userRole == 'warehouse';

    if (_latitude == null || _longitude == null || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid item location.')),
      );
      return;
    }
    if (_selectedImages.isEmpty && _existingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Compress Images then Convert to Base64 (OOM Protection)
      List<String> base64Images = List<String>.from(_existingImages);
      for (var img in _selectedImages) {
        final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
          img.path,
          minWidth: 800,
          minHeight: 800,
          quality: 60,
        );

        final bytes = compressedBytes ?? await img.readAsBytes();
        base64Images.add(base64Encode(bytes));
      }

      // 2. Create Listing Object
      final listing = Listing(
        id: 0,
        userId: 0,
        materialType: _selectedMaterial.toLowerCase(),
        estimatedWeight: double.parse(_weightController.text),
        pickupAddress: _addressController.text,
        locationMethod: _locationMethod,
        title: _titleController.text.trim(),
        notes: _descriptionController.text,
        status: 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        price: _materialRates[_selectedMaterial] ?? 0.0,
        images: base64Images,
        latitude: _latitude,
        longitude: _longitude,
        city: _selectedCity,
        area: _selectedArea,
        metadata: {
          'pickupRequired': isWarehouse ? false : _requestCollector,
          'userCurrentLocation': {
            'latitude': _userGpsLatitude ?? _latitude ?? 0.0,
            'longitude': _userGpsLongitude ?? _longitude ?? 0.0,
          },
          'itemLocation': {
            'latitude': _latitude ?? 0.0,
            'longitude': _longitude ?? 0.0,
            'address': _addressController.text,
          }
        },
      );

      // 3. API Call
      if (_isEditing) {
        await _listingService.updateListing(widget.listing!.id, listing);
      } else {
        await _listingService.createListing(listing);
      }

      if (mounted) {
        if (_isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing updated successfully')),
          );
          Navigator.pop(context, true);
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => _buildSuccessDialog(ctx),
          );
        }
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
                color: (isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent).withValues(alpha: 0.1),
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
      if (_materialRates.isNotEmpty) {
        _selectedMaterial = _materialRates.keys.first;
      }
      _requestCollector = false;
    });
  }

  // --- UI Construction ---

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Listing' : 'New Listing',
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

                        _buildSectionHeader('Location of Item', isDark),
                        _buildLocationSection(isDark),
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
                  }),

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
           const Padding(
             padding: EdgeInsets.only(bottom: 12),
             child: ClipRRect(
               borderRadius: BorderRadius.all(Radius.circular(4)),
               child: LinearProgressIndicator(
                 backgroundColor: Colors.transparent,
                 color: MarketplaceTheme.darkAccentCyan,
               ),
             ),
           ),
        
        // Material Dropdown
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _isLoadingRates 
            ? const Center(child: Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator()))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Material Category',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMaterial,
                      isExpanded: true,
                      dropdownColor: isDark ? MarketplaceTheme.darkBackgroundEnd : Colors.white,
                      icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white54 : Colors.black45),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                ],
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
        _buildTextField(
          controller: _weightController,
          label: 'Weight',
          hint: '0.0',
          icon: Icons.scale_outlined,
          isDark: isDark,
          keyboardType: TextInputType.number,
          suffixText: 'kg',
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
      ],
    );
  }

  Widget _buildPricingSection(bool isDark) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isWarehouse = authService.userRole == 'warehouse';

    return Column(
      children: [
        // Rate Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: (isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent).withValues(alpha: 0.3),
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
                'Rs ${_materialRates[_selectedMaterial] ?? 0}/kg',
                style: TextStyle(
                  color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (!isWarehouse) ...[
          const SizedBox(height: 16),

          // Pickup Required Radio Button
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_shipping_outlined,
                        color: isDark ? Colors.white54 : Colors.black38, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Pickup Required?',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RadioGroup<bool>(
                  groupValue: _requestCollector,
                  onChanged: (val) => setState(() => _requestCollector = val!),
                  child: Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'Yes',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          value: true,
                          activeColor: isDark
                              ? MarketplaceTheme.darkAccentCyan
                              : MarketplaceTheme.lightAccent,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'No',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          value: false,
                          activeColor: isDark
                              ? MarketplaceTheme.darkAccentCyan
                              : MarketplaceTheme.lightAccent,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLivePreviewBar(bool isDark) {
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + safeAreaBottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: 0.1),
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
              text: _isEditing ? 'UPDATE LISTING' : 'PUBLISH LISTING',
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
    String? suffixText,
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
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black45),
          hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black12),
          icon: Icon(icon, color: isDark ? Colors.white54 : Colors.black38),
          suffixText: suffixText,
          suffixStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
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
      {super.key, required this.isDark, required this.isAnalyzing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
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
