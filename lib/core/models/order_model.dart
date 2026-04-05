class Order {
  final int id;
  final int buyerId;
  final int sellerId;
  final String materialType;
  final double weight;
  final String pickupAddress;
  final double? latitude;
  final double? longitude;
  final String? locationMethod;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? reservationId;
  
  // Optional nested user data
  final OrderUser? buyer;
  final OrderUser? seller;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.materialType,
    required this.weight,
    required this.pickupAddress,
    this.latitude,
    this.longitude,
    this.locationMethod,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reservationId,
    this.buyer,
    this.seller,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      buyerId: json['buyerId'],
      sellerId: json['sellerId'],
      materialType: json['materialType'],
      weight: (json['weight'] as num).toDouble(),
      pickupAddress: json['pickupAddress'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      locationMethod: json['locationMethod'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      reservationId: json['reservationId'],
      buyer: json['buyer'] != null ? OrderUser.fromJson(json['buyer']) : null,
      seller: json['seller'] != null ? OrderUser.fromJson(json['seller']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'materialType': materialType,
      'weight': weight,
      'pickupAddress': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'locationMethod': locationMethod,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (reservationId != null) 'reservationId': reservationId,
    };
  }

  // Helper to create a new order for API POST
  Map<String, dynamic> toCreateJson({int? listingId}) {
    return {
      'sellerId': sellerId,
      'materialType': materialType,
      'weight': weight,
      'pickupAddress': pickupAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationMethod != null) 'locationMethod': locationMethod,
      'paymentMethod': paymentMethod,
      if (reservationId != null) 'reservationId': reservationId,
      if (listingId != null) 'listingId': listingId,
    };
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

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'COD':
        return 'Cash on Delivery';
      case 'WALLET':
        return 'Wallet';
      default:
        return paymentMethod;
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
      default:
        return materialType;
    }
  }
}

class OrderUser {
  final int id;
  final String? name;
  final String? email;
  final String? contactNo;
  final String? address;

  OrderUser({
    required this.id,
    this.name,
    this.email,
    this.contactNo,
    this.address,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      contactNo: json['contactNo'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contactNo': contactNo,
      'address': address,
    };
  }
}
