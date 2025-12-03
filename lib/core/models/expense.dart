class Expense {
  final int id;
  final int warehouseId;
  final String category;
  final double amount;
  final String? description;
  final DateTime date;
  final String? receipt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.warehouseId,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
    this.receipt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      warehouseId: json['warehouseId'],
      category: json['category'],
      amount: json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : json['amount'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      receipt: json['receipt'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouseId': warehouseId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'receipt': receipt,
    };
  }
}

// Expense categories enum
class ExpenseCategory {
  static const String operational = 'OPERATIONAL';
  static const String employee = 'EMPLOYEE';
  static const String transportation = 'TRANSPORTATION';
  static const String rent = 'RENT';
  static const String utilities = 'UTILITIES';
  static const String packaging = 'PACKAGING';
  static const String collector = 'COLLECTOR';

  static const List<String> all = [
    operational,
    employee,
    transportation,
    rent,
    utilities,
    packaging,
    collector,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case operational:
        return 'Operational';
      case employee:
        return 'Employee';
      case transportation:
        return 'Transportation';
      case rent:
        return 'Rent';
      case utilities:
        return 'Utilities';
      case packaging:
        return 'Packaging';
      case collector:
        return 'Collector';
      default:
        return category;
    }
  }
}
