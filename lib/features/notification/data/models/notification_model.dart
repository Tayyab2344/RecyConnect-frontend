class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String priority;
  final bool isRead;
  final String? actionUrl;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    this.actionUrl,
    required this.createdAt,
  });

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    String? priority,
    bool? isRead,
    String? actionUrl,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'SYSTEM',
      priority: json['priority'] as String? ?? 'MEDIUM',
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'isRead': isRead,
      'actionUrl': actionUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
