// Subscription models for SaaS Operations

import 'package:security_app/features/resident/models/tenant.dart';

enum SubscriptionTier { basic, standard, premium, enterprise }

class PlanLimits {
  final int maxGates;
  final int maxGuards;
  final int maxFlats;
  final int storageLimitGb;
  final bool hasQrSystem;
  final bool hasResidentApproval;
  final bool hasEmergencyView;
  final bool hasAuditLogs;
  final bool hasOfflineSync;
  final bool hasAdvancedReports;

  const PlanLimits({
    required this.maxGates,
    required this.maxGuards,
    required this.maxFlats,
    required this.storageLimitGb,
    this.hasQrSystem = true,
    this.hasResidentApproval = true,
    this.hasEmergencyView = true,
    this.hasAuditLogs = true,
    this.hasOfflineSync = true,
    this.hasAdvancedReports = true,
  });

  Map<String, dynamic> toJson() => {
        'maxGates': maxGates,
        'maxGuards': maxGuards,
        'maxFlats': maxFlats,
        'storageLimitGb': storageLimitGb,
        'hasQrSystem': hasQrSystem,
        'hasResidentApproval': hasResidentApproval,
        'hasEmergencyView': hasEmergencyView,
        'hasAuditLogs': hasAuditLogs,
        'hasOfflineSync': hasOfflineSync,
        'hasAdvancedReports': hasAdvancedReports,
      };

  factory PlanLimits.fromJson(Map<String, dynamic> json) => PlanLimits(
        maxGates: json['maxGates'] ?? 5,
        maxGuards: json['maxGuards'] ?? 10,
        maxFlats: json['maxFlats'] ?? 100,
        storageLimitGb: json['storageLimitGb'] ?? 5,
        hasQrSystem: json['hasQrSystem'] ?? true,
        hasResidentApproval: json['hasResidentApproval'] ?? true,
        hasEmergencyView: json['hasEmergencyView'] ?? true,
        hasAuditLogs: json['hasAuditLogs'] ?? true,
        hasOfflineSync: json['hasOfflineSync'] ?? true,
        hasAdvancedReports: json['hasAdvancedReports'] ?? true,
      );
}

class SubscriptionPlan {
  final String id;
  final String name;
  final SubscriptionTier tier;
  final double priceMonthly;
  final double priceYearly;
  final String description;
  final List<String> features;
  final PlanLimits limits;
  final bool isPopular;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.priceMonthly,
    required this.priceYearly,
    required this.description,
    required this.features,
    required this.limits,
    this.isPopular = false,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tier': tier.name,
        'priceMonthly': priceMonthly,
        'priceYearly': priceYearly,
        'description': description,
        'features': features,
        'limits': limits.toJson(),
        'isPopular': isPopular,
        'isActive': isActive,
      };

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        id: json['id'],
        name: json['name'],
        tier: SubscriptionTier.values.firstWhere(
          (e) => e.name == json['tier'],
          orElse: () => SubscriptionTier.standard,
        ),
        priceMonthly: (json['priceMonthly'] as num).toDouble(),
        priceYearly: (json['priceYearly'] as num).toDouble(),
        description: json['description'],
        features: List<String>.from(json['features'] ?? []),
        limits: PlanLimits.fromJson(json['limits'] ?? {}),
        isPopular: json['isPopular'] ?? false,
        isActive: json['isActive'] ?? true,
      );
}

class SocietySubscription {
  final String id;
  final String tenantId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String billingCycle; // monthly, yearly
  final double lastPaymentAmount;
  final DateTime? lastPaymentDate;
  final DateTime nextBillingDate;
  final String paymentMethod;
  final bool autoRenew;

  SocietySubscription({
    required this.id,
    required this.tenantId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.billingCycle = 'yearly',
    required this.lastPaymentAmount,
    this.lastPaymentDate,
    required this.nextBillingDate,
    this.paymentMethod = 'UPI / NetBanking',
    this.autoRenew = true,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'planId': planId,
        'status': status.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'billingCycle': billingCycle,
        'lastPaymentAmount': lastPaymentAmount,
        'lastPaymentDate': lastPaymentDate?.toIso8601String(),
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'autoRenew': autoRenew,
      };

  factory SocietySubscription.fromJson(Map<String, dynamic> json) =>
      SocietySubscription(
        id: json['id'],
        tenantId: json['tenantId'],
        planId: json['planId'],
        status: SubscriptionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SubscriptionStatus.trial,
        ),
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        billingCycle: json['billingCycle'] ?? 'yearly',
        lastPaymentAmount: (json['lastPaymentAmount'] as num).toDouble(),
        lastPaymentDate: json['lastPaymentDate'] != null
            ? DateTime.parse(json['lastPaymentDate'])
            : null,
        nextBillingDate: DateTime.parse(json['nextBillingDate']),
        paymentMethod: json['paymentMethod'] ?? 'UPI / NetBanking',
        autoRenew: json['autoRenew'] ?? true,
      );
}
