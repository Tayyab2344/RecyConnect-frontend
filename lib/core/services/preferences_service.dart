import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Keys
  static const String _keyAdminName = 'admin_name';
  static const String _keyAdminContact = 'admin_contact';
  static const String _keyAdminEmail = 'admin_email';
  static const String _keyProfileImage = 'profile_image_base64';
  static const String _keyDarkMode = 'dark_mode';
  // Password handling removed - use backend authentication only

  // ═══════════════════════════════════════════════════════════
  // ADMIN NAME
  // ═══════════════════════════════════════════════════════════

  static Future<void> saveAdminName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAdminName, name);
  }

  static Future<String> getAdminName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminName) ?? 'Admin User';
  }

  // ═══════════════════════════════════════════════════════════
  // ADMIN CONTACT
  // ═══════════════════════════════════════════════════════════

  static Future<void> saveAdminContact(String contact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAdminContact, contact);
  }

  static Future<String> getAdminContact() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminContact) ?? '+92-300-1234567';
  }

  // ═══════════════════════════════════════════════════════════
  // ADMIN EMAIL
  // ═══════════════════════════════════════════════════════════

  static Future<void> saveAdminEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAdminEmail, email);
  }

  static Future<String> getAdminEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminEmail) ?? '';
  }

  // ═══════════════════════════════════════════════════════════
  // PROFILE IMAGE (Base64 for web compatibility)
  // ═══════════════════════════════════════════════════════════

  static Future<void> saveProfileImage(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileImage, base64Image);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileImage);
  }

  static Future<void> clearProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProfileImage);
  }

  // ═══════════════════════════════════════════════════════════
  // DARK MODE
  // ═══════════════════════════════════════════════════════════

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  // ═══════════════════════════════════════════════════════════
  // PASSWORD (TEMPORARY FOR ADMIN SETTINGS)
  // ═══════════════════════════════════════════════════════════
  static const String _keyAdminPassword = 'admin_password';

  static Future<bool> verifyPassword(String inputPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString(_keyAdminPassword) ?? 'admin123';
    return inputPassword == savedPassword;
  }

  static Future<void> saveAdminPassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAdminPassword, newPassword);
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR ALL
  // ═══════════════════════════════════════════════════════════

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Clear user data but keep settings
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = await getDarkMode();
    await prefs.clear();
    await saveDarkMode(isDark);
  }
}
