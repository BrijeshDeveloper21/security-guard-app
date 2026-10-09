// Subscription and feature-gating service for SaaS operations

import 'package:flutter/foundation.dart';
import 'package:security_app/features/resident/models/tenant.dart';
import 'package:security_app/features/super_admin/models/subscription.dart';
import 'package:security_app/core/data/mock_database.dart';
import 'package:security_app/features/admin/services/audit_service.dart';

class SubscriptionService extends ChangeNotifier {
  final MockDatabase _db = MockDatabase();
  final AuditService _auditService = AuditService();

  List<SubscriptionPlan> getPlans() => _db.subscriptionPlans;

  SubscriptionPlan? getPlanById(String planId) {
    try {
      return _db.subscriptionPlans.firstWhere((p) => p.id == planId);
    } catch (_) {
      return null;
    }
  }

  SocietySubscription? getSubscriptionForTenant(String tenantId) {
    try {
      return _db.subscriptions.firstWhere((s) => s.tenantId == tenantId);
    } catch (_) {
      return null;
    }
  }

  /// Checks if a feature is unlocked according to the tenant's current plan and status
  bool isFeatureAllowed({
    required String tenantId,
    required String featureKey,
  }) {
    final tenant = _db.tenants.firstWhere(
      (t) => t.id == tenantId,
      orElse: () => throw Exception('Tenant not found'),
    );

    if (!tenant.isSubscriptionActive) {
      return false; // Subscription expired or suspended
    }

    final plan = getPlanById(tenant.subscriptionPlanId);
    if (plan == null) return false;

    switch (featureKey) {
      case 'qr_system':
        return plan.limits.hasQrSystem;
      case 'resident_approval':
        return plan.limits.hasResidentApproval;
      case 'emergency_view':
        return plan.limits.hasEmergencyView;
      case 'audit_logs':
        return plan.limits.hasAuditLogs;
      case 'offline_sync':
        return plan.limits.hasOfflineSync;
      case 'advanced_reports':
        return plan.limits.hasAdvancedReports;
      default:
        return true;
    }
  }

  /// Upgrades or changes subscription plan from Super Admin or Society Admin
  Future<void> updateSubscription({
    required String tenantId,
    required String newPlanId,
    required String billingCycle,
    required String updatedByUserId,
    required String updatedByUserName,
  }) async {
    final plan = getPlanById(newPlanId);
    if (plan == null) throw Exception('Plan does not exist');

    final subIdx = _db.subscriptions.indexWhere((s) => s.tenantId == tenantId);
    final tenantIdx = _db.tenants.indexWhere((t) => t.id == tenantId);

    final durationDays = billingCycle == 'yearly' ? 365 : 30;
    final expiresAt = DateTime.now().add(Duration(days: durationDays));
    final amount = billingCycle == 'yearly' ? plan.priceYearly : plan.priceMonthly;

    if (subIdx != -1) {
      final oldSub = _db.subscriptions[subIdx];
      _db.subscriptions[subIdx] = SocietySubscription(
        id: oldSub.id,
        tenantId: tenantId,
        planId: newPlanId,
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        endDate: expiresAt,
        billingCycle: billingCycle,
        lastPaymentAmount: amount,
        lastPaymentDate: DateTime.now(),
        nextBillingDate: expiresAt,
      );
    }

    if (tenantIdx != -1) {
      _db.tenants[tenantIdx] = _db.tenants[tenantIdx].copyWith(
        subscriptionPlanId: newPlanId,
        subscriptionStatus: SubscriptionStatus.active,
        subscriptionExpiresAt: expiresAt,
      );
    }

    _auditService.logAction(
      tenantId: tenantId,
      userId: updatedByUserId,
      userName: updatedByUserName,
      userRole: 'Admin',
      action: 'SUBSCRIPTION_UPDATED',
      entityType: 'Subscription',
      entityId: newPlanId,
      details: 'Updated subscription to ${plan.name} ($billingCycle)',
    );

    notifyListeners();
  }

  /// Simulates toggling subscription status for testing expired handling
  void setSubscriptionStatus({
    required String tenantId,
    required SubscriptionStatus status,
  }) {
    final tIdx = _db.tenants.indexWhere((t) => t.id == tenantId);
    if (tIdx != -1) {
      _db.tenants[tIdx] = _db.tenants[tIdx].copyWith(
        subscriptionStatus: status,
        subscriptionExpiresAt: status == SubscriptionStatus.expired
            ? DateTime.now().subtract(const Duration(days: 1))
            : DateTime.now().add(const Duration(days: 30)),
      );
      notifyListeners();
    }
  }
}
