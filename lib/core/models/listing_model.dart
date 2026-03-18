import 'dart:convert';
import 'dart:typed_data';

class ListingUser {
  final int id;
  final String? name;
  final String? email;
  final String? contactNo;

  ListingUser({
    required this.id,
    this.name,
    this.email,
    this.contactNo,
  });

  factory ListingUser.fromJson(Map<String, dynamic> json) {
    return ListingUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      contactNo: json['contactNo'],
    );
  }
}

class Listing {
  final int id;
  final int userId;
  final String materialType;
  final double estimatedWeight;
  final String pickupAddress;
  final double? latitude;
  final double? longitude;
  final String? locationMethod;
  final String? notes;
  final String status;
  final String? buyerInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ListingUser? user;
  final List<String>? images; // Image URLs or paths

  Listing({
    required this.id,
    required this.userId,
    required this.materialType,
    required this.estimatedWeight,
    required this.pickupAddress,
    this.latitude,
    this.longitude,
    this.locationMethod,
    this.notes,
    required this.status,
    this.buyerInfo,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.images,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      userId: json['userId'],
      materialType: json['materialType'],
      estimatedWeight: (json['estimatedWeight'] as num).toDouble(),
      pickupAddress: json['pickupAddress'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      locationMethod: json['locationMethod'],
      notes: json['notes'],
      status: json['status'],
      buyerInfo: json['buyerInfo'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? ListingUser.fromJson(json['user']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'materialType': materialType,
      'estimatedWeight': estimatedWeight,
      'pickupAddress': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'locationMethod': locationMethod,
      'notes': notes,
      'status': status,
      'buyerInfo': buyerInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'images': images,
    };
  }

  // Helper to create a new listing for API POST
  Map<String, dynamic> toCreateJson() {
    return {
      'materialType': materialType,
      'estimatedWeight': estimatedWeight,
      'pickupAddress': pickupAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationMethod != null) 'locationMethod': locationMethod,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (images != null && images!.isNotEmpty) 'images': images,
    };
  }

  List<Uint8List> get decodedImages {
    if (images == null || images!.isEmpty) return [];
    return images!.map((img) {
      try {
        return base64Decode(img);
      } catch (e) {
        print('Error decoding image: $e');
        return Uint8List(0);
      }
    }).where((img) => img.isNotEmpty).toList();
  }

  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'COLLECTED':
        return 'Collected';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get materialTypeDisplay {
    switch (materialType.toLowerCase()) {
      case 'plastic':
        return 'Plastic';
      case 'paper':
        return 'Paper';
      case 'metal':
        return 'Metal';
      case 'e-waste':
        return 'E-Waste';
      case 'glass':
        return 'Glass';
      case 'clothing':
        return 'Clothing';
      case 'other':
        return 'Other';
      default:
        return materialType;
    }
  }
}

