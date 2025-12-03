import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'dart:typed_data';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/constants/city_data.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/address_input_section.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactNoController = TextEditingController();
  final LocationService _locationService = LocationService();

  double? _latitude;
  double? _longitude;
  String _locationMethod = 'manual';
  bool _isLocating = false;

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user != null) {
      _userRole = user['role'];
      _nameController.text = user['name'] ?? '';
      _businessNameController.text = user['businessName'] ?? '';
      _companyNameController.text = user['companyName'] ?? '';
      _cityController.text = user['city'] ?? '';
      _areaController.text = user['area'] ?? '';
      _addressController.text = user['address'] ?? '';
      _contactNoController.text = user['contactNo'] ?? '';
      
      if (user['latitude'] != null) {
        _latitude = user['latitude'] is String ? double.tryParse(user['latitude']) : user['latitude'];
      }
      if (user['longitude'] != null) {
        _longitude = user['longitude'] is String ? double.tryParse(user['longitude']) : user['longitude'];
      }
      _locationMethod = user['locationMethod'] ?? 'manual';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _companyNameController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppTheme.primaryGreen),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Read bytes for web-compatible display
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      final hasPermission = await _locationService.requestLocationPermission();
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required for auto-detection'),
            ),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      // Use smart detection with city/area matching
      final locationData = await _locationService.detectLocationAndMatch(
        PakistanCities.cities,
        (String city) => PakistanCities.getAreasForCity(city),
      );
      
      if (locationData != null) {
        setState(() {
          _latitude = locationData['latitude'];
          _longitude = locationData['longitude'];
          _locationMethod = 'auto';
          
          // Auto-fill city if detected
          if (locationData['city'] != null) {
            _cityController.text = locationData['city'];
          }
          
          // Auto-fill area if detected
          if (locationData['area'] != null) {
            _areaController.text = locationData['area'];
          }
          
          // Optionally auto-fill address from GPS (can be overwritten)
          if (locationData['fullAddress'] != null && 
              locationData['fullAddress'].toString().isNotEmpty) {
            // Only fill if address is empty
            if (_addressController.text.isEmpty) {
              _addressController.text = locationData['fullAddress'];
            }
          }
        });

        String message = 'Location detected successfully';
        if (locationData['city'] != null) {
          message += ' - ${locationData['city']}';
          if (locationData['area'] != null) {
            message += ', ${locationData['area']}';
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get location. Please enter manually.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();

      final Map<String, dynamic> updateData = {};

      // Add fields based on role
      if (_userRole == 'individual' && _nameController.text.isNotEmpty) {
        updateData['name'] = _nameController.text.trim();
      } else if (_userRole == 'warehouse' &&
          _businessNameController.text.isNotEmpty) {
        updateData['businessName'] = _businessNameController.text.trim();
      } else if (_userRole == 'company' &&
          _companyNameController.text.isNotEmpty) {
        updateData['companyName'] = _companyNameController.text.trim();
      }

      // Add address and contact number if provided
      if (_cityController.text.isNotEmpty) {
        updateData['city'] = _cityController.text.trim();
      }
      if (_areaController.text.isNotEmpty) {
        updateData['area'] = _areaController.text.trim();
      }
      if (_addressController.text.isNotEmpty) {
        updateData['address'] = _addressController.text.trim();
      }
      if (_contactNoController.text.isNotEmpty) {
        updateData['contactNo'] = _contactNoController.text.trim();
      }
      
      // Add location data
      if (_latitude != null && _longitude != null) {
        updateData['latitude'] = _latitude;
        updateData['longitude'] = _longitude;
        updateData['locationMethod'] = _locationMethod;
      }

      final result =
          await authService.updateProfile(updateData, _selectedImage);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update profile'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.lightGray,
                      child: _selectedImageBytes != null
                          ? ClipOval(
                              child: Image.memory(
                                _selectedImageBytes!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Consumer<AuthService>(
                              builder: (context, authService, child) {
                                final user = authService.currentUser;
                                final hasProfileImage = user?['profileImage'] != null && 
                                                        (user?['profileImage'] as String).isNotEmpty;
                                
                                if (hasProfileImage) {
                                  return ClipOval(
                                    child: Image.network(
                                      user!['profileImage'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / 
                                                  loadingProgress.expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Text(
                                            user['name']?.substring(0, 1).toUpperCase() ?? 'U',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }
                                
                                return Center(
                                  child: Text(
                                    user?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Form Fields based on role
              if (_userRole == 'individual') ...[
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ] else if (_userRole == 'warehouse') ...[
                CustomTextField(
                  label: 'Business Name',
                  controller: _businessNameController,
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your business name';
                    }
                    return null;
                  },
                ),
              ] else if (_userRole == 'company') ...[
                CustomTextField(
                  label: 'Company Name',
                  controller: _companyNameController,
                  icon: Icons.corporate_fare,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your company name';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 20),

              // Contact Number Field
              CustomTextField(
                label: 'Contact Number',
                controller: _contactNoController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your contact number';
                  }
                  // Remove any spaces, dashes, or parentheses
                  final cleanedValue =
                      value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                  // Must be exactly 11 digits starting with 03
                  if (!RegExp(r'^03\d{9}$').hasMatch(cleanedValue)) {
                    return 'Phone number must be 11 digits starting with 03';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Address Section - Different for Individuals vs Organizations
              if (_userRole == 'warehouse' || _userRole == 'company') ...[
                AddressInputSection(
                  cityController: _cityController,
                  areaController: _areaController,
                  addressController: _addressController,
                  isDark: false, // Will be updated to use theme
                ),
              ] else ...[
                // Simple address field for individuals
                CustomTextField(
                  label: 'Address',
                  controller: _addressController,
                  icon: Icons.location_on,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your address';
                    }
                    if (value.trim().length < 10) {
                      return 'Address must be at least 10 characters';
                    }
                    if (value.trim().length > 200) {
                      return 'Address must not exceed 200 characters';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 20),

              // Location Settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_latitude != null && _longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Current: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLocating ? null : _getCurrentLocation,
                        icon: _isLocating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(_isLocating ? 'Updating...' : 'Update GPS Location'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Update Button
              CustomButton(
                text: 'Update Profile',
                onPressed: _isLoading ? null : _updateProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
