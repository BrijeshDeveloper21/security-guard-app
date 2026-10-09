// Visitor and Visit management service with multi-tenant isolation, automatic timestamps, and cross-gate exits

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/models/sync_queue.dart';
import 'package:security_app/core/data/mock_database.dart';
import 'package:security_app/core/services/qr_service.dart';
import 'package:security_app/features/admin/services/audit_service.dart';
import 'package:security_app/core/services/sync_service.dart';

class VisitorService extends ChangeNotifier {
  final MockDatabase _db = MockDatabase();
  final AuditService _auditService = AuditService();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = const Uuid();

  /// Finds an existing visitor by phone within the tenant for repeat visitor auto-completion
  Visitor? findRepeatVisitor({
    required String tenantId,
    required String phone,
  }) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    try {
      return _db.visitors.firstWhere(
        (v) =>
            v.tenantId == tenantId &&
            v.phone.replaceAll(RegExp(r'\D'), '') == cleanPhone,
      );
    } catch (_) {
      return null;
    }
  }

  /// Lists all visits currently inside the building for the tenant (exitTimestamp == null)
  List<Visit> getCurrentlyInside(String tenantId) {
    return _db.visits
        .where((v) =>
            v.tenantId == tenantId &&
            v.status == VisitStatus.inside &&
            v.exitTimestamp == null)
        .toList()
      ..sort((a, b) => b.entryTimestamp.compareTo(a.entryTimestamp));
  }

  /// Emergency evacuation view: Immediate list of all temporary individuals inside
  List<Visit> getEmergencyInsideList(String tenantId, {String? query}) {
    var inside = getCurrentlyInside(tenantId);
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      inside = inside
          .where((v) =>
              v.visitorName.toLowerCase().contains(q) ||
              v.visitorPhone.contains(q) ||
              v.flatNumber.toLowerCase().contains(q) ||
              v.entryGateName.toLowerCase().contains(q) ||
              v.visitorType.name.toLowerCase().contains(q))
          .toList();
    }
    return inside;
  }

  /// Complete Visitor History with filtering options
  List<Visit> getVisitorHistory({
    required String tenantId,
    String? searchQuery,
    VisitorType? visitorType,
    String? flatNumber,
    String? gateId,
    VisitStatus? status,
    DateTime? fromDate,
  }) {
    return _db.visits.where((v) {
      if (v.tenantId != tenantId) return false;
      if (visitorType != null && v.visitorType != visitorType) return false;
      if (flatNumber != null &&
          flatNumber.isNotEmpty &&
          !v.flatNumber.toLowerCase().contains(flatNumber.toLowerCase())) {
        return false;
      }
      if (gateId != null &&
          gateId.isNotEmpty &&
          v.entryGateId != gateId &&
          v.exitGateId != gateId) {
        return false;
      }
      if (status != null && v.status != status) return false;
      if (fromDate != null && v.entryTimestamp.isBefore(fromDate)) return false;

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matches = v.visitorName.toLowerCase().contains(q) ||
            v.visitorPhone.contains(q) ||
            v.id.toLowerCase().contains(q) ||
            v.flatNumber.toLowerCase().contains(q) ||
            (v.vehicleNumber?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => b.entryTimestamp.compareTo(a.entryTimestamp));
  }

  /// Finds an active visit by visit ID or scanned QR token for cross-gate exit
  Visit? findActiveVisitByIdOrToken({
    required String tenantId,
    required String query,
  }) {
    final cleanQuery = query.trim();
    final parsed = QrService.parseAndValidateToken(cleanQuery);
    final targetVisitId = parsed['visitId'] ?? cleanQuery;

    try {
      return _db.visits.firstWhere(
        (v) =>
            v.tenantId == tenantId &&
            (v.id == targetVisitId ||
                v.secureVisitToken == cleanQuery ||
                v.visitorPhone.replaceAll(RegExp(r'\D'), '') ==
                    cleanQuery.replaceAll(RegExp(r'\D'), '') ||
                v.id.toLowerCase() == cleanQuery.toLowerCase()),
      );
    } catch (_) {
      return null;
    }
  }

  /// Records a new visitor and requests Resident Approval instead of auto-admitting
  Future<Visit> requestResidentApproval({
    required String tenantId,
    required String visitorName,
    required String visitorPhone,
    String? visitorPhotoUrl,
    required String flatId,
    required String flatNumber,
    required String wingName,
    required VisitorType visitorType,
    required VisitPurpose purpose,
    String? customPurpose,
    String? vehicleNumber,
    required String entryGateId,
    required String entryGateName,
    required String entryGuardId,
    required String entryGuardName,
  }) async {
    // 1. Generate unique sequential-like visit ID
    final year = DateTime.now().year;
    final randomSuffix = (100000 + _db.visits.length + 1).toString();
    final visitId = 'VIS-$year-$randomSuffix';

    final automaticEntryTime = DateTime.now();

    final secureToken = QrService.generateSecureVisitToken(
      tenantId: tenantId,
      visitId: visitId,
      entryTime: automaticEntryTime,
    );

    // Create / Update Visitor profile logic
    var existingVisitor = findRepeatVisitor(tenantId: tenantId, phone: visitorPhone);
    String visitorId;
    if (existingVisitor != null) {
      visitorId = existingVisitor.id;
      final updated = existingVisitor.copyWith(
        name: visitorName,
        photoUrl: visitorPhotoUrl ?? existingVisitor.photoUrl,
        vehicleNumber: vehicleNumber ?? existingVisitor.vehicleNumber,
        totalVisits: existingVisitor.totalVisits + 1,
        lastVisitedFlat: flatNumber,
        lastVisitAt: automaticEntryTime,
      );
      final idx = _db.visitors.indexWhere((v) => v.id == existingVisitor.id);
      if (idx != -1) _db.visitors[idx] = updated;
    } else {
      visitorId = 'vis_${_uuid.v4().substring(0, 8)}';
      final newVisitor = Visitor(
        id: visitorId,
        tenantId: tenantId,
        name: visitorName,
        phone: visitorPhone,
        photoUrl: visitorPhotoUrl,
        vehicleNumber: vehicleNumber,
        visitorType: visitorType,
        totalVisits: 1,
        lastVisitedFlat: flatNumber,
        createdAt: automaticEntryTime,
        lastVisitAt: automaticEntryTime,
      );
      _db.visitors.add(newVisitor);
    }

    // Create the Visit record in a PENDING state
    final newVisit = Visit(
      id: visitId,
      tenantId: tenantId,
      visitorId: visitorId,
      visitorName: visitorName,
      visitorPhone: visitorPhone,
      visitorPhotoUrl: visitorPhotoUrl,
      flatId: flatId,
      flatNumber: flatNumber,
      wingName: wingName,
      visitorType: visitorType,
      purpose: purpose,
      customPurpose: customPurpose,
      vehicleNumber: vehicleNumber,
      entryGateId: entryGateId,
      entryGateName: entryGateName,
      entryGuardId: entryGuardId,
      entryGuardName: entryGuardName,
      entryTimestamp: automaticEntryTime,
      status: VisitStatus.inside, // Pending state effectively managed by approvalStatus
      approvalStatus: ApprovalStatus.pending,
      secureVisitToken: secureToken,
    );

    _db.visits.insert(0, newVisit);
    
    notifyListeners();
    return newVisit;
  }

  /// Override admit (Emergency fallback)
  Future<Visit> forceAdmit({
    required String tenantId,
    required String visitId,
    required String guardId,
    required String guardName,
  }) async {
    final index = _db.visits.indexWhere((v) => v.id == visitId && v.tenantId == tenantId);
    if (index == -1) throw Exception("Visit not found.");

    final v = _db.visits[index];
    final updated = v.copyWith(
      approvalStatus: ApprovalStatus.approved,
      status: VisitStatus.inside,
    );
    _db.visits[index] = updated;

    _auditService.logAction(
      tenantId: tenantId,
      userId: guardId,
      userName: guardName,
      userRole: 'Security Guard',
      action: 'FORCE_ADMIT_OVERRIDE',
      entityType: 'Visit',
      entityId: visitId,
      details: 'Guard $guardName overrode approval fallback to admit ${v.visitorName}',
    );

    notifyListeners();
    return updated;
  }

  /// Deletes a visit
  void deleteVisit(String visitId) {
    _db.visits.removeWhere((v) => v.id == visitId);
    notifyListeners();
  }

  /// Records a new visitor and automatic entry timestamp
  Future<Visit> recordNewEntry({
    required String tenantId,
    required String visitorName,
    required String visitorPhone,
    String? visitorPhotoUrl,
    required String flatId,
    required String flatNumber,
    required String wingName,
    required VisitorType visitorType,
    required VisitPurpose purpose,
    String? customPurpose,
    String? vehicleNumber,
    required String entryGateId,
    required String entryGateName,
    required String entryGuardId,
    required String entryGuardName,
    ApprovalStatus approvalStatus = ApprovalStatus.notRequired,
    bool isPreApproved = false,
  }) async {
    // 1. Generate unique sequential-like visit ID
    final year = DateTime.now().year;
    final randomSuffix = (100000 + _db.visits.length + 1).toString();
    final visitId = 'VIS-$year-$randomSuffix';

    // 2. Automatic Entry Timestamp
    final automaticEntryTime = DateTime.now();

    // 3. Cryptographically unique QR token
    final secureToken = QrService.generateSecureVisitToken(
      tenantId: tenantId,
      visitId: visitId,
      entryTime: automaticEntryTime,
    );

    // 4. Update or create Visitor record
    var existingVisitor = findRepeatVisitor(tenantId: tenantId, phone: visitorPhone);
    String visitorId;

    if (existingVisitor != null) {
      visitorId = existingVisitor.id;
      final updated = existingVisitor.copyWith(
        name: visitorName,
        photoUrl: visitorPhotoUrl ?? existingVisitor.photoUrl,
        vehicleNumber: vehicleNumber ?? existingVisitor.vehicleNumber,
        totalVisits: existingVisitor.totalVisits + 1,
        lastVisitedFlat: flatNumber,
        lastVisitAt: automaticEntryTime,
      );
      final idx = _db.visitors.indexWhere((v) => v.id == existingVisitor.id);
      if (idx != -1) _db.visitors[idx] = updated;
    } else {
      visitorId = 'vis_${_uuid.v4().substring(0, 8)}';
      final newVisitor = Visitor(
        id: visitorId,
        tenantId: tenantId,
        name: visitorName,
        phone: visitorPhone,
        photoUrl: visitorPhotoUrl,
        vehicleNumber: vehicleNumber,
        visitorType: visitorType,
        totalVisits: 1,
        lastVisitedFlat: flatNumber,
        createdAt: automaticEntryTime,
        lastVisitAt: automaticEntryTime,
      );
      _db.visitors.add(newVisitor);
    }

    // 5. Create Visit record
    final newVisit = Visit(
      id: visitId,
      tenantId: tenantId,
      visitorId: visitorId,
      visitorName: visitorName,
      visitorPhone: visitorPhone,
      visitorPhotoUrl: visitorPhotoUrl,
      flatId: flatId,
      flatNumber: flatNumber,
      wingName: wingName,
      visitorType: visitorType,
      purpose: purpose,
      customPurpose: customPurpose,
      vehicleNumber: vehicleNumber,
      entryGateId: entryGateId,
      entryGateName: entryGateName,
      entryGuardId: entryGuardId,
      entryGuardName: entryGuardName,
      entryTimestamp: automaticEntryTime,
      status: VisitStatus.inside,
      approvalStatus: approvalStatus,
      secureVisitToken: secureToken,
      isPreApproved: isPreApproved,
    );

    _db.visits.insert(0, newVisit);

    // 6. Audit Log
    _auditService.logAction(
      tenantId: tenantId,
      userId: entryGuardId,
      userName: entryGuardName,
      userRole: 'Security Guard',
      action: 'ENTRY_RECORDED',
      entityType: 'Visit',
      entityId: visitId,
      details:
          'Entry recorded for $visitorName ($visitorPhone) at $entryGateName to Flat $flatNumber',
    );

    // 7. Offline sync queue durability
    _syncService.enqueueAction(
      tenantId: tenantId,
      action: SyncAction.recordEntry,
      entityId: visitId,
      payload: newVisit.toJson(),
    );

    notifyListeners();
    return newVisit;
  }

  /// Marks exit for a visitor at ANY configured gate (Cross-gate exit)
  Future<Visit> recordCrossGateExit({
    required String tenantId,
    required String visitId,
    required String exitGateId,
    required String exitGateName,
    required String exitGuardId,
    required String exitGuardName,
  }) async {
    final index = _db.visits.indexWhere(
      (v) => v.id == visitId && v.tenantId == tenantId,
    );

    if (index == -1) {
      throw Exception('Active visit with ID $visitId not found in this society.');
    }

    final currentVisit = _db.visits[index];
    if (currentVisit.exitTimestamp != null) {
      throw Exception('Visitor has already been marked as EXITED.');
    }

    final automaticExitTime = DateTime.now();

    final updatedVisit = currentVisit.copyWith(
      exitGateId: exitGateId,
      exitGateName: exitGateName,
      exitGuardId: exitGuardId,
      exitGuardName: exitGuardName,
      exitTimestamp: automaticExitTime,
      status: VisitStatus.exited,
    );

    _db.visits[index] = updatedVisit;

    // Audit Log
    _auditService.logAction(
      tenantId: tenantId,
      userId: exitGuardId,
      userName: exitGuardName,
      userRole: 'Security Guard',
      action: 'EXIT_RECORDED',
      entityType: 'Visit',
      entityId: visitId,
      details:
          'Cross-gate exit recorded at $exitGateName by $exitGuardName (Entry was at ${currentVisit.entryGateName})',
    );

    // Sync queue
    _syncService.enqueueAction(
      tenantId: tenantId,
      action: SyncAction.recordExit,
      entityId: visitId,
      payload: {
        'exitGateId': exitGateId,
        'exitGateName': exitGateName,
        'exitGuardId': exitGuardId,
        'exitGuardName': exitGuardName,
        'exitTimestamp': automaticExitTime.toIso8601String(),
      },
    );

    notifyListeners();
    return updatedVisit;
  }
}
