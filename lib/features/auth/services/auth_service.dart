// Authentication & Session Service with Multi-Tenant RBAC

import 'package:flutter/foundation.dart';
import 'package:security_app/core/models/user.dart';
import 'package:security_app/features/resident/models/tenant.dart';
import 'package:security_app/features/guard/models/gate.dart';
import 'package:security_app/core/data/mock_database.dart';
import 'package:security_app/features/admin/services/audit_service.dart';

class AuthService extends ChangeNotifier {
  final MockDatabase _db = MockDatabase();
  final AuditService _auditService = AuditService();

  AppUser? _currentUser;
  Tenant? _currentTenant;
  Gate? _activeGate;

  AppUser? get currentUser => _currentUser;
  Tenant? get currentTenant => _currentTenant;
  Gate? get activeGate => _activeGate;

  bool get isAuthenticated => _currentUser != null;
  UserRole get currentRole => _currentUser?.role ?? UserRole.guard;

  AuthService() {
    // No default session - force user to login!
  }

  /// Sets the active gate for the logged-in guard (e.g. Gate A vs Gate B)
  void setActiveGate(Gate gate) {
    _activeGate = gate;
    notifyListeners();
  }

  /// Switches active demo role seamlessly to test all 4 application modules & cross-gate exits
  void setDemoSession({
    required UserRole role,
    String? gateCode,
    String tenantId = 'tenant_sunrise',
  }) {
    _currentTenant = _db.tenants.firstWhere(
      (t) => t.id == tenantId,
      orElse: () => _db.tenants.first,
    );

    switch (role) {
      case UserRole.superAdmin:
        _currentUser = _db.users.firstWhere((u) => u.role == UserRole.superAdmin);
        _activeGate = null;
        break;

      case UserRole.societyAdmin:
        _currentUser = _db.users.firstWhere(
          (u) => u.role == UserRole.societyAdmin && u.tenantId == tenantId,
          orElse: () => _db.users.firstWhere((u) => u.role == UserRole.societyAdmin),
        );
        _activeGate = null;
        break;

      case UserRole.guard:
        final targetCode = gateCode ?? 'GATE-A';
        final gate = _db.gates.firstWhere(
          (g) => g.tenantId == tenantId && g.code == targetCode,
          orElse: () => _db.gates.firstWhere((g) => g.tenantId == tenantId),
        );
        _activeGate = gate;

        _currentUser = _db.users.firstWhere(
          (u) =>
              u.role == UserRole.guard &&
              u.tenantId == tenantId &&
              (targetCode == 'GATE-B' ? u.email.contains('gateb') : u.email.contains('gatea')),
          orElse: () => _db.users.firstWhere((u) => u.role == UserRole.guard),
        );
        break;

      case UserRole.resident:
        _currentUser = _db.users.firstWhere(
          (u) => u.role == UserRole.resident && u.tenantId == tenantId,
          orElse: () => _db.users.firstWhere((u) => u.role == UserRole.resident),
        );
        _activeGate = null;
        break;
    }

    if (_currentUser != null && _currentTenant != null) {
      _auditService.logAction(
        tenantId: _currentTenant!.id,
        userId: _currentUser!.id,
        userName: _currentUser!.name,
        userRole: _currentUser!.role.nameDisplay,
        action: 'USER_LOGIN',
        entityType: 'User',
        entityId: _currentUser!.id,
        details: 'User ${_currentUser!.name} authenticated with role ${_currentUser!.role.nameDisplay}',
      );
    }

    notifyListeners();
  }

  /// Login with specific role
  Future<bool> login(String email, String password, UserRole selectedRole) async {
    final lowerEmail = email.trim().toLowerCase();
    
    // Create a dynamic mock user based on the selected role explicitly!
    _currentUser = AppUser(
      id: 'dynamic_user_${DateTime.now().millisecondsSinceEpoch}',
      name: lowerEmail.split('@').first.toUpperCase(),
      email: lowerEmail,
      phone: '9876543210',
      role: selectedRole,
      tenantId: 'tenant_sunrise',
      flatId: selectedRole == UserRole.resident ? 'flat_b_1204' : null,
      flatNumber: selectedRole == UserRole.resident ? 'B-1204' : null,
      wingName: selectedRole == UserRole.resident ? 'Wing B' : null,
      createdAt: DateTime.now(),
    );

    _currentTenant = _db.tenants.first;
    
    if (selectedRole == UserRole.guard) {
      _activeGate = _db.gates.first;
    } else {
      _activeGate = null;
    }

    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _currentTenant = null;
    _activeGate = null;
    notifyListeners();
  }
}
