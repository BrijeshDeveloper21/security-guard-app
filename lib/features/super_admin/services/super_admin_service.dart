// Super Admin Service for SaaS platform management across all societies

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:security_app/features/resident/models/tenant.dart';
import 'package:security_app/features/super_admin/models/subscription.dart';
import 'package:security_app/core/data/mock_database.dart';
import 'package:security_app/features/guard/services/gate_service.dart';
import 'package:security_app/features/admin/services/audit_service.dart';

class PlatformAnalytics {
  final int totalSocieties;
  final int activeSubscriptions;
  final int trialSubscriptions;
  final int expiredSubscriptions;
  final int totalUsers;
  final int totalVisits;

  const PlatformAnalytics({
    required this.totalSocieties,
    required this.activeSubscriptions,
    required this.trialSubscriptions,
    required this.expiredSubscriptions,
    required this.totalUsers,
    required this.totalVisits,
  });
}

class SuperAdminService extends ChangeNotifier {
  final MockDatabase _db = MockDatabase();
  final GateService _gateService = GateService();
  final AuditService _auditService = AuditService();
  final Uuid _uuid = const Uuid();

  List<Tenant> getAllSocieties() => _db.tenants;

  PlatformAnalytics getPlatformAnalytics() {
    final active = _db.tenants
        .where((t) => t.subscriptionStatus == SubscriptionStatus.active)
        .length;
    final trial = _db.tenants
        .where((t) => t.subscriptionStatus == SubscriptionStatus.trial)
        .length;
    final expired = _db.tenants
        .where((t) =>
            t.subscriptionStatus == SubscriptionStatus.expired ||
            t.subscriptionStatus == SubscriptionStatus.suspended)
        .length;

    return PlatformAnalytics(
      totalSocieties: _db.tenants.length,
      activeSubscriptions: active,
      trialSubscriptions: trial,
      expiredSubscriptions: expired,
      totalUsers: _db.users.length + _db.guards.length + _db.residents.length,
      totalVisits: _db.visits.length,
    );
  }

  /// Super Admin creates a new society onboarding onto the SaaS platform
  Future<Tenant> createSociety({
    required String name,
    required String buildingName,
    required String address,
    required String city,
    required String contactPhone,
    required String contactEmail,
    required String subscriptionPlanId,
    required int initialGateCount,
    required String superAdminId,
    required String superAdminName,
  }) async {
    final tenantId = 'tenant_${name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}_${_uuid.v4().substring(0, 4)}';
    final now = DateTime.now();

    final newTenant = Tenant(
      id: tenantId,
      name: name,
      buildingName: buildingName,
      address: address,
      city: city,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      subscriptionStatus: SubscriptionStatus.active,
      subscriptionPlanId: subscriptionPlanId,
      subscriptionExpiresAt: now.add(const Duration(days: 365)),
      isActive: true,
      createdAt: now,
    );

    _db.tenants.add(newTenant);

    // Automatically configure initial dynamic gates requested during onboarding
    for (int i = 1; i <= initialGateCount; i++) {
      final charCode = String.fromCharCode(64 + i); // Gate A, Gate B, Gate C...
      await _gateService.addGate(
        tenantId: tenantId,
        name: 'Gate $charCode - Entrance $i',
        code: 'GATE-$charCode',
        adminUserId: superAdminId,
        adminUserName: superAdminName,
      );
    }

    // Create corresponding subscription record
    _db.subscriptions.add(
      SocietySubscription(
        id: 'sub_${_uuid.v4().substring(0, 8)}',
        tenantId: tenantId,
        planId: subscriptionPlanId,
        status: SubscriptionStatus.active,
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
        lastPaymentAmount: 39999.0,
        lastPaymentDate: now,
        nextBillingDate: now.add(const Duration(days: 365)),
      ),
    );

    _auditService.logAction(
      tenantId: tenantId,
      userId: superAdminId,
      userName: superAdminName,
      userRole: 'Super Admin',
      action: 'SOCIETY_ONBOARDED',
      entityType: 'Tenant',
      entityId: tenantId,
      details: 'Onboarded new society "$name" with $initialGateCount gates',
    );

    notifyListeners();
    return newTenant;
  }

  /// Toggles society active or suspended status
  Future<void> setSocietyActiveStatus({
    required String tenantId,
    required bool isActive,
    required String superAdminId,
    required String superAdminName,
  }) async {
    final idx = _db.tenants.indexWhere((t) => t.id == tenantId);
    if (idx != -1) {
      _db.tenants[idx] = _db.tenants[idx].copyWith(
        isActive: isActive,
        subscriptionStatus: isActive
            ? SubscriptionStatus.active
            : SubscriptionStatus.suspended,
      );

      _auditService.logAction(
        tenantId: tenantId,
        userId: superAdminId,
        userName: superAdminName,
        userRole: 'Super Admin',
        action: isActive ? 'SOCIETY_ACTIVATED' : 'SOCIETY_SUSPENDED',
        entityType: 'Tenant',
        entityId: tenantId,
        details: '${isActive ? "Activated" : "Suspended"} society "${_db.tenants[idx].name}"',
      );

      notifyListeners();
    }
  }
}
