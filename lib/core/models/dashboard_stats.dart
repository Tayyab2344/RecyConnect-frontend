class DashboardStats {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final int activeOrders;
  final double inventoryValue;
  final int totalInventoryItems;
  final int lowStockItems;
  final List<RevenueDataPoint> revenueHistory;
  final List<MaterialDistribution> materialDistribution;
  final List<ExpenseBreakdown> expenseBreakdown;

  DashboardStats({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.activeOrders,
    required this.inventoryValue,
    required this.totalInventoryItems,
    required this.lowStockItems,
    required this.revenueHistory,
    required this.materialDistribution,
    required this.expenseBreakdown,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      netProfit: (json['netProfit'] ?? 0).toDouble(),
      profitMargin: (json['profitMargin'] ?? 0).toDouble(),
      activeOrders: json['activeOrders'] ?? 0,
      inventoryValue: (json['inventoryValue'] ?? 0).toDouble(),
      totalInventoryItems: json['totalInventoryItems'] ?? 0,
      lowStockItems: json['lowStockItems'] ?? 0,
      revenueHistory: (json['revenueHistory'] as List? ?? [])
          .map((item) => RevenueDataPoint.fromJson(item))
          .toList(),
      materialDistribution: (json['materialDistribution'] as List? ?? [])
          .map((item) => MaterialDistribution.fromJson(item))
          .toList(),
      expenseBreakdown: (json['expenseBreakdown'] as List? ?? [])
          .map((item) => ExpenseBreakdown.fromJson(item))
          .toList(),
    );
  }
}

class RevenueDataPoint {
  final DateTime date;
  final double amount;

  RevenueDataPoint({required this.date, required this.amount});

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class MaterialDistribution {
  final String materialType;
  final double value;
  final double percentage;

  MaterialDistribution({
    required this.materialType,
    required this.value,
    required this.percentage,
  });

  factory MaterialDistribution.fromJson(Map<String, dynamic> json) {
    return MaterialDistribution(
      materialType: json['materialType'],
      value: (json['value'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class ExpenseBreakdown {
  final String category;
  final double amount;
  final double percentage;

  ExpenseBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) {
    return ExpenseBreakdown(
      category: json['category'],
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}
