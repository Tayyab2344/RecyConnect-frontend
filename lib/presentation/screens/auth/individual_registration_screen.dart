import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/image_source_helper.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/pakistan_locations.dart';
import '../../widgets/city_area_selector.dart';
import 'otp_verification_screen.dart';

class IndividualRegistrationScreen extends StatefulWidget {
  const IndividualRegistrationScreen({super.key});

  @override
  State<IndividualRegistrationScreen> createState() => _IndividualRegistrationScreenState();
}

class _IndividualRegistrationScreenState extends State<IndividualRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Location dropdowns
  String? _selectedCity;
  String? _selectedArea;
  double? _latitude;
  double? _longitude;
  bool _isDetectingLocation = false;
  String? _locationMethod; // "auto" or "manual"
  
  XFile? _profileImage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  
  // Password requirements tracking
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        
        final userData = {
          'role': 'individual',
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'contactNo': _phoneController.text.trim(),
          'address': '$_selectedArea, $_selectedCity',
          'city': _selectedCity,
          'password': _passwordController.text,
          if (_latitude != null) 'latitude': _latitude,
          if (_longitude != null) 'longitude': _longitude,
          if (_locationMethod != null) 'locationMethod': _locationMethod,
          'locationPermission': _locationMethod == 'auto',
        };

        // Add profile image if selected
        final files = <String, XFile>{};
        if (_profileImage != null) {
          files['profileImage'] = _profileImage!;
        }

        final result = await authService.register(userData, files);

        if (mounted) {
          setState(() => _isLoading = false);

          if (result['success'] == true) {
            // Navigate to OTP verification
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Registration failed'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await ImageSourceHelper.pickImage(context);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetectingLocation = true);

    try {
      final locationService = LocationService();

      // Detect location with smart matching
      final result = await locationService.detectLocationAndMatch(
        PakistanLocations.cities,
        (city) => PakistanLocations.getAreasForCity(city),
      );

      if (result == null) {
        // Location detection failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Unable to detect location. Please select manually.'),
              backgroundColor: AppTheme.errorRed,
              action: SnackBarAction(
                label: 'Enable',
                textColor: Colors.white,
                onPressed: () async{
                  await locationService.openLocationSettings();
                },
              ),
            ),
          );
        }
        setState(() => _isDetectingLocation = false);
        return;
      }

      // Update state with detected location
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _selectedCity = result['city'];
        _selectedArea = result['area'];
        _locationMethod = 'auto';
        _isDetectingLocation = false;
      });

      if (mounted) {
        String message = 'Location detected!';
        if (_selectedCity != null) {
          message += ' ✓ $_selectedCity';
          if (_selectedArea != null) {
            message += ', $_selectedArea';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isDetectingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error detecting location: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _checkPasswordStrength(String password) {
    double strength = 0.0;
    String strengthText = '';

    // Track individual requirements
    _hasMinLength = password.length >= 8;
    _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    _hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    _hasNumber = RegExp(r'\d').hasMatch(password);

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
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;
      
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
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Account',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Join RecyConnect',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journey towards sustainable living',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Picture Section
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: kIsWeb
                                  ? Image.network(
                                      _profileImage!.path,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.person_outline,
                                            size: 60,
                                            color: AppTheme.primaryGreen.withOpacity(0.5),
                                          ),
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(_profileImage!.path),
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    ),
                            )
                          : Stack(
                              children: [
                                Center(
                                  child: _emailController.text.isNotEmpty
                                      ? Text(
                                          _emailController.text[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person_outline,
                                          size: 60,
                                          color: AppTheme.primaryGreen.withOpacity(0.5),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Removed Optional text
                const SizedBox(height: 24),

                // Full Name
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Name can only contain letters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'your.email@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    // Trigger rebuild to update profile picture
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '03001234567',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Remove spaces and dashes
                    String cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
                    if (!RegExp(r'^03[0-9]{9}$').hasMatch(cleaned)) {
                      return 'Must be 11 digits starting with 03';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Removed Detect Location button and divider section

                // City & Area Selector
                CityAreaSelector(
                  selectedCity: _selectedCity,
                  selectedArea: _selectedArea,
                  onCityChanged: (city) {
                    setState(() {
                      _selectedCity = city;
                      _selectedArea = null; // Reset area when city changes
                      if (city != null) _locationMethod = 'manual'; // User manually selected
                    });
                  },
                  onAreaChanged: (area) {
                    setState(() {
                      _selectedArea = area;
                      if (area != null) _locationMethod = 'manual'; // User manually selected
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Password
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Create a strong password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onTogglePassword: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                  onChanged: (value) {
                    _checkPasswordStrength(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                      return 'Must contain uppercase, lowercase & number';
                    }
                    return null;
                  },
                ),
                
                // Password Strength Indicator
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
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
                  _buildRequirement('At least 8 characters', _hasMinLength),
                  _buildRequirement('One uppercase letter', _hasUppercase),
                  _buildRequirement('One lowercase letter', _hasLowercase),
                  _buildRequirement('One number', _hasNumber),
                ],
                const SizedBox(height: 16),

                // Confirm Password
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  onTogglePassword: () {
                    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to login screen
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          obscureText: isPassword && !isPasswordVisible,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.black87), // Force dark text color
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textLight.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textLight,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            filled: true,
            fillColor: AppTheme.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.errorRed,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.errorRed,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
