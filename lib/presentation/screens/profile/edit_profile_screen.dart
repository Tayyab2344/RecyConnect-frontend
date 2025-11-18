import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

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
  final _addressController = TextEditingController();
  final _contactNoController = TextEditingController();

  File? _selectedImage;
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
      _addressController.text = user['address'] ?? '';
      _contactNoController.text = user['contactNo'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _companyNameController.dispose();
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
        setState(() {
          _selectedImage = File(image.path);
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
      if (_addressController.text.isNotEmpty) {
        updateData['address'] = _addressController.text.trim();
      }
      if (_contactNoController.text.isNotEmpty) {
        updateData['contactNo'] = _contactNoController.text.trim();
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
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? Consumer<AuthService>(
                              builder: (context, authService, child) {
                                final user = authService.currentUser;
                                if (user?['profileImage'] != null) {
                                  return ClipOval(
                                    child: Image.network(
                                      user!['profileImage'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Text(
                                          user['name']
                                                  ?.substring(0, 1)
                                                  .toUpperCase() ??
                                              'U',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }
                                return Text(
                                  user?['name']
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                );
                              },
                            )
                          : null,
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

              // Address Field
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
