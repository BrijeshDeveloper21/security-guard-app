// Audit Log and Notification entities for compliance and alerting

class AuditLog {
  final String id;
  final String tenantId;
  final String userId;
  final String userName;
  final String userRole;
  final String action; // e.g. VISITOR_CREATED, ENTRY_RECORDED, EXIT_RECORDED, QR_SCANNED, APPROVAL_GRANTED, GUARD_LOGIN, SUBSCRIPTION_UPDATED
  final String entityType; // Visit, Visitor, Gate, Flat, Guard, Resident, Subscription
  final String entityId;
  final String details;
  final String? ipAddress;
  final DateTime timestamp;

  const AuditLog({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.details,
    this.ipAddress,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'userId': userId,
        'userName': userName,
        'userRole': userRole,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'details': details,
        'ipAddress': ipAddress,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
        id: json['id'],
        tenantId: json['tenantId'],
        userId: json['userId'],
        userName: json['userName'] ?? 'System',
        userRole: json['userRole'] ?? 'Guard',
        action: json['action'],
        entityType: json['entityType'],
        entityId: json['entityId'],
        details: json['details'] ?? '',
        ipAddress: json['ipAddress'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

enum NotificationType {
  visitorArrival,
  approvalRequest,
  approvalResponse,
  emergencyAlert,
  systemNotice,
}

class NotificationItem {
  final String id;
  final String tenantId;
  final String recipientId; // user id
  final String title;
  final String body;
  final NotificationType type;
  final String? relatedVisitId;
  final bool isRead;
  final DateTime timestamp;

  const NotificationItem({
    required this.id,
    required this.tenantId,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedVisitId,
    this.isRead = false,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'recipientId': recipientId,
        'title': title,
        'body': body,
        'type': type.name,
        'relatedVisitId': relatedVisitId,
        'isRead': isRead,
        'timestamp': timestamp.toIso8601String(),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'],
        tenantId: json['tenantId'],
        recipientId: json['recipientId'],
        title: json['title'],
        body: json['body'],
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.systemNotice,
        ),
        relatedVisitId: json['relatedVisitId'],
        isRead: json['isRead'] ?? false,
        timestamp: DateTime.parse(json['timestamp']),
      );

  NotificationItem copyWith({
    String? id,
    String? tenantId,
    String? recipientId,
    String? title,
    String? body,
    NotificationType? type,
    String? relatedVisitId,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      relatedVisitId: relatedVisitId ?? this.relatedVisitId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
