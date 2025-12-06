/// Form validators - Centralized validation logic
/// SRP: Only responsible for form validation
/// DRY: Reused across all auth and form screens
class FormValidators {
  // ============================================
  // EMAIL VALIDATION
  // ============================================

  /// Validate email format
  static String? email(String? value, {String fieldName = 'Email'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ============================================
  // PASSWORD VALIDATION
  // ============================================

  /// Validate password with strength requirements
  static String? password(String? value, {
    int minLength = 8,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumber = false,
    bool requireSpecial = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (requireNumber && !value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (requireSpecial && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validate password confirmation matches
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ============================================
  // PHONE VALIDATION
  // ============================================

  /// Validate phone number
  static String? phone(String? value, {
    String fieldName = 'Phone number',
    int minDigits = 10,
    int maxDigits = 15,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < minDigits || digitsOnly.length > maxDigits) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ============================================
  // GENERAL VALIDATIONS
  // ============================================

  /// Validate required field
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int length, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < length) {
      return '$fieldName must be at least $length characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int length, [String fieldName = 'Field']) {
    if (value != null && value.length > length) {
      return '$fieldName must be at most $length characters';
    }
    return null;
  }

  /// Validate name (letters and spaces only)
  static String? name(String? value, [String fieldName = 'Name']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  // ============================================
  // BUSINESS VALIDATIONS
  // ============================================

  /// Validate business name
  static String? businessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Business name is required';
    }
    if (value.length < 2) {
      return 'Business name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Business name must be at most 100 characters';
    }
    return null;
  }

  /// Validate NTN (National Tax Number) - Pakistan format
  static String? ntn(String? value) {
    if (value == null || value.isEmpty) {
      return 'NTN is required';
    }
    // NTN format: 7 digits followed by a dash and a single digit
    if (!RegExp(r'^\d{7}-\d$').hasMatch(value)) {
      return 'Enter a valid NTN (format: 1234567-8)';
    }
    return null;
  }

  /// Validate CNIC (Pakistan ID)
  static String? cnic(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNIC is required';
    }
    // CNIC format: 13 digits with dashes: 12345-1234567-1
    final digitsOnly = value.replaceAll('-', '');
    if (digitsOnly.length != 13 || !RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return 'Enter a valid CNIC (format: 12345-1234567-1)';
    }
    return null;
  }

  // ============================================
  // NUMERIC VALIDATIONS
  // ============================================

  /// Validate numeric input
  static String? number(String? value, [String fieldName = 'Value']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, [String fieldName = 'Value']) {
    final error = number(value, fieldName);
    if (error != null) return error;
    
    if (double.parse(value!) <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  /// Validate number in range
  static String? numberInRange(String? value, double min, double max, [String fieldName = 'Value']) {
    final error = number(value, fieldName);
    if (error != null) return error;
    
    final num = double.parse(value!);
    if (num < min || num > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  // ============================================
  // OTP VALIDATION
  // ============================================

  /// Validate OTP code
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter the verification code';
    }
    if (value.length != length) {
      return 'OTP must be $length digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  // ============================================
  // URL VALIDATION
  // ============================================

  /// Validate URL format
  static String? url(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'URL is required' : null;
    }
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!urlPattern.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  // ============================================
  // COMBINATOR METHODS
  // ============================================

  /// Combine multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
