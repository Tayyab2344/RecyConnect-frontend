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
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
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
  final double quantity;
  final List<ListingOrderItem> orderItems;

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
    this.quantity = 0,
    this.orderItems = const [],
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : null;
    final createdAt = DateTime.parse(json['createdAt']);

    return Listing(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse('${json['userId'] ?? userJson?['id']}') ?? 0,
      materialType: json['materialType'],
      estimatedWeight: (json['estimatedWeight'] as num).toDouble(),
      quantity: json['quantity'] != null ? (json['quantity'] as num).toDouble() : 0,
      pickupAddress: json['pickupAddress'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      locationMethod: json['locationMethod'],
      title: json['title'],
      notes: json['notes'],
      status: json['status'],
      buyerInfo: json['buyerInfo'],
      createdAt: createdAt,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : createdAt,
      user: userJson != null ? ListingUser.fromJson(userJson) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      orderItems: json['orderItems'] is List
          ? (json['orderItems'] as List)
              .map((item) => ListingOrderItem.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList()
          : const [],
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
      'quantity': quantity,
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

  double get orderedWeight {
    return orderItems.fold(0.0, (sum, item) => sum + item.quantity);
  }

  double get availableWeight {
    if (estimatedWeight > 0) return estimatedWeight;
    if (quantity > 0) return quantity;
    return 0;
  }

  double get displayWeight {
    if (availableWeight > 0) return availableWeight;
    return orderedWeight;
  }

  bool get hasOpenOrder {
    return orderItems.any((item) {
      final status = item.orderStatus?.toUpperCase();
      return status == 'CREATED' || status == 'CONFIRMED' || status == 'PENDING';
    });
  }

  bool get hasOrders => orderItems.isNotEmpty;

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
    if (status == 'SOLD' && hasOpenOrder) {
      return 'Order Pending';
    }
    switch (status) {
      case 'DRAFT':
        return 'Draft';
      case 'PUBLISHED':
        return 'Active';
      case 'PAUSED':
        return 'Paused';
      case 'SOLD':
        return 'Sold';
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
    return '$displayWeight kg of $materialTypeDisplay';
  }
}

class ListingOrderItem {
  final double quantity;
  final int? orderId;
  final String? orderStatus;
  final String? buyerName;
  final DateTime? createdAt;

  ListingOrderItem({
    required this.quantity,
    this.orderId,
    this.orderStatus,
    this.buyerName,
    this.createdAt,
  });

  factory ListingOrderItem.fromJson(Map<String, dynamic> json) {
    final order = json['order'] is Map
        ? Map<String, dynamic>.from(json['order'] as Map)
        : null;
    final buyer = order?['buyer'] is Map
        ? Map<String, dynamic>.from(order!['buyer'] as Map)
        : null;

    return ListingOrderItem(
      quantity: json['quantity'] != null ? (json['quantity'] as num).toDouble() : 0,
      orderId: order?['id'] as int?,
      orderStatus: order?['status'] as String?,
      buyerName: buyer?['name'] as String?,
      createdAt: order?['createdAt'] != null
          ? DateTime.tryParse(order!['createdAt'] as String)
          : null,
    );
  }
}

