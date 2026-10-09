// User & Authentication models with RBAC

enum UserRole {
  superAdmin,
  societyAdmin,
  guard,
  resident,
}

extension UserRoleExt on UserRole {
  String get nameDisplay {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.societyAdmin:
        return 'Society Admin';
      case UserRole.guard:
        return 'Security Guard';
      case UserRole.resident:
        return 'Resident';
    }
  }

  bool get isGuard => this == UserRole.guard;
  bool get isResident => this == UserRole.resident;
  bool get isAdmin => this == UserRole.societyAdmin || this == UserRole.superAdmin;
  bool get isSuperAdmin => this == UserRole.superAdmin;
}

class AppUser {
  final String id;
  final String? tenantId; // null for superAdmin
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? assignedGateId; // for guard
  final String? flatId; // for resident
  final String? flatNumber; // for resident
  final String? wingName; // for resident
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    this.tenantId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.assignedGateId,
    this.flatId,
    this.flatNumber,
    this.wingName,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'assignedGateId': assignedGateId,
        'flatId': flatId,
        'flatNumber': flatNumber,
        'wingName': wingName,
        'avatarUrl': avatarUrl,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        tenantId: json['tenantId'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.guard,
        ),
        assignedGateId: json['assignedGateId'],
        flatId: json['flatId'],
        flatNumber: json['flatNumber'],
        wingName: json['wingName'],
        avatarUrl: json['avatarUrl'],
        isActive: json['isActive'] ?? true,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );

  AppUser copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? assignedGateId,
    String? flatId,
    String? flatNumber,
    String? wingName,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      assignedGateId: assignedGateId ?? this.assignedGateId,
      flatId: flatId ?? this.flatId,
      flatNumber: flatNumber ?? this.flatNumber,
      wingName: wingName ?? this.wingName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
