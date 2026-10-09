// Tenant & Society models for Multi-tenant SaaS Architecture

enum SubscriptionStatus {
  trial,
  active,
  pastDue,
  expired,
  suspended,
  cancelled,
}

extension SubscriptionStatusExt on SubscriptionStatus {
  String get nameDisplay {
    switch (this) {
      case SubscriptionStatus.trial:
        return 'TRIAL';
      case SubscriptionStatus.active:
        return 'ACTIVE';
      case SubscriptionStatus.pastDue:
        return 'PAST_DUE';
      case SubscriptionStatus.expired:
        return 'EXPIRED';
      case SubscriptionStatus.suspended:
        return 'SUSPENDED';
      case SubscriptionStatus.cancelled:
        return 'CANCELLED';
    }
  }

  bool get canOperateGates {
    return this == SubscriptionStatus.active || this == SubscriptionStatus.trial;
  }
}

class TenantSecuritySettings {
  final bool requireVisitorPhoto;
  final bool requireDeliveryApproval;
  final bool requireGuestApproval;
  final bool requireCabApproval;
  final bool autoApprovePreApproved;
  final int visitorHistoryRetentionDays;
  final int photoRetentionDays;
  final bool enforceVehicleNumber;

  const TenantSecuritySettings({
    this.requireVisitorPhoto = true,
    this.requireDeliveryApproval = false,
    this.requireGuestApproval = true,
    this.requireCabApproval = false,
    this.autoApprovePreApproved = true,
    this.visitorHistoryRetentionDays = 365,
    this.photoRetentionDays = 90,
    this.enforceVehicleNumber = false,
  });

  Map<String, dynamic> toJson() => {
        'requireVisitorPhoto': requireVisitorPhoto,
        'requireDeliveryApproval': requireDeliveryApproval,
        'requireGuestApproval': requireGuestApproval,
        'requireCabApproval': requireCabApproval,
        'autoApprovePreApproved': autoApprovePreApproved,
        'visitorHistoryRetentionDays': visitorHistoryRetentionDays,
        'photoRetentionDays': photoRetentionDays,
        'enforceVehicleNumber': enforceVehicleNumber,
      };

  factory TenantSecuritySettings.fromJson(Map<String, dynamic> json) =>
      TenantSecuritySettings(
        requireVisitorPhoto: json['requireVisitorPhoto'] ?? true,
        requireDeliveryApproval: json['requireDeliveryApproval'] ?? false,
        requireGuestApproval: json['requireGuestApproval'] ?? true,
        requireCabApproval: json['requireCabApproval'] ?? false,
        autoApprovePreApproved: json['autoApprovePreApproved'] ?? true,
        visitorHistoryRetentionDays: json['visitorHistoryRetentionDays'] ?? 365,
        photoRetentionDays: json['photoRetentionDays'] ?? 90,
        enforceVehicleNumber: json['enforceVehicleNumber'] ?? false,
      );

  TenantSecuritySettings copyWith({
    bool? requireVisitorPhoto,
    bool? requireDeliveryApproval,
    bool? requireGuestApproval,
    bool? requireCabApproval,
    bool? autoApprovePreApproved,
    int? visitorHistoryRetentionDays,
    int? photoRetentionDays,
    bool? enforceVehicleNumber,
  }) {
    return TenantSecuritySettings(
      requireVisitorPhoto: requireVisitorPhoto ?? this.requireVisitorPhoto,
      requireDeliveryApproval:
          requireDeliveryApproval ?? this.requireDeliveryApproval,
      requireGuestApproval: requireGuestApproval ?? this.requireGuestApproval,
      requireCabApproval: requireCabApproval ?? this.requireCabApproval,
      autoApprovePreApproved:
          autoApprovePreApproved ?? this.autoApprovePreApproved,
      visitorHistoryRetentionDays:
          visitorHistoryRetentionDays ?? this.visitorHistoryRetentionDays,
      photoRetentionDays: photoRetentionDays ?? this.photoRetentionDays,
      enforceVehicleNumber: enforceVehicleNumber ?? this.enforceVehicleNumber,
    );
  }
}

class Tenant {
  final String id;
  final String name;
  final String buildingName;
  final String address;
  final String city;
  final String contactPhone;
  final String contactEmail;
  final String? logoUrl;
  final String timezone;
  final SubscriptionStatus subscriptionStatus;
  final String subscriptionPlanId;
  final DateTime subscriptionExpiresAt;
  final TenantSecuritySettings securitySettings;
  final bool isActive;
  final DateTime createdAt;

  Tenant({
    required this.id,
    required this.name,
    required this.buildingName,
    required this.address,
    required this.city,
    required this.contactPhone,
    required this.contactEmail,
    this.logoUrl,
    this.timezone = 'Asia/Kolkata',
    required this.subscriptionStatus,
    required this.subscriptionPlanId,
    required this.subscriptionExpiresAt,
    this.securitySettings = const TenantSecuritySettings(),
    this.isActive = true,
    required this.createdAt,
  });

  bool get isSubscriptionActive =>
      (subscriptionStatus == SubscriptionStatus.active ||
          subscriptionStatus == SubscriptionStatus.trial) &&
      subscriptionExpiresAt.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'buildingName': buildingName,
        'address': address,
        'city': city,
        'contactPhone': contactPhone,
        'contactEmail': contactEmail,
        'logoUrl': logoUrl,
        'timezone': timezone,
        'subscriptionStatus': subscriptionStatus.name,
        'subscriptionPlanId': subscriptionPlanId,
        'subscriptionExpiresAt': subscriptionExpiresAt.toIso8601String(),
        'securitySettings': securitySettings.toJson(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        id: json['id'],
        name: json['name'],
        buildingName: json['buildingName'] ?? json['name'],
        address: json['address'] ?? '',
        city: json['city'] ?? 'Mumbai',
        contactPhone: json['contactPhone'] ?? '',
        contactEmail: json['contactEmail'] ?? '',
        logoUrl: json['logoUrl'],
        timezone: json['timezone'] ?? 'Asia/Kolkata',
        subscriptionStatus: SubscriptionStatus.values.firstWhere(
          (e) => e.name == json['subscriptionStatus'],
          orElse: () => SubscriptionStatus.trial,
        ),
        subscriptionPlanId: json['subscriptionPlanId'] ?? 'plan_standard',
        subscriptionExpiresAt: DateTime.parse(
          json['subscriptionExpiresAt'] ??
              DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        ),
        securitySettings: json['securitySettings'] != null
            ? TenantSecuritySettings.fromJson(json['securitySettings'])
            : const TenantSecuritySettings(),
        isActive: json['isActive'] ?? true,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );

  Tenant copyWith({
    String? id,
    String? name,
    String? buildingName,
    String? address,
    String? city,
    String? contactPhone,
    String? contactEmail,
    String? logoUrl,
    String? timezone,
    SubscriptionStatus? subscriptionStatus,
    String? subscriptionPlanId,
    DateTime? subscriptionExpiresAt,
    TenantSecuritySettings? securitySettings,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      buildingName: buildingName ?? this.buildingName,
      address: address ?? this.address,
      city: city ?? this.city,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      logoUrl: logoUrl ?? this.logoUrl,
      timezone: timezone ?? this.timezone,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionPlanId: subscriptionPlanId ?? this.subscriptionPlanId,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      securitySettings: securitySettings ?? this.securitySettings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
