import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/ocr_service.dart'; // Add OcrService import
import '../../../core/utils/validators.dart';
import '../../widgets/city_area_selector.dart';
import 'otp_verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String role;

  const RegistrationScreen({super.key, required this.role});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _ntnController = TextEditingController();

  final _addressController = TextEditingController(); // This will now be street address
  final _contactNoController = TextEditingController();

  String? _selectedCity;
  String? _selectedArea;

  XFile? _profileImage;
  XFile? _cnicImage;
  XFile? _utilityImage;
  XFile? _ntnImage;

  String? _extractedCnicNumber;
  String? _extractedUtilityBillNumber;
  String? _extractedNtnNumber;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;
  int _currentStep = 0;
  
  
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  Future<void> _analyzeDocument(XFile file, String docType) async {
    // Client-side OCR implementation using OcrService
    // This runs locally on the device (offline-capable) and avoids Vercel timeouts
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing document...')),
    );

    try {
      final File imageFile = File(file.path);
      
      if (docType == 'CNIC') {
        final extractedData = await OcrService.extractCnicData(imageFile);
        
        if (extractedData.containsKey('cnic')) {
          setState(() {
            _cnicController.text = extractedData['cnic']!; // The service already handles formatting? 
            // OcrService regex: \d{5}-\d{7}-\d{1}. If it matches, it's formatted.
            _extractedCnicNumber = extractedData['cnic'];
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('CNIC Extracted: ${extractedData['cnic']}'),
                backgroundColor: AppTheme.primaryGreen,
              ),
            );
          }
        } else {
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not detect CNIC number. Please enter manually.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else if (docType == 'NTN') {
        final extractedData = await OcrService.extractNtnData(imageFile);
        
        if (extractedData.containsKey('ntn')) {
          setState(() {
            _ntnController.text = extractedData['ntn']!;
            _extractedNtnNumber = extractedData['ntn'];
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('NTN Extracted: ${extractedData['ntn']}'),
                backgroundColor: AppTheme.primaryGreen,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not detect NTN number. Please enter manually.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } 
      // Utility bill OCR is also available in OcrService if needed, but not requested specifically for this fix yet
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OCR Failed: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    _companyNameController.dispose();
    _cnicController.dispose();
    _ntnController.dispose();
    _addressController.dispose();
    _contactNoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    double strength = 0.0;
    String strengthText = '';

    // Track individual requirements
    _hasMinLength = password.length >= 8;
    _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    _hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    _hasNumber = RegExp(r'\d').hasMatch(password);
    _hasSpecialChar = RegExp(r'[!@#$%^\&*(),.?":{}|<>]').hasMatch(password);

    if (password.isEmpty) {
      strength = 0.0;
      strengthText = '';
    } else if (password.length < 8) {
      strength = 0.2;
      strengthText = 'Weak';
    } else {
      // Base strength for length
      strength = 0.3;
      
      // Has lowercase
      if (_hasLowercase) strength += 0.15;
      
      // Has uppercase
      if (_hasUppercase) strength += 0.15;
      
      // Has number
      if (_hasNumber) strength += 0.15;
      
      // Has special character
      if (_hasSpecialChar) strength += 0.15;
      
      // Length bonus
      if (password.length >= 12) strength += 0.1;

      if (strength <= 0.4) {
        strengthText = 'Weak';
      } else if (strength <= 0.6) {
        strengthText = 'Medium';
      } else if (strength <= 0.8) {
        strengthText = 'Strong';
      } else {
        strengthText = 'Very Strong';
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strength <= 0.4
          ? Colors.red
          : strength <= 0.6
              ? Colors.orange
              : strength <= 0.8
                  ? Colors.lightGreen
                  : Colors.green;
    });
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

  Future<void> _pickProfileImage() async {
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
          _profileImage = image;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _pickCnicImage() async {
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
          _cnicImage = image;
        });
        await _onCnicImageSelected(_cnicImage);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _pickUtilityImage() async {
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
          _utilityImage = image;
        });
        await _onUtilityImageSelected(_utilityImage);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _pickNtnImage() async {
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
          _ntnImage = image;
        });
        await _onNtnImageSelected(_ntnImage);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() => _currentStep--);
      },
      child: Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A1628),
                    Color(0xFF0D2137),
                    Color(0xFF0F2847),
                    Color(0xFF0A1E35),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF0F9F7),
                    Color(0xFFE8F5F2),
                    Color(0xFFDFF2ED),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWeb ? 800 : double.infinity),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Custom App Bar
                      _buildGlassAppBar(isDark),
                      
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(isWeb ? 40 : 24),
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildProgressIndicator(),
                            const SizedBox(height: 32),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.05, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey<int>(_currentStep),
                                child: _buildStepContent(),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildGlassAppBar(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : const Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              '${_getRoleDisplayName()} Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 54), // Balance the back button and spacing (38 + 16)
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getRoleIcon(),
            size: 48,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: AppTheme.headingStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getRoleDescription(),
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    int totalSteps = _getTotalSteps();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(totalSteps, (index) {
          bool isCompleted = index < _currentStep;
          bool isCurrent = index == _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                // Step Circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent ? AppTheme.primaryGreen : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted || isCurrent ? AppTheme.primaryGreen : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                // Connector Line
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppTheme.primaryGreen : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildDocumentsStep();
      case 2:
        return _buildVerificationStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.65),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: AppTheme.subHeadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Please enter your personal details',
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 32),

          // Profile Image
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      width: 4,
                    ),
                    image: _profileImage != null
                        ? DecorationImage(
                            image: kIsWeb 
                                ? NetworkImage(_profileImage!.path) 
                                : FileImage(File(_profileImage!.path)) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppTheme.backgroundLight,
                  ),
                  child: _profileImage == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: AppTheme.textLight,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Name field (Always shown for all roles now)
          _buildEnhancedTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ],
            validator: Validators.name,
          ),
          const SizedBox(height: 24),

          if (widget.role == 'warehouse')
            _buildEnhancedTextField(
              controller: _businessNameController,
              label: 'Business Name',
              hint: 'Enter your business name',
              icon: Icons.business_outlined,
              validator: Validators.businessName,
            ),
          if (widget.role == 'company')
            _buildEnhancedTextField(
              controller: _companyNameController,
              label: 'Company Name',
              hint: 'Enter your company name',
              icon: Icons.corporate_fare_outlined,
              validator: Validators.companyName,
            ),
          const SizedBox(height: 24),

          _buildEnhancedTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'your.email@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 24),

          _buildEnhancedTextField(
            controller: _contactNoController,
            label: 'Contact Number',
            hint: '03001234567',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: Validators.phoneNumber,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 24),

          // City & Area Selector
          CityAreaSelector(
            selectedCity: _selectedCity,
            selectedArea: _selectedArea,
            onCityChanged: (city) {
              setState(() {
                _selectedCity = city;
                _selectedArea = null; // Reset area when city changes
              });
            },
            onAreaChanged: (area) {
              setState(() {
                _selectedArea = area;
              });
            },
          ),
          const SizedBox(height: 24),

          _buildEnhancedTextField(
            controller: _addressController,
            label: 'Street Address',
            hint: 'House No, Street No, etc.',
            icon: Icons.location_on_outlined,
            keyboardType: TextInputType.streetAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter street address';
              }
              return null;
            },
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          _buildEnhancedTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a strong password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            validator: Validators.password,
            onChanged: (value) => _checkPasswordStrength(value),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.textLight,
                size: 22,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          // Password Strength Indicator
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _passwordStrength <= 0.4
                            ? Colors.red
                            : _passwordStrength <= 0.6
                                ? Colors.orange
                                : _passwordStrength <= 0.8
                                    ? Colors.lightGreen
                                    : Colors.green,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _passwordStrengthText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _passwordStrength <= 0.4
                        ? Colors.red
                        : _passwordStrength <= 0.6
                            ? Colors.orange
                            : _passwordStrength <= 0.8
                                ? Colors.lightGreen
                                : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Password Requirements Checklist
            _buildRequirementItem('At least 8 characters', _hasMinLength),
            _buildRequirementItem('One uppercase letter', _hasUppercase),
            _buildRequirementItem('One lowercase letter', _hasLowercase),
            _buildRequirementItem('One number', _hasNumber),
            _buildRequirementItem('One special character', _hasSpecialChar),
          ],

          const SizedBox(height: 24),

          // Confirm Password Field
          _buildEnhancedTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.textLight,
                size: 22,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),

          // Password Match Indicator
          if (_confirmPasswordController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_confirmPasswordController.text == _passwordController.text
                        ? AppTheme.primaryGreen
                        : AppTheme.errorRed)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (_confirmPasswordController.text == _passwordController.text
                          ? AppTheme.primaryGreen
                          : AppTheme.errorRed)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _confirmPasswordController.text == _passwordController.text
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 20,
                    color: _confirmPasswordController.text == _passwordController.text
                        ? AppTheme.primaryGreen
                        : AppTheme.errorRed,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _confirmPasswordController.text == _passwordController.text
                          ? 'Passwords match'
                          : 'Passwords do not match',
                      style: AppTheme.captionStyle.copyWith(
                        color: _confirmPasswordController.text == _passwordController.text
                            ? AppTheme.primaryGreen
                            : AppTheme.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.infoBlue.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 20, color: AppTheme.infoBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create a strong password with a mix of letters, numbers, and symbols',
                    style: AppTheme.captionStyle.copyWith(color: AppTheme.infoBlue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.65),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Verification',
            style: AppTheme.subHeadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload clear images of your documents for verification',
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 32),

          if (widget.role == 'warehouse' || widget.role == 'company') ...[
            _buildDocumentUploadCard(
              title: 'CNIC Verification',
              description: 'Upload front side of your CNIC',
              icon: Icons.credit_card_rounded,
              image: _cnicImage,
              onTap: _pickCnicImage,
            ),
            
            // Manual CNIC entry field (always show after upload)
            if (_cnicImage != null) ...[
              const SizedBox(height: 16),
              _buildEnhancedTextField(
                controller: _cnicController,
                label: 'CNIC Number',
                hint: '12345-1234567-1',
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CNIC number';
                  }
                  // Remove hyphens and check if 13 digits
                  final digits = value.replaceAll('-', '');
                  if (digits.length != 13) {
                    return 'CNIC must be 13 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.infoBlue.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.infoBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _cnicController.text.isEmpty 
                          ? 'OCR couldn\'t extract CNIC. Please enter manually.'
                          : 'OCR extracted CNIC. Please verify and correct if needed.',
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.infoBlue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (widget.role == 'company') ...[
            const SizedBox(height: 24),
            _buildDocumentUploadCard(
              title: 'Utility Bill',
              description: 'Recent electricity or gas bill',
              icon: Icons.receipt_long_rounded,
              image: _utilityImage,
              onTap: _pickUtilityImage,
            ),
            const SizedBox(height: 24),
            _buildDocumentUploadCard(
              title: 'NTN Certificate',
              description: 'National Tax Number certificate',
              icon: Icons.account_balance_rounded,
              image: _ntnImage,
              onTap: _pickNtnImage,
            ),
            if (_ntnController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NTN Number Extracted',
                            style: AppTheme.captionStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _ntnController.text,
                            style: AppTheme.subHeadingStyle.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (widget.role == 'individual') ...[
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: 64,
                      color: AppTheme.primaryGreen.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Documents Required',
                    style: AppTheme.subHeadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Individual accounts don\'t require document verification.\nYou can proceed to the next step.',
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.textLight),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.65),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Review & Submit',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before submitting',
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          _buildReviewItem(
            'Role',
            _getRoleDisplayName(),
            Icons.badge_outlined,
          ),
          _buildReviewItem(
            widget.role == 'individual'
                ? 'Name'
                : widget.role == 'warehouse'
                    ? 'Business Name'
                    : 'Company Name',
            widget.role == 'individual'
                ? _nameController.text
                : widget.role == 'warehouse'
                    ? _businessNameController.text
                    : _companyNameController.text,
            Icons.person_outline_rounded,
          ),
          _buildReviewItem(
            'Email',
            _emailController.text,
            Icons.email_outlined,
          ),
          _buildReviewItem(
            'Contact Number',
            _contactNoController.text,
            Icons.phone_outlined,
          ),
          _buildReviewItem(
            'Address',
            _addressController.text,
            Icons.location_on_outlined,
          ),
          if (_cnicController.text.isNotEmpty)
            _buildReviewItem(
              'CNIC',
              _cnicController.text,
              Icons.credit_card_rounded,
            ),
          if (_ntnController.text.isNotEmpty)
            _buildReviewItem(
              'NTN',
              _ntnController.text,
              Icons.receipt_long_rounded,
            ),

          // Document Upload Status Section
          if (_cnicImage != null ||
              _utilityImage != null ||
              _ntnImage != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Automatic Document Processing',
                          style: AppTheme.subHeadingStyle.copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your documents will be automatically processed after email verification. Document numbers (CNIC, NTN, etc.) will be extracted using OCR and saved to your profile.',
                    style: AppTheme.captionStyle.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  if (_cnicImage != null)
                    _buildExtractedDataItem(
                      'CNIC Document',
                      '✓ Uploaded - Ready for processing',
                      Icons.credit_card_rounded,
                    ),
                  if (_utilityImage != null)
                    _buildExtractedDataItem(
                      'Utility Bill',
                      '✓ Uploaded - Ready for processing',
                      Icons.receipt_long_rounded,
                    ),
                  if (_ntnImage != null)
                    _buildExtractedDataItem(
                      'NTN Certificate',
                      '✓ Uploaded - Ready for processing',
                      Icons.account_balance_rounded,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildExtractedDataItem(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, size: 20, color: AppTheme.primaryGreen),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.captionStyle.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.bodyStyle.copyWith(
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

  Widget _buildDocumentUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required XFile? image,
    required VoidCallback onTap,
  }) {
    bool hasImage = image != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: hasImage ? AppTheme.primaryGreen.withOpacity(0.05) : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppTheme.primaryGreen : Colors.grey.shade300,
            width: hasImage ? 2 : 1,
            style: hasImage ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: Row(
          children: [
            // Icon or Image Preview
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: hasImage ? Colors.white : Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                image: hasImage
                    ? DecorationImage(
                        image: kIsWeb 
                            ? NetworkImage(image.path) 
                            : FileImage(File(image.path)) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasImage
                  ? Center(
                      child: Icon(
                        icon,
                        color: AppTheme.textLight.withOpacity(0.5),
                        size: 32,
                      ),
                    )
                  : null,
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasImage ? AppTheme.primaryGreen : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasImage ? 'Tap to change' : description,
                      style: AppTheme.captionStyle.copyWith(
                        fontSize: 12,
                        color: hasImage ? AppTheme.primaryGreen : AppTheme.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Action Icon
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasImage ? AppTheme.primaryGreen : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!hasImage)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                  ],
                ),
                child: Icon(
                  hasImage ? Icons.edit : Icons.add_a_photo_rounded,
                  color: hasImage ? Colors.white : AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    int? maxLines,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTheme.captionStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines ?? 1,
          onChanged: onChanged,
          style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyStyle.copyWith(
              color: AppTheme.textLight.withOpacity(0.5),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 50),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    int totalSteps = _getTotalSteps();
    bool isLastStep = _currentStep == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button removed as per request
          // if (_currentStep > 0)
          //   Expanded(
          //     child: OutlinedButton(
          //       onPressed: () => setState(() => _currentStep--),
          //       child: const Text('Previous'),
          //     ),
          //   ),
          // if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (isLastStep) {
                        _handleRegister();
                      } else {
                        _handleNextStep();
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(isLastStep ? 'Create Account' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNextStep() async {
    FocusScope.of(context).unfocus(); // Close keyboard
    final isValid = await _validateCurrentStep();
    if (isValid && mounted) {
      setState(() => _currentStep++);
    }
  }

  Future<bool> _validateCurrentStep() async {
    switch (_currentStep) {
      case 0:
        // Validate basic info
        if (_nameController.text.trim().isEmpty) {
          _showSnackBar('Please enter your name', isError: true);
          return false;
        }
        if (widget.role == 'warehouse' &&
            _businessNameController.text.trim().isEmpty) {
          _showSnackBar('Please enter business name', isError: true);
          return false;
        }
        if (widget.role == 'company' &&
            _companyNameController.text.trim().isEmpty) {
          _showSnackBar('Please enter company name', isError: true);
          return false;
        }
        if (_emailController.text.trim().isEmpty) {
          _showSnackBar('Please enter email', isError: true);
          return false;
        }
        if (_passwordController.text.isEmpty) {
          _showSnackBar('Please enter password', isError: true);
          return false;
        }
        if (_contactNoController.text.trim().isEmpty) {
          _showSnackBar('Please enter contact number', isError: true);
          return false;
        }
        if (_contactNoController.text.trim().isEmpty) {
          _showSnackBar('Please enter contact number', isError: true);
          return false;
        }
        if (_selectedCity == null || _selectedArea == null) {
          _showSnackBar('Please select city and area', isError: true);
          return false;
        }
        if (_addressController.text.trim().isEmpty) {
          _showSnackBar('Please enter street address', isError: true);
          return false;
        }
        
         // Profile image is optional for Individuals again, as backend accepts it.
         // if (_profileImage == null) {
         //    _showSnackBar('Profile picture is required', isError: true);
         //    return false;
         // }

         if (!(_formKey.currentState?.validate() ?? false)) {
           return false;
         }

         // Check email existence asynchronously
         setState(() => _isLoading = true);
         try {
           final authService = context.read<AuthService>();
           final result = await authService.checkEmail(_emailController.text.trim());
           if (result['success'] == true) {
             final exists = result['data']['exists'] == true;
             if (exists) {
               _showSnackBar('Email already exists. Please login or use another email.', isError: true);
               return false;
             }
           } else {
             _showSnackBar('Failed to validate email: ${result['message']}', isError: true);
             return false;
           }
         } catch (e) {
           _showSnackBar('Error validating email', isError: true);
           return false;
         } finally {
           if (mounted) setState(() => _isLoading = false);
         }

         return true;
      case 1:
        if (widget.role == 'warehouse' || widget.role == 'company') {
          if (_cnicImage == null) {
            _showSnackBar('Please upload CNIC document', isError: true);
            return false;
          }
        }
        if (widget.role == 'company') {
          if (_utilityImage == null) {
            _showSnackBar('Please upload utility bill', isError: true);
            return false;
          }
          if (_ntnImage == null) {
            _showSnackBar('Please upload NTN certificate', isError: true);
            return false;
          }
        }
        return true;
      case 2:
        return true;
      default:
        return true;
    }
  }

  int _getTotalSteps() {
    // Individual: Basic Info -> Verification
    // Warehouse/Company: Basic Info -> Documents -> Verification
    return widget.role == 'individual' ? 2 : 3;
  }

  Future<void> _onCnicImageSelected(dynamic imageData) async {
    if (imageData == null) return;

    setState(() => _cnicImage = imageData);

    // Analyze document immediately to extract CNIC
    await _analyzeDocument(imageData, 'CNIC');
  }

  Future<void> _onUtilityImageSelected(dynamic imageData) async {
    if (imageData == null) return;

    setState(() => _utilityImage = imageData);

    // Show success message
    _showSnackBar(
        'Utility bill uploaded! Will be processed after verification.',
        isError: false);
  }

  Future<void> _onNtnImageSelected(dynamic imageData) async {
    if (imageData == null) return;

    setState(() => _ntnImage = imageData);

    // Analyze document immediately to extract NTN
    await _analyzeDocument(imageData, 'NTN');
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();

      final Map<String, dynamic> userData = {
        'role': widget.role,
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'address': '${_addressController.text.trim()}, $_selectedArea, $_selectedCity', // Combine for backend
        'city': _selectedCity,
        'area': _selectedArea,
        'streetAddress': _addressController.text.trim(),
        'contactNo': _contactNoController.text.trim(),
        'name': _nameController.text.trim(), // Always include name
      };

      if (_cnicController.text.isNotEmpty) {
        userData['cnic'] = _cnicController.text.trim();
      }

      if (widget.role == 'warehouse') {
        userData['businessName'] = _businessNameController.text.trim();
      } else if (widget.role == 'company') {
        userData['companyName'] = _companyNameController.text.trim();
      }
      
      // Prepare files map
      final Map<String, XFile> files = {};
      
      // Reverting to 'profileImage'
      if (_profileImage != null) files['profileImage'] = _profileImage!; 
      
      // Restoring other files
      if (_cnicImage != null) files['cnic'] = _cnicImage!;
      if (_utilityImage != null) files['utility'] = _utilityImage!;
      if (_ntnImage != null) files['ntn'] = _ntnImage!;
      
      if (kDebugMode) {
        print('Registration Files Check: ${files.keys.toList()}');
      }

      final response = await authService.register(userData, files);

      if (mounted) {
        if (response['success'] == true) {
          _showSnackBar(
            response['message'] ??
                'Registration initiated. Check your email for OTP.',
            isError: false,
          );

          // Navigate to OTP verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            ),
          );
        } else {
          _showSnackBar(
            response['message'] ?? 'Registration failed',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Registration failed: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMet ? AppTheme.primaryGreen.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet ? AppTheme.primaryGreen : Colors.grey.shade400,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTheme.captionStyle.copyWith(
              fontSize: 11,
              color: isMet ? AppTheme.primaryGreen : Colors.grey.shade600,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppTheme.textDark : AppTheme.textLight,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getRoleDisplayName() {
    switch (widget.role) {
      case 'individual':
        return 'Individual';
      case 'warehouse':
        return 'Warehouse';
      case 'company':
        return 'Company';
      default:
        return 'User';
    }
  }

  IconData _getRoleIcon() {
    switch (widget.role) {
      case 'individual':
        return Icons.person_rounded;
      case 'warehouse':
        return Icons.warehouse_rounded;
      case 'company':
        return Icons.business_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getRoleDescription() {
    switch (widget.role) {
      case 'individual':
        return 'Join as an individual to manage your personal recycling activities and contribute to a cleaner environment';
      case 'warehouse':
        return 'Register your warehouse to manage waste collection operations and connect with recyclers';
      case 'company':
        return 'Register your company for corporate waste management solutions and sustainability reporting';
      default:
        return '';
    }
  }
}
