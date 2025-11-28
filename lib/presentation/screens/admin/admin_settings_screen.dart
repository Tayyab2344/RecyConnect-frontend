import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/admin_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/preferences_service.dart';
import '../../screens/auth/login_screen.dart';
import '../../widgets/admin/admin_drawer.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // Profile controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Password controllers
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Password visibility states
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Profile image
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileImageBytes;
  bool _isLoading = true;
  bool _isSavingProfile = false;
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile data from preferences
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final name = await PreferencesService.getAdminName();
      final email = await PreferencesService.getAdminEmail();
      final contact = await PreferencesService.getAdminContact();
      final profileImage = await PreferencesService.getProfileImage();

      setState(() {
        _nameController.text = name;
        _emailController.text = email;
        _phoneController.text = contact;

        if (profileImage != null && profileImage.isNotEmpty) {
          try {
            _profileImageBytes = base64Decode(profileImage);
          } catch (e) {
            _profileImageBytes = null;
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load profile data', isError: true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE PHOTO UPLOAD
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _pickProfilePhoto() async {
    try {
      // Show options dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.photo_camera, color: AdminColors.primaryGreen),
              SizedBox(width: 12),
              Text('Choose Photo'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.photo_library, color: AdminColors.accentBlue),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from your photos'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: AdminColors.primaryGreen),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
          actions: [
            if (_profileImageBytes != null)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _removeProfilePhoto();
                },
                child: const Text(
                  'Remove Photo',
                  style: TextStyle(color: AdminColors.accentRed),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (source == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        // Read file as bytes
        final bytes = await pickedFile.readAsBytes();

        // Convert to base64 for storage
        final base64String = base64Encode(bytes);

        // Save to preferences
        await PreferencesService.saveProfileImage(base64String);

        setState(() {
          _profileImageBytes = bytes;
        });

        if (mounted) {
          _showSnackBar('Profile photo updated successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to pick image: $e', isError: true);
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    await PreferencesService.clearProfileImage();
    setState(() {
      _profileImageBytes = null;
    });
    _showSnackBar('Profile photo removed');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PASSWORD STRENGTH
  // ═══════════════════════════════════════════════════════════════════════════

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;

    // Uppercase check
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;

    // Lowercase check
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.1;

    // Number check
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

    // Special character check
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    return strength.clamp(0.0, 1.0);
  }

  String _getPasswordStrengthLabel(double strength) {
    if (strength <= 0.3) return 'Weak';
    if (strength <= 0.6) return 'Medium';
    return 'Strong';
  }

  Color _getPasswordStrengthColor(double strength) {
    if (strength <= 0.3) return AdminColors.accentRed;
    if (strength <= 0.6) return AdminColors.accentOrange;
    return AdminColors.primaryGreen;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE PROFILE CHANGES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveProfileChanges() async {
    // Validate
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Name cannot be empty', isError: true);
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('Contact number cannot be empty', isError: true);
      return;
    }

    // Validate phone format (simple check)
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _showSnackBar('Please enter a valid contact number', isError: true);
      return;
    }

    setState(() => _isSavingProfile = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Save to preferences
      await PreferencesService.saveAdminName(_nameController.text.trim());
      await PreferencesService.saveAdminContact(_phoneController.text.trim());

      if (mounted) {
        setState(() => _isSavingProfile = false);
        _showSuccessDialog(
          title: 'Profile Updated',
          message: 'Your profile information has been saved successfully.',
          icon: Icons.check_circle,
          iconColor: AdminColors.primaryGreen,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingProfile = false);
        _showSnackBar('Failed to save profile: $e', isError: true);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE PASSWORD
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _updatePassword() async {
    // Validate all fields
    if (_currentPasswordController.text.isEmpty) {
      _showSnackBar('Please enter your current password', isError: true);
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Please enter a new password', isError: true);
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showSnackBar('Please confirm your new password', isError: true);
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showSnackBar('Password must be at least 8 characters', isError: true);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    // Check password strength
    final strength = _getPasswordStrength(_newPasswordController.text);
    if (strength < 0.5) {
      _showSnackBar(
        'Please choose a stronger password with uppercase, numbers',
        isError: true,
      );
      return;
    }

    setState(() => _isUpdatingPassword = true);

    try {
      // Verify current password
      final isValid = await PreferencesService.verifyPassword(
        _currentPasswordController.text,
      );

      if (!isValid) {
        if (mounted) {
          setState(() => _isUpdatingPassword = false);
          _showSnackBar('Current password is incorrect', isError: true);
        }
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Save new password
      await PreferencesService.saveAdminPassword(_newPasswordController.text);

      if (mounted) {
        setState(() => _isUpdatingPassword = false);

        // Clear fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _showCurrentPassword = false;
          _showNewPassword = false;
          _showConfirmPassword = false;
        });

        _showSuccessDialog(
          title: 'Password Updated',
          message:
              'Your password has been changed successfully. Please use your new password for future logins.',
          icon: Icons.lock,
          iconColor: AdminColors.primaryGreen,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdatingPassword = false);
        _showSnackBar('Failed to update password: $e', isError: true);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════════════════

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AdminColors.accentRed),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to logout from the admin panel?'),
            SizedBox(height: 12),
            Text(
              'You will need to enter your credentials again to access the dashboard.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AdminColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.accentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AdminColors.primaryGreen),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate logout process
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      // Navigate to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS & SNACKBARS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? AdminColors.accentRed : AdminColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD UI
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      drawer: const AdminDrawer(currentRoute: 'settings'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AdminColors.primaryGreen),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Settings Section
                  _buildProfileSection(),
                  const SizedBox(height: 24),

                  // Security Section
                  _buildSecuritySection(),
                  const SizedBox(height: 24),

                  // App Settings Section
                  _buildAppSettingsSection(),
                  const SizedBox(height: 24),

                  // About Section
                  _buildAboutSection(),
                  const SizedBox(height: 24),

                  // Logout Section
                  _buildLogoutSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // Section header widget
  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: theme.dividerColor, thickness: 1),
        const SizedBox(height: 16),
      ],
    );
  }

  // Profile Section
  Widget _buildProfileSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Profile Settings', Icons.person),

        // Profile Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar with edit button
              _buildProfileAvatar(),
              const SizedBox(height: 24),

              // Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Email Field (disabled)
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                prefixIcon: Icons.email_outlined,
                enabled: false,
                suffixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 16),

              // Phone Field
              _buildTextField(
                controller: _phoneController,
                label: 'Contact Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSavingProfile ? null : _saveProfileChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: _isSavingProfile
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Profile Avatar with edit functionality
  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        // Avatar display
        GestureDetector(
          onTap: _pickProfilePhoto,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _profileImageBytes == null
                  ? AdminColors.primaryGradient
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AdminColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _profileImageBytes != null
                  ? Image.memory(
                      _profileImageBytes!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    )
                  : Center(
                      child: Text(
                        _getInitials(_nameController.text),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        // Edit button overlay
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickProfilePhoto,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AdminColors.primaryGreen,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AdminColors.primaryGreen,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'AD';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // Security Section
  Widget _buildSecuritySection() {
    final theme = Theme.of(context);
    final passwordStrength = _getPasswordStrength(_newPasswordController.text);
    final strengthLabel = _getPasswordStrengthLabel(passwordStrength);
    final strengthColor = _getPasswordStrengthColor(passwordStrength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Security', Icons.security),

        // Password Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Update your password regularly for security',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),

              // Current Password
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Current Password',
                isVisible: _showCurrentPassword,
                onToggle: () {
                  setState(() {
                    _showCurrentPassword = !_showCurrentPassword;
                  });
                },
              ),
              const SizedBox(height: 16),

              // New Password
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
                isVisible: _showNewPassword,
                onToggle: () {
                  setState(() {
                    _showNewPassword = !_showNewPassword;
                  });
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),

              // Password Strength Indicator
              if (_newPasswordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: passwordStrength,
                          backgroundColor: theme.dividerColor,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(strengthColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      strengthLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: strengthColor,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Confirm Password
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                isVisible: _showConfirmPassword,
                onToggle: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),

              // Password Match Indicator
              if (_confirmPasswordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _newPasswordController.text ==
                              _confirmPasswordController.text
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 16,
                      color: _newPasswordController.text ==
                              _confirmPasswordController.text
                          ? AdminColors.primaryGreen
                          : AdminColors.accentRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _newPasswordController.text ==
                              _confirmPasswordController.text
                          ? 'Passwords match'
                          : 'Passwords do not match',
                      style: TextStyle(
                        fontSize: 12,
                        color: _newPasswordController.text ==
                                _confirmPasswordController.text
                            ? AdminColors.primaryGreen
                            : AdminColors.accentRed,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Password Requirements
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement(
                      'At least 8 characters',
                      _newPasswordController.text.length >= 8,
                    ),
                    _buildRequirement(
                      'One uppercase letter',
                      _newPasswordController.text.contains(RegExp(r'[A-Z]')),
                    ),
                    _buildRequirement(
                      'One number',
                      _newPasswordController.text.contains(RegExp(r'[0-9]')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Update Password Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isUpdatingPassword ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: _isUpdatingPassword
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Password requirement item
  Widget _buildRequirement(String text, bool isMet) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet ? theme.colorScheme.primary : theme.iconTheme.color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  // App Settings Section
  Widget _buildAppSettingsSection() {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('App Settings', Icons.settings),

        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Theme Toggle (Functional with Provider)
              _buildSettingsTile(
                icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                iconColor: AdminColors.accentPurple,
                title: 'Theme',
                subtitle: isDarkMode ? 'Dark Mode' : 'Light Mode',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.setDarkMode(value);
                    _showSnackBar(
                      value ? 'Dark mode enabled' : 'Light mode enabled',
                    );
                  },
                  activeColor: AdminColors.primaryGreen,
                ),
                onTap: () {
                  themeProvider.toggleTheme();
                  _showSnackBar(
                    themeProvider.isDarkMode
                        ? 'Dark mode enabled'
                        : 'Light mode enabled',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // About Section
  Widget _buildAboutSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('About', Icons.info_outline),

        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // App Version
              _buildSettingsTile(
                icon: Icons.info,
                iconColor: AdminColors.accentBlue,
                title: 'App Version',
                subtitle: null,
                trailing: Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
                onTap: null,
              ),
              Divider(height: 1, color: theme.dividerColor),

              // Privacy Policy
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                iconColor: theme.colorScheme.primary,
                title: 'Privacy Policy',
                subtitle: null,
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.iconTheme.color,
                ),
                onTap: () => _showSnackBar('Privacy Policy - Coming soon'),
              ),
              Divider(height: 1, color: theme.dividerColor),

              // Terms of Service
              _buildSettingsTile(
                icon: Icons.description,
                iconColor: AdminColors.accentOrange,
                title: 'Terms of Service',
                subtitle: null,
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.iconTheme.color,
                ),
                onTap: () => _showSnackBar('Terms of Service - Coming soon'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Logout Section
  Widget _buildLogoutSection() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: AdminColors.accentRed),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: AdminColors.accentRed,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AdminColors.accentRed, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(
        color: enabled
            ? theme.textTheme.bodyLarge?.color
            : theme.textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        prefixIcon: Icon(prefixIcon, color: theme.iconTheme.color),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: theme.iconTheme.color, size: 20)
            : null,
        filled: true,
        fillColor: enabled ? Colors.transparent : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // Password field widget
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: onChanged,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        prefixIcon: Icon(Icons.lock_outline, color: theme.iconTheme.color),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: theme.iconTheme.color,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // Settings tile widget
  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color,
              ),
            )
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
