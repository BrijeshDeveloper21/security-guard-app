// Society / Building Admin management service

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:security_app/features/resident/models/tenant.dart';
import 'package:security_app/features/resident/models/flat.dart';
import 'package:security_app/features/resident/models/guard_resident.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/data/mock_database.dart';
import 'package:security_app/features/admin/services/audit_service.dart';

class SocietyDashboardStats {
  final int visitorsToday;
  final int currentlyInside;
  final int pendingApprovals;
  final int exitedToday;
  final int activeGuards;
  final int activeGates;

  const SocietyDashboardStats({
    required this.visitorsToday,
    required this.currentlyInside,
    required this.pendingApprovals,
    required this.exitedToday,
    required this.activeGuards,
    required this.activeGates,
  });
}

class SocietyService extends ChangeNotifier {
  final MockDatabase _db = MockDatabase();
  final AuditService _auditService = AuditService();
  final Uuid _uuid = const Uuid();

  Tenant? getTenant(String tenantId) {
    try {
      return _db.tenants.firstWhere((t) => t.id == tenantId);
    } catch (_) {
      return null;
    }
  }

  SocietyDashboardStats getDashboardStats(String tenantId) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final tenantVisits = _db.visits.where((v) => v.tenantId == tenantId).toList();
    final todayVisits = tenantVisits
        .where((v) => v.entryTimestamp.isAfter(todayStart))
        .toList();

    final insideCount = tenantVisits
        .where((v) => v.status == VisitStatus.inside && v.exitTimestamp == null)
        .length;

    final exitedCount = todayVisits
        .where((v) => v.status == VisitStatus.exited && v.exitTimestamp != null)
        .length;

    final pendingCount = _db.approvals
        .where((a) => a.tenantId == tenantId && a.status == ApprovalStatus.pending)
        .length;

    final activeGuardsCount = _db.guards
        .where((g) => g.tenantId == tenantId && g.isActive && g.isOnDuty)
        .length;

    final activeGatesCount = _db.gates
        .where((g) => g.tenantId == tenantId && g.isActive)
        .length;

    return SocietyDashboardStats(
      visitorsToday: todayVisits.length,
      currentlyInside: insideCount,
      pendingApprovals: pendingCount,
      exitedToday: exitedCount,
      activeGuards: activeGuardsCount,
      activeGates: activeGatesCount,
    );
  }

  List<Wing> getWings(String tenantId) =>
      _db.wings.where((w) => w.tenantId == tenantId).toList();

  List<Flat> getFlats(String tenantId) =>
      _db.flats.where((f) => f.tenantId == tenantId).toList();

  List<GuardProfile> getGuards(String tenantId) =>
      _db.guards.where((g) => g.tenantId == tenantId).toList();

  List<ResidentProfile> getResidents(String tenantId) =>
      _db.residents.where((r) => r.tenantId == tenantId).toList();

  Future<void> addWing({
    required String tenantId,
    required String name,
    required int totalFloors,
    required String adminId,
    required String adminName,
  }) async {
    final wing = Wing(
      id: 'wing_${tenantId.replaceAll('tenant_', '')}_${_uuid.v4().substring(0, 4)}',
      tenantId: tenantId,
      name: name,
      totalFloors: totalFloors,
      createdAt: DateTime.now(),
    );
    _db.wings.add(wing);
    _auditService.logAction(
      tenantId: tenantId,
      userId: adminId,
      userName: adminName,
      userRole: 'Society Admin',
      action: 'WING_ADDED',
      entityType: 'Wing',
      entityId: wing.id,
      details: 'Added wing $name ($totalFloors floors)',
    );
    notifyListeners();
  }

  Future<void> addFlat({
    required String tenantId,
    required String wingId,
    required String wingName,
    required String flatNumber,
    required int floor,
    String? residentName,
    String? residentPhone,
    required String adminId,
    required String adminName,
  }) async {
    final flat = Flat(
      id: 'flat_${tenantId.replaceAll('tenant_', '')}_${_uuid.v4().substring(0, 4)}',
      tenantId: tenantId,
      wingId: wingId,
      wingName: wingName,
      flatNumber: flatNumber,
      floor: floor,
      residentName: residentName,
      residentPhone: residentPhone,
    );
    _db.flats.add(flat);
    _auditService.logAction(
      tenantId: tenantId,
      userId: adminId,
      userName: adminName,
      userRole: 'Society Admin',
      action: 'FLAT_ADDED',
      entityType: 'Flat',
      entityId: flat.id,
      details: 'Added flat $flatNumber in $wingName',
    );
    notifyListeners();
  }

  Future<void> addGuard({
    required String tenantId,
    required String name,
    required String phone,
    required String assignedGateId,
    required String assignedGateName,
    GuardShift shift = GuardShift.morning,
    required String adminId,
    required String adminName,
  }) async {
    final guard = GuardProfile(
      id: 'guard_${_uuid.v4().substring(0, 6)}',
      tenantId: tenantId,
      userId: 'user_guard_${_uuid.v4().substring(0, 6)}',
      name: name,
      phone: phone,
      assignedGateId: assignedGateId,
      assignedGateName: assignedGateName,
      shift: shift,
      createdAt: DateTime.now(),
    );
    _db.guards.add(guard);
    _auditService.logAction(
      tenantId: tenantId,
      userId: adminId,
      userName: adminName,
      userRole: 'Society Admin',
      action: 'GUARD_ADDED',
      entityType: 'Guard',
      entityId: guard.id,
      details: 'Added guard $name assigned to $assignedGateName',
    );
    notifyListeners();
  }

  Future<void> addResident({
    required String tenantId,
    required String name,
    required String phone,
    required String email,
    required String flatId,
    required String flatNumber,
    required String wingName,
    required String adminId,
    required String adminName,
  }) async {
    final resident = ResidentProfile(
      id: 'res_${_uuid.v4().substring(0, 6)}',
      tenantId: tenantId,
      userId: 'user_res_${_uuid.v4().substring(0, 6)}',
      name: name,
      phone: phone,
      email: email,
      flatId: flatId,
      flatNumber: flatNumber,
      wingName: wingName,
      createdAt: DateTime.now(),
    );
    _db.residents.add(resident);
    _auditService.logAction(
      tenantId: tenantId,
      userId: adminId,
      userName: adminName,
      userRole: 'Society Admin',
      action: 'RESIDENT_ADDED',
      entityType: 'Resident',
      entityId: resident.id,
      details: 'Added resident $name assigned to Flat $flatNumber',
    );
    notifyListeners();
  }
}
