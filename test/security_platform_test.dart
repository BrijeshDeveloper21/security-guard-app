import 'package:flutter_test/flutter_test.dart';
import 'package:security_app/features/resident/models/tenant.dart';
import 'package:security_app/core/models/user.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/models/sync_queue.dart';
import 'package:security_app/core/data/mock_database.dart';
import 'package:security_app/features/guard/services/visitor_service.dart';
import 'package:security_app/core/services/qr_service.dart';
import 'package:security_app/features/super_admin/services/subscription_service.dart';
import 'package:security_app/core/services/sync_service.dart';
import 'package:security_app/features/auth/services/auth_service.dart';

void main() {
  group('Critical Security & SaaS Platform Test Suite', () {
    late MockDatabase db;
    late VisitorService visitorService;
    late SubscriptionService subscriptionService;
    late SyncService syncService;
    late AuthService authService;

    setUp(() {
      db = MockDatabase();
      visitorService = VisitorService();
      subscriptionService = SubscriptionService();
      syncService = SyncService();
      authService = AuthService();
    });

    // 1. Visitor creation & Repeat Visitor auto-lookup
    test('1. Visitor creation and repeat lookup test', () async {
      final initialCount = db.visits.length;

      final newVisit = await visitorService.recordNewEntry(
        tenantId: 'tenant_sunrise',
        visitorName: 'Kunal Singhania',
        visitorPhone: '9811223344',
        flatId: 'flat_b_1204',
        flatNumber: 'B-1204',
        wingName: 'Wing B',
        visitorType: VisitorType.guest,
        purpose: VisitPurpose.meetingResident,
        entryGateId: 'gate_sunrise_a',
        entryGateName: 'Gate A - Main Entrance',
        entryGuardId: 'user_guard_gate_a',
        entryGuardName: 'Ramesh Singh',
      );

      expect(db.visits.length, equals(initialCount + 1));
      expect(newVisit.visitorName, equals('Kunal Singhania'));
      expect(newVisit.id.startsWith('VIS-'), isTrue);

      // Repeat visitor lookup test
      final repeatVisitor = visitorService.findRepeatVisitor(
        tenantId: 'tenant_sunrise',
        phone: '9811223344',
      );
      expect(repeatVisitor, isNotNull);
      expect(repeatVisitor!.name, equals('Kunal Singhania'));
      expect(repeatVisitor.lastVisitedFlat, equals('B-1204'));
    });

    // 2. Automatic Entry Timestamp
    test('2. Automatic entry timestamp test (no manual typing)', () async {
      final beforeTime = DateTime.now().subtract(const Duration(seconds: 1));

      final visit = await visitorService.recordNewEntry(
        tenantId: 'tenant_sunrise',
        visitorName: 'Auto Time Test Visitor',
        visitorPhone: '9822334455',
        flatId: 'flat_a_101',
        flatNumber: 'A-101',
        wingName: 'Wing A',
        visitorType: VisitorType.delivery,
        purpose: VisitPurpose.delivery,
        entryGateId: 'gate_sunrise_a',
        entryGateName: 'Gate A - Main Entrance',
        entryGuardId: 'user_guard_gate_a',
        entryGuardName: 'Ramesh Singh',
      );

      final afterTime = DateTime.now().add(const Duration(seconds: 1));

      expect(visit.entryTimestamp.isAfter(beforeTime), isTrue);
      expect(visit.entryTimestamp.isBefore(afterTime), isTrue);
      expect(visit.exitTimestamp, isNull);
      expect(visit.status, equals(VisitStatus.inside));
    });

    // 3. Cross-Gate Exit & Automatic Exit Timestamp
    test('3. Cross-Gate Exit: Enter Gate A -> Exit Gate B automatically recorded', () async {
      // 1. Enter at Gate A
      final visit = await visitorService.recordNewEntry(
        tenantId: 'tenant_sunrise',
        visitorName: 'Cross Gate Visitor',
        visitorPhone: '9833445566',
        flatId: 'flat_b_1204',
        flatNumber: 'B-1204',
        wingName: 'Wing B',
        visitorType: VisitorType.technician,
        purpose: VisitPurpose.repair,
        entryGateId: 'gate_sunrise_a',
        entryGateName: 'Gate A - Main Entrance',
        entryGuardId: 'user_guard_gate_a',
        entryGuardName: 'Ramesh Singh',
      );

      expect(visit.entryGateId, equals('gate_sunrise_a'));
      expect(visit.isInside, isTrue);

      // 2. Exit at Gate B
      final exitedVisit = await visitorService.recordCrossGateExit(
        tenantId: 'tenant_sunrise',
        visitId: visit.id,
        exitGateId: 'gate_sunrise_b',
        exitGateName: 'Gate B - Parking Gate',
        exitGuardId: 'user_guard_gate_b',
        exitGuardName: 'Suresh Patil',
      );

      expect(exitedVisit.status, equals(VisitStatus.exited));
      expect(exitedVisit.exitTimestamp, isNotNull);
      expect(exitedVisit.exitGateId, equals('gate_sunrise_b'));
      expect(exitedVisit.exitGateName, equals('Gate B - Parking Gate'));
      expect(exitedVisit.exitGuardName, equals('Suresh Patil'));
      expect(exitedVisit.isInside, isFalse);
    });

    // 4. QR Identification & Secure Token Verification (No private PII in QR)
    test('4. QR Identification: Secure visit token without plain PII', () {
      final now = DateTime.now();
      final token = QrService.generateSecureVisitToken(
        tenantId: 'tenant_sunrise',
        visitId: 'VIS-2026-000101',
        entryTime: now,
      );

      expect(token.contains('SECURE-V1'), isTrue);
      expect(token.contains('9876543210'), isFalse); // No phone in QR!
      expect(token.contains('Rajesh Kumar'), isFalse); // No name in QR!

      final parsed = QrService.parseAndValidateToken(token);
      expect(parsed['isValid'], isTrue);
      expect(parsed['visitId'], equals('VIS-2026-000101'));
      expect(parsed['tenantId'], equals('tenant_sunrise'));
    });

    // 5. Duplicate / Invalid QR rejection
    test('5. Duplicate / Invalid QR error handling', () {
      final invalidResult = QrService.parseAndValidateToken('MALICIOUS_CORRUPTED_QR_CODE');
      expect(invalidResult['isValid'], isFalse);

      final emptyResult = QrService.parseAndValidateToken('');
      expect(emptyResult['isValid'], isFalse);
    });

    // 6. Currently-Inside filtering
    test('6. Currently-Inside filtering only returns visits where exitTimestamp is null', () {
      final insideList = visitorService.getCurrentlyInside('tenant_sunrise');
      for (final v in insideList) {
        expect(v.status, equals(VisitStatus.inside));
        expect(v.exitTimestamp, isNull);
        expect(v.tenantId, equals('tenant_sunrise'));
      }
    });

    // 7. Strict Multi-Tenant Isolation
    test('7. Multi-Tenant Isolation: Society A cannot access Society B data', () {
      // Fetch visits for Sunrise Heights
      final sunriseVisits = visitorService.getVisitorHistory(tenantId: 'tenant_sunrise');
      for (final v in sunriseVisits) {
        expect(v.tenantId, equals('tenant_sunrise'));
        expect(v.tenantId, isNot(equals('tenant_green_valley')));
      }

      // Fetch visits for Green Valley
      final greenValleyVisits = visitorService.getVisitorHistory(tenantId: 'tenant_green_valley');
      for (final v in greenValleyVisits) {
        expect(v.tenantId, equals('tenant_green_valley'));
        expect(v.tenantId, isNot(equals('tenant_sunrise')));
      }

      // Cross-tenant search attempt should return null
      final crossAttempt = visitorService.findActiveVisitByIdOrToken(
        tenantId: 'tenant_sunrise',
        query: 'VIS-GV-000001', // Green Valley visit ID
      );
      expect(crossAttempt, isNull);
    });

    // 8. Subscription Status & Feature Gating
    test('8. Subscription Status & Feature Access Control', () {
      // Active plan features
      final hasQrSunrise = subscriptionService.isFeatureAllowed(
        tenantId: 'tenant_sunrise',
        featureKey: 'qr_system',
      );
      expect(hasQrSunrise, isTrue); // Standard plan has QR

      // Simulate expired subscription
      subscriptionService.setSubscriptionStatus(
        tenantId: 'tenant_sunrise',
        status: SubscriptionStatus.expired,
      );

      final hasQrAfterExpired = subscriptionService.isFeatureAllowed(
        tenantId: 'tenant_sunrise',
        featureKey: 'qr_system',
      );
      expect(hasQrAfterExpired, isFalse); // Restricted when expired

      // Reactivate
      subscriptionService.setSubscriptionStatus(
        tenantId: 'tenant_sunrise',
        status: SubscriptionStatus.active,
      );
    });

    // 9. Role Permissions & Session Management
    test('9. Role-based access control and gate assignment', () {
      expect(UserRole.guard.isGuard, isTrue);
      expect(UserRole.guard.isAdmin, isFalse);

      expect(UserRole.resident.isResident, isTrue);
      expect(UserRole.resident.isGuard, isFalse);

      expect(UserRole.societyAdmin.isAdmin, isTrue);
      expect(UserRole.superAdmin.isSuperAdmin, isTrue);

      // Verify AuthService role switching
      authService.setDemoSession(role: UserRole.guard, gateCode: 'GATE-B');
      expect(authService.currentUser?.role, equals(UserRole.guard));
      expect(authService.activeGate?.code, equals('GATE-B'));
    });

    // 10. Offline synchronization queue
    test('10. Offline synchronization queue durability', () async {
      // 1. Simulate network drop
      syncService.setNetworkOnline(false);
      expect(syncService.isOnline, isFalse);

      // 2. Queue an action offline
      syncService.enqueueAction(
        tenantId: 'tenant_sunrise',
        action: SyncAction.recordEntry,
        entityId: 'VIS-TEST-OFFLINE',
        payload: {'visitorName': 'Offline Tester'},
      );

      expect(syncService.pendingQueueCount, greaterThanOrEqualTo(1));

      // 3. Reconnect network & trigger sync
      syncService.setNetworkOnline(true);
      expect(syncService.isOnline, isTrue);

      await syncService.triggerSync();
      expect(syncService.syncStatus, equals(SyncStatus.synced));
    });
  });
}
