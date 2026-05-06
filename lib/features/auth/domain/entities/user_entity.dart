/// Pure domain entity representing a User.
/// This has NO dependency on Flutter, JSON, or any external package.
/// It represents the core business concept of a user in the system.
class UserEntity {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final String? phone;
  final String? address;
  final String? city;
  final String? area;
  final String? profileImage;
  final int? collectorId;
  final String? verificationStatus;
  final String? kycStage;
  final String? rejectionReason;
  final String? businessName;
  final String? companyName;
  final String? businessType;
  final String? registrationNumber;

  const UserEntity({
    this.id,
    this.name,
    this.email,
    this.role,
    this.phone,
    this.address,
    this.city,
    this.area,
    this.profileImage,
    this.collectorId,
    this.verificationStatus,
    this.kycStage,
    this.rejectionReason,
    this.businessName,
    this.companyName,
    this.businessType,
    this.registrationNumber,
  });

  /// Get the display name (handles different user types)
  String get displayName =>
      name ?? businessName ?? companyName ?? 'User';

  /// Check if the user is verified
  bool get isVerified => verificationStatus == 'APPROVED';

  /// Check if the user is pending verification
  bool get isPending => verificationStatus == 'PENDING';
}
