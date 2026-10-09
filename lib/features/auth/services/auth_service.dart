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

  /// Smart Phone Number Based Login Lookup
  Future<AppUser?> lookupUserByPhone(String phone) async {
    try {
      final user = _db.users.firstWhere((u) => u.phone == phone);
      return user;
    } catch (_) {
      return null; // User not found in mock DB
    }
  }

  /// OTP Verification & Smart Login Routing
  Future<bool> verifyOtpAndLogin(String phone, String otp) async {
    // Mock OTP verification (1234 is universal mock OTP)
    if (otp != '1234') return false;

    try {
      // Find user based purely on Phone Number
      _currentUser = _db.users.firstWhere((u) => u.phone == phone);
      
      // Setup Tenant for the found user
      if (_currentUser?.tenantId != null) {
        _currentTenant = _db.tenants.firstWhere(
          (t) => t.id == _currentUser!.tenantId,
          orElse: () => _db.tenants.first,
        );
      } else {
        _currentTenant = _db.tenants.first;
      }

      // If Guard, assign active gate
      if (_currentUser?.role == UserRole.guard) {
         _activeGate = _db.gates.firstWhere(
          (g) => g.tenantId == _currentTenant!.id,
          orElse: () => _db.gates.first,
        );
      } else {
        _activeGate = null;
      }

      // Audit Log
      if (_currentTenant != null) {
        _auditService.logAction(
          tenantId: _currentTenant!.id,
          userId: _currentUser!.id,
          userName: _currentUser!.name,
          userRole: _currentUser!.role.nameDisplay,
          action: 'USER_LOGIN',
          entityType: 'User',
          entityId: _currentUser!.id,
          details: 'User authenticated via OTP with role ${_currentUser!.role.nameDisplay}',
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      // User not found in DB
      return false;
    }
  }

  /// Legacy Email/Password Login (Deprecated but kept for compatibility)
  Future<bool> login(String email, String password, UserRole selectedRole) async {
    // Left for testing compatibility if needed
    return false;
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

  void logout() {
    _currentUser = null;
    _currentTenant = null;
    _activeGate = null;
    notifyListeners();
  }
}
