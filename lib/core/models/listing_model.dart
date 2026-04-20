import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ListingUser {
  final int id;
  final String? name;
  final String? email;
  final String? contactNo;
  final DateTime? createdAt;

  ListingUser({
    required this.id,
    this.name,
    this.email,
    this.contactNo,
    this.createdAt,
  });

  factory ListingUser.fromJson(Map<String, dynamic> json) {
    return ListingUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      contactNo: json['contactNo'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
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
  final String? title;
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
    this.title,
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
      title: json['title'],
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
      'title': title,
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
      if (title != null && title!.isNotEmpty) 'title': title,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (images != null && images!.isNotEmpty) 'images': images,
    };
  }

  /// Check if images are network URLs (Cloudinary) rather than base64
  bool get hasNetworkImages {
    if (images == null || images!.isEmpty) return false;
    return images!.first.startsWith('http://') || images!.first.startsWith('https://');
  }

  /// Get image URLs for network images (Cloudinary URLs)
  List<String> get imageUrls {
    if (images == null || images!.isEmpty) return [];
    return images!.where((img) => img.startsWith('http://') || img.startsWith('https://')).toList();
  }

  /// Decode base64 images (legacy support)
  List<Uint8List> get decodedImages {
    if (images == null || images!.isEmpty) return [];
    return images!.where((img) => !img.startsWith('http://') && !img.startsWith('https://')).map((img) {
      try {
        return base64Decode(img);
      } catch (e) {
        if (kDebugMode) print('Error decoding image: $e');
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

  /// Returns the user-provided title, or falls back to "X kg of Material"
  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!;
    }
    return '$estimatedWeight kg of $materialTypeDisplay';
  }
}

