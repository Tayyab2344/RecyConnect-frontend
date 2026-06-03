import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/warehouse_service.dart';

/// Enhanced Add Collector Screen with:
/// - Phone validation (same as registration: 03XXXXXXXXX)
/// - CNIC OCR extraction from image
/// - CNIC uniqueness check across all roles
/// - Premium glassmorphism UI
class AddCollectorScreen extends StatefulWidget {
  const AddCollectorScreen({super.key});

  @override
  State<AddCollectorScreen> createState() => _AddCollectorScreenState();
}

class _AddCollectorScreenState extends State<AddCollectorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _cnicController = TextEditingController();

  File? _profileImage;
  File? _cnicImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isExtractingCnic = false;
  bool _isCheckingCnic = false;
  String? _cnicError;
  bool _cnicExtractedFromImage = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      // Request permissions
      PermissionStatus permission;
      if (Platform.isAndroid) {
        if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
          permission = PermissionStatus.granted;
        } else {
          permission = await Permission.photos.request();
          if (permission.isDenied) {
            permission = await Permission.storage.request();
          }
        }
      } else {
        permission = await Permission.photos.request();
      }

      if (permission.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gallery permission is required to pick images'),
              action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
            ),
          );
        }
        return;
      }

      if (permission.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable gallery permission from app settings'),
              action: SnackBarAction(label: 'Open Settings', onPressed: openAppSettings),
            ),
          );
        }
        return;
      }

      // Show option to choose camera or gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildImageSourceSheet(),
      );

      if (source == null) return;

      // If camera is selected, request camera permission
      if (source == ImageSource.camera) {
        final cameraPermission = await Permission.camera.request();
        if (cameraPermission.isDenied || cameraPermission.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera permission is required'),
                action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
              ),
            );
          }
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(pickedFile.path);
          } else {
            _cnicImage = File(pickedFile.path);
          }
        });

        // If CNIC image, extract text using OCR
        if (!isProfile && _cnicImage != null) {
          await _extractCnicFromImage();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Widget _buildImageSourceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2A3A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                ),
                title: Text('Take Photo', style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                )),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: Text('Choose from Gallery', style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                )),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Extract CNIC number from image using ML Kit OCR
  Future<void> _extractCnicFromImage() async {
    if (_cnicImage == null) return;

    setState(() {
      _isExtractingCnic = true;
      _cnicExtractedFromImage = false;
    });

    try {
      final inputImage = InputImage.fromFile(_cnicImage!);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      // Look for CNIC pattern: 5 digits - 7 digits - 1 digit or 13 continuous digits
      final cnicPattern = RegExp(r'(\d{5}[-\s]?\d{7}[-\s]?\d{1})|(\d{13})');
      
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final text = line.text.replaceAll(' ', '');
          final match = cnicPattern.firstMatch(text);
          
          if (match != null) {
            String extractedCnic = match.group(0)!.replaceAll(RegExp(r'[-\s]'), '');
            
            // Format as XXXXX-XXXXXXX-X
            if (extractedCnic.length == 13) {
              final formattedCnic = '${extractedCnic.substring(0, 5)}-${extractedCnic.substring(5, 12)}-${extractedCnic.substring(12)}';
              
              setState(() {
                _cnicController.text = formattedCnic;
                _cnicExtractedFromImage = true;
                _isExtractingCnic = false;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('CNIC extracted: $formattedCnic'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }

              // Auto-check if CNIC is unique
              await _checkCnicUniqueness(formattedCnic);
              return;
            }
          }
        }
      }

      // No CNIC found
      setState(() => _isExtractingCnic = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not extract CNIC. Please enter manually.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isExtractingCnic = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR Error: $e')),
        );
      }
    }
  }

  /// Check if CNIC is already registered
  Future<void> _checkCnicUniqueness(String cnic) async {
    final cleanedCnic = cnic.replaceAll('-', '');
    if (cleanedCnic.length != 13) return;

    setState(() {
      _isCheckingCnic = true;
      _cnicError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/check-cnic/$cleanedCnic'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['exists'] == true) {
          setState(() {
            _cnicError = 'CNIC already registered as ${data['data']['role']}';
          });
        }
      }
    } catch (e) {
      // Silently fail - will be checked again on submit
    } finally {
      setState(() => _isCheckingCnic = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a profile picture')),
      );
      return;
    }

    if (_cnicImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload CNIC image')),
      );
      return;
    }

    if (_cnicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter CNIC number')),
      );
      return;
    }

    // Check CNIC uniqueness before submit
    if (_cnicError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cnicError!), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final warehouseService = WarehouseService();

    if (authService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error. Please login again.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final result = await warehouseService.addCollector(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      contactNo: _contactController.text.trim(),
      token: authService.token!,
      profileImage: _profileImage,
      cnic: _cnicImage,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success'] == true) {
        _showSuccessDialog(
          result['collectorId'],
          result['password'],
          result['name'],
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to add collector')),
        );
      }
    }
  }

  void _showSuccessDialog(String collectorId, String password, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2A3A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 30),
            const SizedBox(width: 10),
            Text('Collector Added!', style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Collector "$name" has been successfully added.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 20),
            Text('Credentials:', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            )),
            const SizedBox(height: 10),
            _buildCredentialRow('Collector ID', collectorId, isDark),
            const SizedBox(height: 10),
            _buildCredentialRow('Password', password, isDark),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please save these credentials now. The password will not be shown again.',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: Text('Done', style: TextStyle(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey,
                )),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : Colors.black87,
                )),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, size: 20, color: isDark ? Colors.white54 : Colors.grey),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          _buildBackground(isDark),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(isDark),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Personal Information', isDark),
                          const SizedBox(height: 16),
                          
                          // Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outlined,
                            isDark: isDark,
                            validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Phone Field with validation
                          _buildTextField(
                            controller: _contactController,
                            label: 'Contact Number',
                            icon: Icons.phone_outlined,
                            isDark: isDark,
                            hint: '03001234567',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Contact number is required';
                              }
                              String cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
                              if (!RegExp(r'^03[0-9]{9}$').hasMatch(cleaned)) {
                                return 'Must be 11 digits starting with 03';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Address Field
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address',
                            icon: Icons.location_on_outlined,
                            isDark: isDark,
                            maxLines: 2,
                            validator: (v) => v?.isEmpty == true ? 'Address is required' : null,
                          ),
                          const SizedBox(height: 16),

                          // CNIC Field
                          _buildTextField(
                            controller: _cnicController,
                            label: 'CNIC Number',
                            icon: Icons.credit_card_outlined,
                            isDark: isDark,
                            hint: 'XXXXX-XXXXXXX-X',
                            keyboardType: TextInputType.number,
                            suffixWidget: _cnicExtractedFromImage
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.auto_awesome, size: 14, color: AppColors.success),
                                        const SizedBox(width: 4),
                                        Text('OCR', style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                        )),
                                      ],
                                    ),
                                  )
                                : (_isCheckingCnic
                                    ? const Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      )
                                    : null),
                            errorText: _cnicError,
                            onChanged: (value) {
                              setState(() {
                                _cnicExtractedFromImage = false;
                                _cnicError = null;
                              });
                              // Check uniqueness when 13 digits are entered
                              final cleaned = value.replaceAll('-', '');
                              if (cleaned.length == 13) {
                                _checkCnicUniqueness(value);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'CNIC is required';
                              }
                              String cleaned = value.replaceAll('-', '');
                              if (cleaned.length != 13) {
                                return 'CNIC must be 13 digits';
                              }
                              if (!RegExp(r'^\d{13}$').hasMatch(cleaned)) {
                                return 'Invalid CNIC format';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Documents', isDark),
                          const SizedBox(height: 16),

                          // Profile Picture
                          _buildImagePicker(
                            'Profile Picture',
                            _profileImage,
                            () => _pickImage(true),
                            isDark,
                          ),
                          const SizedBox(height: 16),

                          // CNIC Image with OCR indicator
                          _buildImagePicker(
                            'CNIC Image',
                            _cnicImage,
                            () => _pickImage(false),
                            isDark,
                            showOcrBadge: true,
                            isExtracting: _isExtractingCnic,
                          ),
                          const SizedBox(height: 32),

                          // Submit Button
                          _buildSubmitButton(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A1628),
                  const Color(0xFF0D2137),
                  const Color(0xFF0F2847),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF0F9F7),
                  const Color(0xFFE8F5F2),
                ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Add New Collector',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? hint,
    String? errorText,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    Widget? suffixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              onChanged: onChanged,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
                prefixIcon: Icon(icon, color: isDark ? AppColors.neonCyan : AppColors.primaryGreen),
                suffixIcon: suffixWidget,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                errorText: errorText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(
    String label,
    File? image,
    VoidCallback onTap,
    bool isDark, {
    bool showOcrBadge = false,
    bool isExtracting = false,
  }) {
    return GestureDetector(
      onTap: isExtracting ? null : onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.neonCyan.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Stack(
                  children: [
                    if (image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(image, fit: BoxFit.cover, width: double.infinity, height: 150),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 40,
                              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to upload $label',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                            if (showOcrBadge) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome, size: 12, color: AppColors.primaryGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      'OCR will extract CNIC',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (isExtracting)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text(
                                'Extracting CNIC...',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.neonGreen, AppColors.neonCyan]
                  : [AppColors.primaryGreen, const Color(0xFF45A049)],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.neonGreen : AppColors.primaryGreen)
                    .withValues(alpha: 0.4 * _pulseAnimation.value),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Create Collector Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF0A1628) : Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
