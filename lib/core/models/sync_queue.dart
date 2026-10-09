// Offline synchronization queue for weak gate network resilience

enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

enum SyncAction {
  createVisitor,
  recordEntry,
  recordExit,
  respondApproval,
  logAudit,
}

class SyncQueueItem {
  final String id;
  final String tenantId;
  final SyncAction action;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final SyncStatus status;
  final int retryCount;
  final String? errorMessage;

  const SyncQueueItem({
    required this.id,
    required this.tenantId,
    required this.action,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'action': action.name,
        'entityId': entityId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'retryCount': retryCount,
        'errorMessage': errorMessage,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'],
        tenantId: json['tenantId'],
        action: SyncAction.values.firstWhere(
          (e) => e.name == json['action'],
          orElse: () => SyncAction.recordEntry,
        ),
        entityId: json['entityId'],
        payload: Map<String, dynamic>.from(json['payload'] ?? {}),
        createdAt: DateTime.parse(json['createdAt']),
        status: SyncStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SyncStatus.pending,
        ),
        retryCount: json['retryCount'] ?? 0,
        errorMessage: json['errorMessage'],
      );

  SyncQueueItem copyWith({
    String? id,
    String? tenantId,
    SyncAction? action,
    String? entityId,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    SyncStatus? status,
    int? retryCount,
    String? errorMessage,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      action: action ?? this.action,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
