// Dynamic gate management service supporting unlimited gates per society

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:security_app/features/guard/models/gate.dart';
import 'package:security_app/core/data/mock_database.dart';
import 'package:security_app/features/admin/services/audit_service.dart';

class GateService extends ChangeNotifier {
  final MockDatabase _db = MockDatabase();
  final AuditService _auditService = AuditService();
  final Uuid _uuid = const Uuid();

  /// Gets all gates configured for a specific tenant
  List<Gate> getGates(String tenantId, {bool activeOnly = false}) {
    return _db.gates.where((g) {
      if (g.tenantId != tenantId) return false;
      if (activeOnly && !g.isActive) return false;
      return true;
    }).toList();
  }

  /// Finds gate by ID
  Gate? getGateById(String tenantId, String gateId) {
    try {
      return _db.gates.firstWhere(
        (g) => g.tenantId == tenantId && g.id == gateId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Adds a new gate dynamically
  Future<Gate> addGate({
    required String tenantId,
    required String name,
    required String code,
    GateType type = GateType.mainEntrance,
    String? description,
    required String adminUserId,
    required String adminUserName,
  }) async {
    final gate = Gate(
      id: 'gate_${tenantId.replaceAll('tenant_', '')}_${_uuid.v4().substring(0, 6)}',
      tenantId: tenantId,
      name: name,
      code: code.toUpperCase(),
      type: type,
      description: description,
      isActive: true,
      createdAt: DateTime.now(),
    );

    _db.gates.add(gate);

    _auditService.logAction(
      tenantId: tenantId,
      userId: adminUserId,
      userName: adminUserName,
      userRole: 'Society Admin',
      action: 'GATE_CREATED',
      entityType: 'Gate',
      entityId: gate.id,
      details: 'Added new gate "$name" with code ${gate.code}',
    );

    notifyListeners();
    return gate;
  }

  /// Updates or renames a gate
  Future<Gate> updateGate({
    required String tenantId,
    required String gateId,
    required String name,
    required String code,
    required GateType type,
    String? description,
    required bool isActive,
    required String adminUserId,
    required String adminUserName,
  }) async {
    final index = _db.gates.indexWhere((g) => g.id == gateId && g.tenantId == tenantId);
    if (index == -1) {
      throw Exception('Gate not found');
    }

    final oldGate = _db.gates[index];
    final updated = oldGate.copyWith(
      name: name,
      code: code.toUpperCase(),
      type: type,
      description: description,
      isActive: isActive,
    );

    _db.gates[index] = updated;

    _auditService.logAction(
      tenantId: tenantId,
      userId: adminUserId,
      userName: adminUserName,
      userRole: 'Society Admin',
      action: 'GATE_UPDATED',
      entityType: 'Gate',
      entityId: gateId,
      details: 'Updated gate "${oldGate.name}" -> "$name" (Status: ${isActive ? "Active" : "Disabled"})',
    );

    notifyListeners();
    return updated;
  }

  /// Toggles active/disable status for a gate
  Future<void> toggleGateStatus({
    required String tenantId,
    required String gateId,
    required bool isActive,
    required String adminUserId,
    required String adminUserName,
  }) async {
    final index = _db.gates.indexWhere((g) => g.id == gateId && g.tenantId == tenantId);
    if (index != -1) {
      final gate = _db.gates[index];
      _db.gates[index] = gate.copyWith(isActive: isActive);

      _auditService.logAction(
        tenantId: tenantId,
        userId: adminUserId,
        userName: adminUserName,
        userRole: 'Society Admin',
        action: isActive ? 'GATE_ENABLED' : 'GATE_DISABLED',
        entityType: 'Gate',
        entityId: gateId,
        details: '${isActive ? "Enabled" : "Disabled"} gate "${gate.name}"',
      );

      notifyListeners();
    }
  }
}
