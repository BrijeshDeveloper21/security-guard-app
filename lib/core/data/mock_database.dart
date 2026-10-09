// Mock database and seed dataset for local development, multi-tenancy verification, and demo

import 'package:security_app/features/resident/models/tenant.dart';
import 'package:security_app/features/super_admin/models/subscription.dart';
import 'package:security_app/core/models/user.dart';
import 'package:security_app/features/guard/models/gate.dart';
import 'package:security_app/features/resident/models/flat.dart';
import 'package:security_app/features/resident/models/guard_resident.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/features/resident/models/approval.dart';
import 'package:security_app/features/admin/models/audit_notification.dart';
import 'package:security_app/core/models/sync_queue.dart';

class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal() {
    _initializeSeedData();
  }

  // Multi-tenant in-memory collections
  final List<Tenant> tenants = [];
  final List<SubscriptionPlan> subscriptionPlans = [];
  final List<SocietySubscription> subscriptions = [];
  final List<AppUser> users = [];
  final List<Gate> gates = [];
  final List<Wing> wings = [];
  final List<Flat> flats = [];
  final List<GuardProfile> guards = [];
  final List<ResidentProfile> residents = [];
  final List<Visitor> visitors = [];
  final List<Visit> visits = [];
  final List<VisitorApproval> approvals = [];
  final List<AuditLog> auditLogs = [];
  final List<NotificationItem> notifications = [];
  final List<SyncQueueItem> syncQueue = [];

  // Network simulation state
  bool isOnline = true;
  SyncStatus syncStatus = SyncStatus.synced;

  void _initializeSeedData() {
    // 1. Subscription Plans
    subscriptionPlans.addAll([
      const SubscriptionPlan(
        id: 'plan_basic',
        name: 'Basic',
        tier: SubscriptionTier.basic,
        priceMonthly: 1999.0,
        priceYearly: 19999.0,
        description: 'Essential gate security & visitor photo logging',
        features: [
          'Visitor Management',
          'Visitor Photo Capture',
          'Automatic Entry/Exit',
          'Multiple Gates (Up to 3)',
          'Visitor History (90 Days)',
        ],
        limits: PlanLimits(
          maxGates: 3,
          maxGuards: 6,
          maxFlats: 100,
          storageLimitGb: 2,
          hasQrSystem: false,
          hasResidentApproval: false,
          hasEmergencyView: false,
          hasAuditLogs: true,
          hasOfflineSync: true,
          hasAdvancedReports: false,
        ),
      ),
      const SubscriptionPlan(
        id: 'plan_standard',
        name: 'Standard',
        tier: SubscriptionTier.standard,
        priceMonthly: 3999.0,
        priceYearly: 39999.0,
        description: 'Complete security with QR passes & resident approvals',
        isPopular: true,
        features: [
          'Everything in Basic',
          'Resident Digital Approvals',
          'Cross-Gate QR System',
          'Real-time Notifications',
          'Emergency Evacuation View',
          'Staff & Delivery Management',
          'Multiple Gates (Up to 10)',
        ],
        limits: PlanLimits(
          maxGates: 10,
          maxGuards: 25,
          maxFlats: 500,
          storageLimitGb: 10,
          hasQrSystem: true,
          hasResidentApproval: true,
          hasEmergencyView: true,
          hasAuditLogs: true,
          hasOfflineSync: true,
          hasAdvancedReports: true,
        ),
      ),
      const SubscriptionPlan(
        id: 'plan_premium',
        name: 'Premium',
        tier: SubscriptionTier.premium,
        priceMonthly: 7999.0,
        priceYearly: 79999.0,
        description: 'Enterprise security, unlimited gates & deep analytics',
        features: [
          'Everything in Standard',
          'Unlimited Gates & Wings',
          'Advanced Security Analytics',
          'Automated Vehicle OCR',
          'Dedicated Security SLA',
          'Long-term Data Archiving',
        ],
        limits: PlanLimits(
          maxGates: 50,
          maxGuards: 100,
          maxFlats: 2500,
          storageLimitGb: 100,
          hasQrSystem: true,
          hasResidentApproval: true,
          hasEmergencyView: true,
          hasAuditLogs: true,
          hasOfflineSync: true,
          hasAdvancedReports: true,
        ),
      ),
    ]);

    // 2. Tenants (Societies)
    final tenantSunrise = Tenant(
      id: 'tenant_sunrise',
      name: 'Sunrise Heights Cooperative Society',
      buildingName: 'Sunrise Heights',
      address: 'Plot 42, Sector 18, Palm Beach Road, Vashi',
      city: 'Navi Mumbai',
      contactPhone: '+91 98200 99881',
      contactEmail: 'security@sunriseheights.com',
      timezone: 'Asia/Kolkata',
      subscriptionStatus: SubscriptionStatus.active,
      subscriptionPlanId: 'plan_standard',
      subscriptionExpiresAt: DateTime.now().add(const Duration(days: 180)),
      securitySettings: const TenantSecuritySettings(
        requireVisitorPhoto: true,
        requireDeliveryApproval: false,
        requireGuestApproval: true,
        requireCabApproval: false,
        autoApprovePreApproved: true,
      ),
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );

    final tenantGreenValley = Tenant(
      id: 'tenant_green_valley',
      name: 'Green Valley Residency',
      buildingName: 'Green Valley Towers',
      address: 'Hill View Road, Baner',
      city: 'Pune',
      contactPhone: '+91 98333 44556',
      contactEmail: 'admin@greenvalley.com',
      timezone: 'Asia/Kolkata',
      subscriptionStatus: SubscriptionStatus.active,
      subscriptionPlanId: 'plan_basic',
      subscriptionExpiresAt: DateTime.now().add(const Duration(days: 60)),
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    tenants.addAll([tenantSunrise, tenantGreenValley]);

    // 3. Subscriptions
    subscriptions.addAll([
      SocietySubscription(
        id: 'sub_sunrise_01',
        tenantId: 'tenant_sunrise',
        planId: 'plan_standard',
        status: SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().add(const Duration(days: 180)),
        lastPaymentAmount: 39999.0,
        lastPaymentDate: DateTime.now().subtract(const Duration(days: 90)),
        nextBillingDate: DateTime.now().add(const Duration(days: 180)),
        paymentMethod: 'UPI / Razorpay',
      ),
      SocietySubscription(
        id: 'sub_greenvalley_01',
        tenantId: 'tenant_green_valley',
        planId: 'plan_basic',
        status: SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        lastPaymentAmount: 19999.0,
        lastPaymentDate: DateTime.now().subtract(const Duration(days: 30)),
        nextBillingDate: DateTime.now().add(const Duration(days: 60)),
        paymentMethod: 'Bank Transfer',
      ),
    ]);

    // 4. Gates for Sunrise Heights (Dynamic 3 Gates)
    gates.addAll([
      Gate(
        id: 'gate_sunrise_a',
        tenantId: 'tenant_sunrise',
        name: 'Gate A - Main Entrance',
        code: 'GATE-A',
        type: GateType.mainEntrance,
        description: 'Main vehicular and visitor gate',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Gate(
        id: 'gate_sunrise_b',
        tenantId: 'tenant_sunrise',
        name: 'Gate B - Parking Gate',
        code: 'GATE-B',
        type: GateType.parking,
        description: 'Basement and surface parking exit/entry',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Gate(
        id: 'gate_sunrise_c',
        tenantId: 'tenant_sunrise',
        name: 'Gate C - Service Gate',
        code: 'GATE-C',
        type: GateType.service,
        description: 'Vendor, deliveries and technician gate',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      // Gate for Green Valley
      Gate(
        id: 'gate_gv_1',
        tenantId: 'tenant_green_valley',
        name: 'Main North Gate',
        code: 'GV-GATE-1',
        type: GateType.mainEntrance,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ]);

    // 5. Wings & Flats for Sunrise Heights
    wings.addAll([
      Wing(
        id: 'wing_a',
        tenantId: 'tenant_sunrise',
        name: 'Wing A',
        totalFloors: 14,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Wing(
        id: 'wing_b',
        tenantId: 'tenant_sunrise',
        name: 'Wing B',
        totalFloors: 14,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Wing(
        id: 'wing_c',
        tenantId: 'tenant_sunrise',
        name: 'Wing C',
        totalFloors: 14,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ]);

    flats.addAll([
      const Flat(
        id: 'flat_b_1204',
        tenantId: 'tenant_sunrise',
        wingId: 'wing_b',
        wingName: 'Wing B',
        flatNumber: 'B-1204',
        floor: 12,
        residentName: 'Rajesh Sharma',
        residentPhone: '+91 98765 43210',
        residentEmail: 'rajesh.sharma@example.com',
      ),
      const Flat(
        id: 'flat_a_101',
        tenantId: 'tenant_sunrise',
        wingId: 'wing_a',
        wingName: 'Wing A',
        flatNumber: 'A-101',
        floor: 1,
        residentName: 'Priya Verma',
        residentPhone: '+91 98200 11223',
        residentEmail: 'priya.verma@example.com',
      ),
      const Flat(
        id: 'flat_a_502',
        tenantId: 'tenant_sunrise',
        wingId: 'wing_a',
        wingName: 'Wing A',
        flatNumber: 'A-502',
        floor: 5,
        residentName: 'Vikram Mehta',
        residentPhone: '+91 98190 33445',
        residentEmail: 'vikram.mehta@example.com',
      ),
      const Flat(
        id: 'flat_c_301',
        tenantId: 'tenant_sunrise',
        wingId: 'wing_c',
        wingName: 'Wing C',
        flatNumber: 'C-301',
        floor: 3,
        residentName: 'Anand Kulkarni',
        residentPhone: '+91 98670 55667',
        residentEmail: 'anand.k@example.com',
      ),
      // Flat in Green Valley
      const Flat(
        id: 'flat_gv_101',
        tenantId: 'tenant_green_valley',
        wingId: 'wing_gv_1',
        wingName: 'Tower 1',
        flatNumber: 'T1-101',
        floor: 1,
        residentName: 'Sunil Rao',
        residentPhone: '+91 99000 88776',
      ),
    ]);

    // 6. Users across roles
    users.addAll([
      AppUser(
        id: 'user_super_admin',
        name: 'Aakash Singhal',
        email: 'superadmin@antigravity.security',
        phone: '+91 98000 11111',
        role: UserRole.superAdmin,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      AppUser(
        id: 'user_society_admin',
        tenantId: 'tenant_sunrise',
        name: 'Sunil Nair (Secretary)',
        email: 'admin@sunriseheights.com',
        phone: '+91 98200 99881',
        role: UserRole.societyAdmin,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      AppUser(
        id: 'user_guard_gate_a',
        tenantId: 'tenant_sunrise',
        name: 'Ramesh Singh',
        email: 'guard.gatea@sunriseheights.com',
        phone: '+91 97690 12345',
        role: UserRole.guard,
        assignedGateId: 'gate_sunrise_a',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      AppUser(
        id: 'user_guard_gate_b',
        tenantId: 'tenant_sunrise',
        name: 'Suresh Patil',
        email: 'guard.gateb@sunriseheights.com',
        phone: '+91 97690 54321',
        role: UserRole.guard,
        assignedGateId: 'gate_sunrise_b',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      AppUser(
        id: 'user_resident_b1204',
        tenantId: 'tenant_sunrise',
        name: 'Rajesh Sharma',
        email: 'resident.b1204@sunriseheights.com',
        phone: '+91 98765 43210',
        role: UserRole.resident,
        flatId: 'flat_b_1204',
        flatNumber: 'B-1204',
        wingName: 'Wing B',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ]);

    // 7. Guards & Residents Profiles
    guards.addAll([
      GuardProfile(
        id: 'guard_prof_1',
        tenantId: 'tenant_sunrise',
        userId: 'user_guard_gate_a',
        name: 'Ramesh Singh',
        phone: '+91 97690 12345',
        badgeNumber: 'SEC-042',
        assignedGateId: 'gate_sunrise_a',
        assignedGateName: 'Gate A - Main Entrance',
        shift: GuardShift.morning,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      GuardProfile(
        id: 'guard_prof_2',
        tenantId: 'tenant_sunrise',
        userId: 'user_guard_gate_b',
        name: 'Suresh Patil',
        phone: '+91 97690 54321',
        badgeNumber: 'SEC-043',
        assignedGateId: 'gate_sunrise_b',
        assignedGateName: 'Gate B - Parking Gate',
        shift: GuardShift.afternoon,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ]);

    residents.addAll([
      ResidentProfile(
        id: 'res_prof_1',
        tenantId: 'tenant_sunrise',
        userId: 'user_resident_b1204',
        name: 'Rajesh Sharma',
        phone: '+91 98765 43210',
        email: 'resident.b1204@sunriseheights.com',
        flatId: 'flat_b_1204',
        flatNumber: 'B-1204',
        wingName: 'Wing B',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ]);

    // 8. Sample Visitors (with previous visits for auto-completion)
    visitors.addAll([
      Visitor(
        id: 'vis_rk_01',
        tenantId: 'tenant_sunrise',
        name: 'Rajesh Kumar',
        phone: '9876543210',
        vehicleNumber: 'MH-43-AK-2024',
        visitorType: VisitorType.technician,
        totalVisits: 3,
        lastVisitedFlat: 'B-1204',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastVisitAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Visitor(
        id: 'vis_ad_02',
        tenantId: 'tenant_sunrise',
        name: 'Anita Desai',
        phone: '9820011223',
        vehicleNumber: 'MH-04-DZ-8910',
        visitorType: VisitorType.delivery,
        totalVisits: 8,
        lastVisitedFlat: 'A-101',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastVisitAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Visitor(
        id: 'vis_vk_03',
        tenantId: 'tenant_sunrise',
        name: 'Vikas Dubey (Ola Cab)',
        phone: '9819988776',
        vehicleNumber: 'MH-03-CB-4433',
        visitorType: VisitorType.cab,
        totalVisits: 1,
        lastVisitedFlat: 'B-1204',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);

    // 9. Visits (Sample currently INSIDE and EXITED visits)
    final entryTimeToday = DateTime.now().subtract(const Duration(hours: 1, minutes: 15));
    visits.addAll([
      Visit(
        id: 'VIS-2026-000101',
        tenantId: 'tenant_sunrise',
        visitorId: 'vis_rk_01',
        visitorName: 'Rajesh Kumar',
        visitorPhone: '9876543210',
        flatId: 'flat_b_1204',
        flatNumber: 'B-1204',
        wingName: 'Wing B',
        visitorType: VisitorType.technician,
        purpose: VisitPurpose.repair,
        customPurpose: 'AC Repair & Servicing',
        vehicleNumber: 'MH-43-AK-2024',
        entryGateId: 'gate_sunrise_a',
        entryGateName: 'Gate A - Main Entrance',
        entryGuardId: 'user_guard_gate_a',
        entryGuardName: 'Ramesh Singh',
        entryTimestamp: entryTimeToday,
        status: VisitStatus.inside,
        approvalStatus: ApprovalStatus.approved,
        secureVisitToken: 'TOKEN-VIS-2026-000101-SECURE-892',
      ),
      Visit(
        id: 'VIS-2026-000098',
        tenantId: 'tenant_sunrise',
        visitorId: 'vis_ad_02',
        visitorName: 'Anita Desai',
        visitorPhone: '9820011223',
        flatId: 'flat_a_101',
        flatNumber: 'A-101',
        wingName: 'Wing A',
        visitorType: VisitorType.delivery,
        purpose: VisitPurpose.delivery,
        customPurpose: 'Amazon Courier Delivery',
        vehicleNumber: 'MH-04-DZ-8910',
        entryGateId: 'gate_sunrise_a',
        entryGateName: 'Gate A - Main Entrance',
        entryGuardId: 'user_guard_gate_a',
        entryGuardName: 'Ramesh Singh',
        entryTimestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 10)),
        exitGateId: 'gate_sunrise_b',
        exitGateName: 'Gate B - Parking Gate',
        exitGuardId: 'user_guard_gate_b',
        exitGuardName: 'Suresh Patil',
        exitTimestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
        status: VisitStatus.exited,
        approvalStatus: ApprovalStatus.notRequired,
        secureVisitToken: 'TOKEN-VIS-2026-000098-SECURE-114',
      ),
      // Visit in Green Valley to verify strict multi-tenant isolation
      Visit(
        id: 'VIS-GV-000001',
        tenantId: 'tenant_green_valley',
        visitorId: 'vis_gv_99',
        visitorName: 'Deepak Joshi',
        visitorPhone: '9988776655',
        flatId: 'flat_gv_101',
        flatNumber: 'T1-101',
        wingName: 'Tower 1',
        visitorType: VisitorType.guest,
        purpose: VisitPurpose.meetingResident,
        entryGateId: 'gate_gv_1',
        entryGateName: 'Main North Gate',
        entryGuardId: 'guard_gv_1',
        entryGuardName: 'Security Guard GV',
        entryTimestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: VisitStatus.inside,
        approvalStatus: ApprovalStatus.approved,
        secureVisitToken: 'TOKEN-GV-000001-SECURE-001',
      ),
    ]);

    // 10. Audit logs
    auditLogs.addAll([
      AuditLog(
        id: 'audit_01',
        tenantId: 'tenant_sunrise',
        userId: 'user_guard_gate_a',
        userName: 'Ramesh Singh',
        userRole: 'Security Guard',
        action: 'ENTRY_RECORDED',
        entityType: 'Visit',
        entityId: 'VIS-2026-000101',
        details: 'Recorded entry for Rajesh Kumar at Gate A - Main Entrance',
        timestamp: entryTimeToday,
      ),
      AuditLog(
        id: 'audit_02',
        tenantId: 'tenant_sunrise',
        userId: 'user_guard_gate_b',
        userName: 'Suresh Patil',
        userRole: 'Security Guard',
        action: 'EXIT_RECORDED',
        entityType: 'Visit',
        entityId: 'VIS-2026-000098',
        details: 'Recorded cross-gate exit at Gate B - Parking Gate',
        timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
      ),
    ]);
  }
}
