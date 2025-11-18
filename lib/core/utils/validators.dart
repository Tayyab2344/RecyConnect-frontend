class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]')
        .hasMatch(value)) {
      return 'Password must contain:\n• At least one uppercase letter\n• At least one lowercase letter\n• At least one number\n• At least one special character (@\$!%*?&)';
    }

    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  // Business/Company name validation
  static String? businessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Business name is required';
    }

    if (value.trim().length < 2) {
      return 'Business name must be at least 2 characters long';
    }

    if (value.trim().length > 100) {
      return 'Business name must not exceed 100 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9\s&.-]+$').hasMatch(value.trim())) {
      return 'Business name contains invalid characters';
    }

    return null;
  }

  // Company name validation (same as business name)
  static String? companyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company name is required';
    }

    return businessName(value);
  }

  // OTP validation
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }

    if (value.trim().length != 6) {
      return 'OTP must be exactly 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  // Collector ID validation
  static String? collectorId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Collector ID is required';
    }

    if (value.trim().length < 3 || value.trim().length > 20) {
      return 'Collector ID must be between 3 and 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value.trim())) {
      return 'Collector ID can only contain letters, numbers, hyphens, and underscores';
    }

    return null;
  }

  // Required field validation
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Phone number validation - Pakistani format: exactly 11 digits starting with 03
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove any spaces, dashes, or parentheses
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Must be exactly 11 digits starting with 03
    if (!RegExp(r'^03\d{9}$').hasMatch(cleanedValue)) {
      return 'Phone number must be 11 digits starting with 03 (e.g., 03001234567)';
    }

    return null;
  }

  // Address validation
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.trim().length < 10) {
      return 'Address must be at least 10 characters long';
    }

    if (value.trim().length > 200) {
      return 'Address must not exceed 200 characters';
    }

    return null;
  }
}
