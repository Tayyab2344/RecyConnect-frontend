class WarehouseInventory {
  final int id;
  final int warehouseId;
  final String materialType;
  final String category;
  final double quantityInStock;
  final double? reorderLevel;
  final double purchasePrice;
  final double sellingPrice;
  final int? supplierId;
  final String? supplierName;
  final String? location;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WarehouseInventory({
    required this.id,
    required this.warehouseId,
    required this.materialType,
    required this.category,
    required this.quantityInStock,
    this.reorderLevel,
    required this.purchasePrice,
    required this.sellingPrice,
    this.supplierId,
    this.supplierName,
    this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculated fields
  double get profitPerKg => sellingPrice - purchasePrice;
  double get marginPercent => (profitPerKg / sellingPrice) * 100;
  double get totalValue => quantityInStock * sellingPrice;
  bool get isLowStock => reorderLevel != null && quantityInStock <= reorderLevel!;

  factory WarehouseInventory.fromJson(Map<String, dynamic> json) {
    return WarehouseInventory(
      id: json['id'],
      warehouseId: json['warehouseId'],
      materialType: json['materialType'],
      category: json['category'],
      quantityInStock: json['quantityInStock'] is int
          ? (json['quantityInStock'] as int).toDouble()
          : json['quantityInStock'],
      reorderLevel: json['reorderLevel'] != null
          ? (json['reorderLevel'] is int
              ? (json['reorderLevel'] as int).toDouble()
              : json['reorderLevel'])
          : null,
      purchasePrice: json['purchasePrice'] is int
          ? (json['purchasePrice'] as int).toDouble()
          : json['purchasePrice'],
      sellingPrice: json['sellingPrice'] is int
          ? (json['sellingPrice'] as int).toDouble()
          : json['sellingPrice'],
      supplierId: json['supplierId'],
      supplierName: json['supplier']?['name'],
      location: json['location'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouseId': warehouseId,
      'materialType': materialType,
      'category': category,
      'quantityInStock': quantityInStock,
      'reorderLevel': reorderLevel,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'supplierId': supplierId,
      'location': location,
      'notes': notes,
    };
  }
}
