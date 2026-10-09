// Guard and Resident operational profiles

enum GuardShift {
  morning, // 06:00 - 14:00
  afternoon, // 14:00 - 22:00
  night, // 22:00 - 06:00
}

extension GuardShiftExt on GuardShift {
  String get nameDisplay {
    switch (this) {
      case GuardShift.morning:
        return 'Morning (6 AM - 2 PM)';
      case GuardShift.afternoon:
        return 'Afternoon (2 PM - 10 PM)';
      case GuardShift.night:
        return 'Night (10 PM - 6 AM)';
    }
  }
}

class GuardProfile {
  final String id;
  final String tenantId;
  final String userId;
  final String name;
  final String phone;
  final String? badgeNumber;
  final String assignedGateId;
  final String assignedGateName;
  final GuardShift shift;
  final bool isOnDuty;
  final bool isActive;
  final DateTime createdAt;

  const GuardProfile({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.name,
    required this.phone,
    this.badgeNumber,
    required this.assignedGateId,
    required this.assignedGateName,
    this.shift = GuardShift.morning,
    this.isOnDuty = true,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'userId': userId,
        'name': name,
        'phone': phone,
        'badgeNumber': badgeNumber,
        'assignedGateId': assignedGateId,
        'assignedGateName': assignedGateName,
        'shift': shift.name,
        'isOnDuty': isOnDuty,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GuardProfile.fromJson(Map<String, dynamic> json) => GuardProfile(
        id: json['id'],
        tenantId: json['tenantId'],
        userId: json['userId'],
        name: json['name'],
        phone: json['phone'],
        badgeNumber: json['badgeNumber'],
        assignedGateId: json['assignedGateId'] ?? '',
        assignedGateName: json['assignedGateName'] ?? 'Main Gate',
        shift: GuardShift.values.firstWhere(
          (e) => e.name == json['shift'],
          orElse: () => GuardShift.morning,
        ),
        isOnDuty: json['isOnDuty'] ?? true,
        isActive: json['isActive'] ?? true,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );

  GuardProfile copyWith({
    String? id,
    String? tenantId,
    String? userId,
    String? name,
    String? phone,
    String? badgeNumber,
    String? assignedGateId,
    String? assignedGateName,
    GuardShift? shift,
    bool? isOnDuty,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return GuardProfile(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      assignedGateId: assignedGateId ?? this.assignedGateId,
      assignedGateName: assignedGateName ?? this.assignedGateName,
      shift: shift ?? this.shift,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ResidentProfile {
  final String id;
  final String tenantId;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String flatId;
  final String flatNumber; // B-1204
  final String wingName; // Wing B
  final bool isOwner;
  final bool isActive;
  final DateTime createdAt;

  const ResidentProfile({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.flatId,
    required this.flatNumber,
    required this.wingName,
    this.isOwner = true,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'userId': userId,
        'name': name,
        'phone': phone,
        'email': email,
        'flatId': flatId,
        'flatNumber': flatNumber,
        'wingName': wingName,
        'isOwner': isOwner,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ResidentProfile.fromJson(Map<String, dynamic> json) => ResidentProfile(
        id: json['id'],
        tenantId: json['tenantId'],
        userId: json['userId'],
        name: json['name'],
        phone: json['phone'],
        email: json['email'] ?? '',
        flatId: json['flatId'],
        flatNumber: json['flatNumber'],
        wingName: json['wingName'] ?? '',
        isOwner: json['isOwner'] ?? true,
        isActive: json['isActive'] ?? true,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );
}
