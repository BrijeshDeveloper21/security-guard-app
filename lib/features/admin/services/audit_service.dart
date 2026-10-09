// Audit log service to track all security, entry/exit, and admin operations

import 'package:uuid/uuid.dart';
import 'package:security_app/features/admin/models/audit_notification.dart';
import 'package:security_app/core/data/mock_database.dart';

class AuditService {
  final MockDatabase _db = MockDatabase();
  final Uuid _uuid = const Uuid();

  List<AuditLog> getLogsForTenant(String tenantId) {
    return _db.auditLogs
        .where((log) => log.tenantId == tenantId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void logAction({
    required String tenantId,
    required String userId,
    required String userName,
    required String userRole,
    required String action,
    required String entityType,
    required String entityId,
    required String details,
    String? ipAddress,
  }) {
    final log = AuditLog(
      id: 'audit_${_uuid.v4().substring(0, 8)}',
      tenantId: tenantId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
      ipAddress: ipAddress ?? '127.0.0.1 (Local Gate)',
      timestamp: DateTime.now(),
    );

    _db.auditLogs.insert(0, log);
  }
}
