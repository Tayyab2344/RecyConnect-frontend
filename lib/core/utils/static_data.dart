// Material types and categories
class MaterialData {
  static const List<String> materialTypes = [
    'plastic',
    'paper',
    'metal',
    'e-waste',
  ];

  static const Map<String, String> materialIcons = {
    'plastic': '♻️',
    'paper': '📄',
    'metal': '🔩',
    'e-waste': '💻',
  };

  static const Map<String, String> materialColors = {
    'plastic': '#4CAF50',
    'paper': '#FF9800',
    'metal': '#757575',
    'e-waste': '#2196F3',
  };

  static const Map<String, double> materialRates = {
    'plastic': 45.0, // PKR per kg
    'paper': 25.0,
    'metal': 120.0,
    'e-waste': 80.0,
  };
}

// Status types
class StatusData {
  static const List<String> listingStatuses = [
    'PENDING',
    'COLLECTED',
    'COMPLETED',
    'CANCELLED',
  ];

  static const List<String> orderStatuses = [
    'PENDING',
    'COLLECTED',
    'COMPLETED',
    'CANCELLED',
  ];

  static const Map<String, String> statusColors = {
    'PENDING': '#FFA000',
    'COLLECTED': '#2196F3',
    'COMPLETED': '#4CAF50',
    'CANCELLED': '#F44336',
  };
}

// Sample marketplace items (static simulation)
class MarketplaceData {
  static final List<Map<String, dynamic>> sampleItems = [
    {
      'id': 1,
      'sellerId': 100,
      'sellerName': 'Ali Khan',
      'materialType': 'plastic',
      'weight': 5.5,
      'price': 247.5,
      'pickupAddress': 'F-7 Markaz, Islamabad',
      'status': 'AVAILABLE',
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 2,
      'sellerId': 101,
      'sellerName': 'Sara Ahmed',
      'materialType': 'paper',
      'weight': 8.0,
      'price': 200.0,
      'pickupAddress': 'Blue Area, Islamabad',
      'status': 'AVAILABLE',
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': 3,
      'sellerId': 102,
      'sellerName': 'Hassan Raza',
      'materialType': 'metal',
      'weight': 3.2,
      'price': 384.0,
      'pickupAddress': 'I-10 Markaz, Islamabad',
      'status': 'AVAILABLE',
      'createdAt': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
    },
    {
      'id': 4,
      'sellerId': 103,
      'sellerName': 'Fatima Malik',
      'materialType': 'e-waste',
      'weight': 2.5,
      'price': 200.0,
      'pickupAddress': 'G-11 Markaz, Islamabad',
      'status': 'AVAILABLE',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];
}

// Sample notifications (static simulation)
class NotificationData {
  static final List<Map<String, dynamic>> sampleNotifications = [
    {
      'id': 1,
      'type': 'listing_status',
      'title': 'Listing Collected',
      'message': 'Your plastic listing has been collected',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'read': false,
    },
    {
      'id': 2,
      'type': 'order_status',
      'title': 'Order Placed',
      'message': 'Your order for paper has been placed successfully',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      'read': false,
    },
    {
      'id': 3,
      'type': 'price_alert',
      'title': 'Price Update',
      'message': 'Metal prices have increased by 5%',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'read': true,
    },
  ];
}

// Recent activity (static simulation)
class ActivityData {
  static final List<Map<String, dynamic>> recentActivity = [
    {
      'id': 'activity-1',
      'type': 'LISTING',
      'action': 'Created listing',
      'details': 'plastic - 5.0kg',
      'status': 'PENDING',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 'activity-2',
      'type': 'ORDER',
      'action': 'Placed order',
      'details': 'paper - 3.0kg from Ali Khan',
      'status': 'PENDING',
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
    },
    {
      'id': 'activity-3',
      'type': 'LISTING',
      'action': 'Listing completed',
      'details': 'metal - 2.5kg',
      'status': 'COMPLETED',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];
}

// AI category suggestions (simulated)
class AIData {
  static const List<Map<String, dynamic>> categorySuggestions = [
    {
      'material': 'plastic',
      'confidence': 0.95,
      'suggestions': ['bottles', 'containers', 'packaging'],
    },
    {
      'material': 'paper',
      'confidence': 0.89,
      'suggestions': ['newspapers', 'cardboard', 'office paper'],
    },
    {
      'material': 'metal',
      'confidence': 0.92,
      'suggestions': ['cans', 'wires', 'appliances'],
    },
    {
      'material': 'e-waste',
      'confidence': 0.88,
      'suggestions': ['phones', 'laptops', 'batteries'],
    },
  ];
}

// Helper functions
class StaticDataHelper {
  static String getMaterialIcon(String materialType) {
    return MaterialData.materialIcons[materialType.toLowerCase()] ?? '♻️';
  }

  static double getMaterialRate(String materialType) {
    return MaterialData.materialRates[materialType.toLowerCase()] ?? 0.0;
  }

  static double calculatePrice(String materialType, double weight) {
    final rate = getMaterialRate(materialType);
    return rate * weight;
  }
}
