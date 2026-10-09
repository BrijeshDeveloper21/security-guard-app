// Resident workflow service: Approvals, pre-approved passes, flat visitor history

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:security_app/features/resident/models/approval.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/data/mock_database.dart';
import 'package:security_app/core/services/qr_service.dart';
import 'package:security_app/features/admin/services/audit_service.dart';

class ResidentService extends ChangeNotifier {
  final MockDatabase _db = MockDatabase();
  final AuditService _auditService = AuditService();
  final Uuid _uuid = const Uuid();

  /// Gets pending approval requests for a specific flat
  List<VisitorApproval> getPendingApprovalsForFlat({
    required String tenantId,
    required String flatId,
  }) {
    return _db.approvals
        .where((a) =>
            a.tenantId == tenantId &&
            a.flatId == flatId &&
            a.status == ApprovalStatus.pending)
        .toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  /// Gets visitor history isolated strictly to this flat
  List<Visit> getVisitorHistoryForFlat({
    required String tenantId,
    required String flatId,
  }) {
    return _db.visits
        .where((v) => v.tenantId == tenantId && v.flatId == flatId)
        .toList()
      ..sort((a, b) => b.entryTimestamp.compareTo(a.entryTimestamp));
  }

  /// Resident approves a visitor request
  Future<void> approveVisitor({
    required String tenantId,
    required String approvalId,
    required String residentId,
    required String residentName,
  }) async {
    final idx = _db.approvals.indexWhere(
      (a) => a.id == approvalId && a.tenantId == tenantId,
    );

    if (idx != -1) {
      final app = _db.approvals[idx];
      _db.approvals[idx] = app.copyWith(
        status: ApprovalStatus.approved,
        respondedAt: DateTime.now(),
      );

      // Also update corresponding visit status if exists
      final vIdx = _db.visits.indexWhere((v) => v.id == app.visitId);
      if (vIdx != -1) {
        _db.visits[vIdx] = _db.visits[vIdx].copyWith(
          approvalStatus: ApprovalStatus.approved,
        );
      }

      _auditService.logAction(
        tenantId: tenantId,
        userId: residentId,
        userName: residentName,
        userRole: 'Resident',
        action: 'APPROVAL_GRANTED',
        entityType: 'VisitorApproval',
        entityId: approvalId,
        details: 'Approved visitor ${app.visitorName} for Flat ${app.flatNumber}',
      );

      notifyListeners();
    }
  }

  /// Resident rejects a visitor request
  Future<void> rejectVisitor({
    required String tenantId,
    required String approvalId,
    required String residentId,
    required String residentName,
    String? reason,
  }) async {
    final idx = _db.approvals.indexWhere(
      (a) => a.id == approvalId && a.tenantId == tenantId,
    );

    if (idx != -1) {
      final app = _db.approvals[idx];
      _db.approvals[idx] = app.copyWith(
        status: ApprovalStatus.rejected,
        respondedAt: DateTime.now(),
        rejectionReason: reason ?? 'Resident unavailable / not expected',
      );

      final vIdx = _db.visits.indexWhere((v) => v.id == app.visitId);
      if (vIdx != -1) {
        _db.visits[vIdx] = _db.visits[vIdx].copyWith(
          approvalStatus: ApprovalStatus.rejected,
          status: VisitStatus.rejected,
          rejectionReason: reason ?? 'Resident rejected entry',
        );
      }

      _auditService.logAction(
        tenantId: tenantId,
        userId: residentId,
        userName: residentName,
        userRole: 'Resident',
        action: 'APPROVAL_REJECTED',
        entityType: 'VisitorApproval',
        entityId: approvalId,
        details: 'Rejected visitor ${app.visitorName} for Flat ${app.flatNumber}. Reason: $reason',
      );

      notifyListeners();
    }
  }

  /// Resident creates a Pre-Approved Visitor Pass (e.g. for tonight's dinner guest or delivery)
  Future<Visit> createPreApprovedPass({
    required String tenantId,
    required String residentId,
    required String residentName,
    required String flatId,
    required String flatNumber,
    required String wingName,
    required String visitorName,
    required String visitorPhone,
    required VisitorType visitorType,
    required VisitPurpose purpose,
    required DateTime expectedArrival,
  }) async {
    final year = DateTime.now().year;
    final passId = 'PASS-$year-${(100000 + _db.visits.length + 1)}';

    final secureToken = QrService.generateSecureVisitToken(
      tenantId: tenantId,
      visitId: passId,
      entryTime: expectedArrival,
    );

    final pass = Visit(
      id: passId,
      tenantId: tenantId,
      visitorId: 'vis_pre_${_uuid.v4().substring(0, 6)}',
      visitorName: visitorName,
      visitorPhone: visitorPhone,
      flatId: flatId,
      flatNumber: flatNumber,
      wingName: wingName,
      visitorType: visitorType,
      purpose: purpose,
      entryGateId: 'gate_preapproved',
      entryGateName: 'Any Configured Gate',
      entryGuardId: 'resident_self',
      entryGuardName: residentName,
      entryTimestamp: expectedArrival,
      status: VisitStatus.inside, // becomes active when presented
      approvalStatus: ApprovalStatus.approved, // auto-approved by resident
      secureVisitToken: secureToken,
      isPreApproved: true,
      expectedArrivalTime: expectedArrival,
    );

    _db.visits.add(pass);

    _auditService.logAction(
      tenantId: tenantId,
      userId: residentId,
      userName: residentName,
      userRole: 'Resident',
      action: 'PRE_APPROVED_PASS_CREATED',
      entityType: 'Visit',
      entityId: passId,
      details: 'Created pre-approved pass for $visitorName arriving at $expectedArrival',
    );

    notifyListeners();
    return pass;
  }
}
