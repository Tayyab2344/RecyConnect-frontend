import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
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
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _ntnController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactNoController = TextEditingController();

  File? _profileImage;
  File? _cnicImage;
  File? _utilityImage;
  File? _ntnImage;

  // Extracted document data (will be populated by backend OCR after OTP verification)
  String? _extractedCnicNumber;
  String? _extractedUtilityBillNumber;
  String? _extractedNtnNumber;

  bool _isLoading = false;
  bool _obscurePassword = true;
  int _currentStep = 0;

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          _profileImage = File(image.path);
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
          _cnicImage = File(image.path);
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
          _utilityImage = File(image.path);
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
          _ntnImage = File(image.path);
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textDark,
        ),
        title: Text(
          '${_getRoleDisplayName()} Registration',
          style: const TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.05),
              Colors.white,
              AppTheme.primaryGreen.withOpacity(0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWeb ? 600 : double.infinity),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(isWeb ? 48 : 24),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildProgressIndicator(),
                      const SizedBox(height: 32),
                      _buildStepContent(),
                      const SizedBox(height: 32),
                      _buildNavigationButtons(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryGreen.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              _getRoleIcon(),
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Create ${_getRoleDisplayName()} Account',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getRoleDescription(),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    int totalSteps = _getTotalSteps();

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            bool isCompleted = index < _currentStep;
            bool isCurrent = index == _currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? AppTheme.primaryGreen
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1) const SizedBox(width: 8),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          'Step ${_currentStep + 1} of $totalSteps',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      width: 3,
                    ),
                    image: _profileImage != null
                        ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppTheme.backgroundLight,
                  ),
                  child: _profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
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
          const SizedBox(height: 24),

          // Name field based on role
          if (widget.role == 'individual')
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
          const SizedBox(height: 20),

          _buildEnhancedTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'your.email@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 20),

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
          const SizedBox(height: 20),

          _buildEnhancedTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter your complete address',
            icon: Icons.location_on_outlined,
            keyboardType: TextInputType.streetAddress,
            validator: Validators.address,
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          _buildEnhancedTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a strong password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            validator: Validators.password,
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

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Password must be at least 8 characters',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Document Verification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.role == 'warehouse' || widget.role == 'company') ...[
            _buildDocumentUploadCard(
              title: 'CNIC Verification',
              description:
                  'Upload front side of your CNIC - Number will be extracted automatically',
              icon: Icons.credit_card_rounded,
              image: _cnicImage,
              onTap: _pickCnicImage,
            ),
            if (_cnicController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primaryGreen, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CNIC Number Extracted',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _cnicController.text,
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
          if (widget.role == 'company') ...[
            const SizedBox(height: 20),
            _buildDocumentUploadCard(
              title: 'Utility Bill',
              description: 'Recent electricity or gas bill',
              icon: Icons.receipt_long_rounded,
              image: _utilityImage,
              onTap: _pickUtilityImage,
            ),
            const SizedBox(height: 20),
            _buildDocumentUploadCard(
              title: 'NTN Certificate',
              description:
                  'National Tax Number certificate - Number will be extracted automatically',
              icon: Icons.account_balance_rounded,
              image: _ntnImage,
              onTap: _pickNtnImage,
            ),
            if (_ntnController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primaryGreen, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NTN Number Extracted',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _ntnController.text,
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
          if (widget.role == 'individual') ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 80,
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No documents required',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Individual accounts don\'t require document verification',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
              size: 60,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Review & Submit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please review your information before submitting',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 22,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Automatic Document Processing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your documents will be automatically processed after email verification. Document numbers (CNIC, NTN, etc.) will be extracted using OCR and saved to your profile.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, size: 20, color: AppTheme.primaryGreen),
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
            child: Icon(icon, size: 20, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textDark,
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
    required File? image,
    required VoidCallback onTap,
  }) {
    bool hasImage = image != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: hasImage
              ? AppTheme.primaryGreen.withOpacity(0.05)
              : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage
                ? AppTheme.primaryGreen.withOpacity(0.3)
                : Colors.grey.shade300,
            width: 2,
            style: hasImage ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasImage
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasImage ? Icons.check_circle_rounded : icon,
                color: hasImage ? Colors.white : AppTheme.primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasImage ? 'Document uploaded' : description,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          hasImage ? AppTheme.primaryGreen : AppTheme.textLight,
                      fontWeight:
                          hasImage ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasImage ? Icons.edit_rounded : Icons.upload_file_rounded,
              color: hasImage ? AppTheme.primaryGreen : AppTheme.textLight,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textLight.withOpacity(0.5),
              fontWeight: FontWeight.w400,
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
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    int totalSteps = _getTotalSteps();
    bool isLastStep = _currentStep == totalSteps - 1;

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Previous',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (isLastStep) {
                      _handleRegister();
                    } else {
                      if (_validateCurrentStep()) {
                        setState(() => _currentStep++);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastStep ? 'Create Account' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLastStep
                            ? Icons.check_circle_rounded
                            : Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Validate basic info
        if (widget.role == 'individual' &&
            _nameController.text.trim().isEmpty) {
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
        if (_addressController.text.trim().isEmpty) {
          _showSnackBar('Please enter address', isError: true);
          return false;
        }
        return _formKey.currentState?.validate() ?? false;
      case 1:
        // Validate documents - Only check if images are uploaded
        // Numbers will be extracted automatically by backend OCR
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

    // Show success message
    _showSnackBar(
        'CNIC uploaded! Number will be extracted automatically after verification.',
        isError: false);

    // Note: OCR extraction happens on backend after OTP verification
    // The extracted CNIC number will be stored in the user's profile
  }

  Future<void> _onUtilityImageSelected(dynamic imageData) async {
    if (imageData == null) return;

    setState(() => _utilityImage = imageData);

    // Show success message
    _showSnackBar(
        'Utility bill uploaded! Will be processed after verification.',
        isError: false);

    // Note: OCR extraction happens on backend after OTP verification
  }

  Future<void> _onNtnImageSelected(dynamic imageData) async {
    if (imageData == null) return;

    setState(() => _ntnImage = imageData);

    // Show success message
    _showSnackBar(
        'NTN uploaded! Number will be extracted automatically after verification.',
        isError: false);

    // Note: OCR extraction happens on backend after OTP verification
    // The extracted NTN number will be stored in the user's profile
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
        'address': _addressController.text.trim(),
        'contactNo': _contactNoController.text.trim(),
      };

      if (widget.role == 'individual') {
        userData['name'] = _nameController.text.trim();
      } else if (widget.role == 'warehouse') {
        userData['businessName'] = _businessNameController.text.trim();
      } else if (widget.role == 'company') {
        userData['companyName'] = _companyNameController.text.trim();
      }

      final response = await authService.register(userData);

      if (mounted) {
        if (response['success'] == true) {
          _showSnackBar(
            response['message'] ??
                'Registration initiated. Check your email for OTP.',
            isError: false,
          );

          // Navigate to OTP verification screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                email: _emailController.text.trim(),
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
