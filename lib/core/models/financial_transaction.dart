class FinancialTransaction {
  final int id;
  final int warehouseId;
  final String type; // REVENUE, EXPENSE, REFUND
  final double amount;
  final int? orderId;
  final String? description;
  final double? stripeFee;
  final double netAmount;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  FinancialTransaction({
    required this.id,
    required this.warehouseId,
    required this.type,
    required this.amount,
    this.orderId,
    this.description,
    this.stripeFee,
    required this.netAmount,
    this.metadata,
    required this.createdAt,
  });

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'],
      warehouseId: json['warehouseId'],
      type: json['type'],
      amount: json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : json['amount'],
      orderId: json['orderId'],
      description: json['description'],
      stripeFee: json['stripeFee'] != null
          ? (json['stripeFee'] is int
              ? (json['stripeFee'] as int).toDouble()
              : json['stripeFee'])
          : null,
      netAmount: json['netAmount'] is int
          ? (json['netAmount'] as int).toDouble()
          : json['netAmount'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Transaction types
class TransactionType {
  static const String revenue = 'REVENUE';
  static const String expense = 'EXPENSE';
  static const String refund = 'REFUND';
}
