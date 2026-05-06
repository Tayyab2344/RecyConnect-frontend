import '../../domain/entities/user_entity.dart';

/// Data Transfer Object for User data.
/// This class knows about JSON serialization (fromJson/toJson).
/// It extends UserEntity so it IS-A UserEntity but also has serialization.
///
/// Flow: API Response → UserModel.fromJson() → UserEntity (used in domain/UI)
class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.name,
    super.email,
    super.role,
    super.phone,
    super.address,
    super.city,
    super.area,
    super.profileImage,
    super.collectorId,
    super.verificationStatus,
    super.kycStage,
    super.rejectionReason,
    super.businessName,
    super.companyName,
    super.businessType,
    super.registrationNumber,
  });

  /// Create a UserModel from a JSON map (API response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      phone: (json['phone'] ?? json['contactNo']) as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      area: json['area'] as String?,
      profileImage: json['profileImage'] as String?,
      collectorId: (json['collectorId'] as num?)?.toInt(),
      verificationStatus: json['verificationStatus'] as String?,
      kycStage: json['kycStage'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      businessName: json['businessName'] as String?,
      companyName: json['companyName'] as String?,
      businessType: json['businessType'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
    );
  }

  /// Convert to a JSON map for API requests / local storage.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (area != null) 'area': area,
      if (profileImage != null) 'profileImage': profileImage,
      if (collectorId != null) 'collectorId': collectorId,
      if (verificationStatus != null) 'verificationStatus': verificationStatus,
      if (kycStage != null) 'kycStage': kycStage,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (businessName != null) 'businessName': businessName,
      if (companyName != null) 'companyName': companyName,
      if (businessType != null) 'businessType': businessType,
      if (registrationNumber != null) 'registrationNumber': registrationNumber,
    };
  }

  /// Convert a raw API response user map to the simplified map that was
  /// previously stored by the old AuthService (backward compatibility).
  static Map<String, dynamic> toStorageMap(Map<String, dynamic> userData, {
    String? verificationStatus,
    String? kycStage,
    String? rejectionReason,
  }) {
    return {
      'id': userData['id'],
      'role': userData['role'],
      'name': userData['name'] ?? userData['businessName'] ?? userData['companyName'],
      'collectorId': userData['collectorId'],
      'verificationStatus': verificationStatus,
      'kycStage': kycStage,
      'rejectionReason': rejectionReason,
    };
  }
}
