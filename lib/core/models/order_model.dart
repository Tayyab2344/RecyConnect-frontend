class Order {
  final int id;
  final int buyerId;
  final int sellerId;
  final String status;
  final double totalAmount;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional nested user data
  final OrderUser? buyer;
  final OrderUser? seller;

  // Optional order items (from backend items array)
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.totalAmount,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.buyer,
    this.seller,
    this.items,
  });

  /// Parse the actual backend response shape:
  /// { id, buyerId, sellerId, status, totalAmount, createdAt, updatedAt,
  ///   buyer:{...}, seller:{...}, items:[{listingId, quantity, price, listing:{...}}] }
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      buyerId: json['buyerId'] as int,
      sellerId: json['sellerId'] as int,
      status: json['status'] as String? ?? 'CREATED',
      totalAmount: json['totalAmount'] != null
          ? (json['totalAmount'] as num).toDouble()
          : 0.0,
      paymentMethod: json['paymentMethod'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      buyer:
          json['buyer'] != null ? OrderUser.fromJson(json['buyer']) : null,
      seller:
          json['seller'] != null ? OrderUser.fromJson(json['seller']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => OrderItem.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'status': status,
      'totalAmount': totalAmount,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convenience getters derived from items
  String get materialType {
    if (items != null && items!.isNotEmpty) {
      return items!.first.listing?['materialType'] as String? ?? '';
    }
    return '';
  }

  double get weight {
    if (items != null && items!.isNotEmpty) {
      return items!.fold(0.0, (sum, i) => sum + i.quantity);
    }
    return 0.0;
  }

  String get statusDisplay {
    switch (status) {
      case 'CREATED':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
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
        if (materialType.isEmpty) return 'Unknown';
        // Capitalize first letter as fallback
        if (materialType.length > 1) {
          return materialType[0].toUpperCase() + materialType.substring(1);
        }
        return materialType;
    }
  }

  String get paymentMethodDisplay {
    if (paymentMethod == null) return 'N/A';
    switch (paymentMethod!.toLowerCase()) {
      case 'card':
        return 'Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cod':
      case 'cash':
        return 'Cash on Delivery';
      default:
        // Capitalize first letter as fallback
        if (paymentMethod!.length > 1) {
          return paymentMethod![0].toUpperCase() + paymentMethod!.substring(1);
        }
        return paymentMethod!;
    }
  }
}

class OrderItem {
  final int? id;
  final int listingId;
  final double quantity;
  final double price;
  final Map<String, dynamic>? listing;

  OrderItem({
    this.id,
    required this.listingId,
    required this.quantity,
    required this.price,
    this.listing,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int?,
      listingId: json['listingId'] as int,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      listing: json['listing'] as Map<String, dynamic>?,
    );
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
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String?,
      contactNo: json['contactNo'] as String?,
      address: json['address'] as String?,
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
