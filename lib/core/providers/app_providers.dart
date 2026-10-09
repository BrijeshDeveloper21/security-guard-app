// Central Riverpod state providers for the SaaS platform

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:security_app/core/models/user.dart';
import 'package:security_app/features/resident/models/tenant.dart';
import 'package:security_app/features/guard/models/gate.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/features/auth/services/auth_service.dart';
import 'package:security_app/features/guard/services/visitor_service.dart';
import 'package:security_app/features/guard/services/gate_service.dart';
import 'package:security_app/features/resident/services/resident_service.dart';
import 'package:security_app/features/super_admin/services/subscription_service.dart';
import 'package:security_app/features/admin/services/society_service.dart';
import 'package:security_app/features/super_admin/services/super_admin_service.dart';
import 'package:security_app/core/services/sync_service.dart';
import 'package:security_app/features/admin/services/audit_service.dart';

// Service Providers
final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService();
});

final visitorServiceProvider = ChangeNotifierProvider<VisitorService>((ref) {
  return VisitorService();
});

final gateServiceProvider = ChangeNotifierProvider<GateService>((ref) {
  return GateService();
});

final residentServiceProvider = ChangeNotifierProvider<ResidentService>((ref) {
  return ResidentService();
});

final subscriptionServiceProvider =
    ChangeNotifierProvider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final societyServiceProvider = ChangeNotifierProvider<SocietyService>((ref) {
  return SocietyService();
});

final superAdminServiceProvider =
    ChangeNotifierProvider<SuperAdminService>((ref) {
  return SuperAdminService();
});

final syncServiceProvider = ChangeNotifierProvider<SyncService>((ref) {
  return SyncService();
});

final auditServiceProvider = Provider<AuditService>((ref) {
  return AuditService();
});

// Computed State Providers
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final currentTenantProvider = Provider<Tenant?>((ref) {
  return ref.watch(authServiceProvider).currentTenant;
});

final activeGateProvider = Provider<Gate?>((ref) {
  return ref.watch(authServiceProvider).activeGate;
});

final currentlyInsideListProvider = Provider<List<Visit>>((ref) {
  final tenant = ref.watch(currentTenantProvider);
  final visitorService = ref.watch(visitorServiceProvider);
  if (tenant == null) return [];
  return visitorService.getCurrentlyInside(tenant.id);
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(syncServiceProvider).isOnline;
});

// Localization / Language Provider
class LanguageNotifier extends Notifier<String> {
  @override
  String build() => 'EN';
  void setLang(String val) => state = val;

  String translate(String key) {
    final Map<String, Map<String, String>> translations = {
      'EN': {
        'greeting_morning': 'Good Morning',
        'greeting_afternoon': 'Good Afternoon',
        'greeting_evening': 'Good Evening',
        'new_visitor': 'NEW VISITOR',
        'new_visitor_sub': 'Photo & Quick Entry',
        'delivery': 'DELIVERY',
        'delivery_sub': 'Courier & Packages',
        'scan_qr': 'SCAN QR',
        'scan_qr_sub': 'Cross-Gate & Exit',
        'find_visitor': 'FIND VISITOR',
        'find_visitor_sub': 'Mobile / Flat / ID',
        'currently_inside': 'CURRENTLY INSIDE',
        'currently_inside_sub': 'Active Visits',
        'emergency': 'EMERGENCY VIEW',
        'emergency_sub': 'Immediate Evac List',
        'security_actions': 'SECURITY ACTIONS',
        'logout': 'Logout',
        'visitor_history': 'Visitor History',
        'resident_services': 'RESIDENT SERVICES',
        'visitor_approval_req': 'VISITOR APPROVAL REQUESTS',
        'my_flat_log': 'MY FLAT VISITOR LOG',
        'pay_bills': 'Pay Bills',
        'helpdesk': 'Helpdesk',
        'my_profile': 'My Profile',
        'approve': 'APPROVE',
        'reject': 'REJECT',
      },
      'HI': {
        'greeting_morning': 'शुभ प्रभात',
        'greeting_afternoon': 'शुभ दोपहर',
        'greeting_evening': 'शुभ संध्या',
        'new_visitor': 'नया आगंतुक',
        'new_visitor_sub': 'फोटो और त्वरित प्रवेश',
        'delivery': 'डिलीवरी',
        'delivery_sub': 'कूरियर और पैकेज',
        'scan_qr': 'क्यूआर स्कैन',
        'scan_qr_sub': 'गेट से बाहर',
        'find_visitor': 'आगंतुक खोजें',
        'find_visitor_sub': 'मोबाइल / फ्लैट / आईडी',
        'currently_inside': 'वर्तमान में अंदर',
        'currently_inside_sub': 'सक्रिय दौरे',
        'emergency': 'आपातकालीन दृश्य',
        'emergency_sub': 'तत्काल निकासी',
        'security_actions': 'सुरक्षा क्रियाएं',
        'logout': 'लॉग आउट',
        'visitor_history': 'आगंतुक इतिहास',
        'resident_services': 'निवासी सेवाएं',
        'visitor_approval_req': 'आगंतुक अनुमोदन अनुरोध',
        'my_flat_log': 'मेरा फ्लैट आगंतुक लॉग',
        'pay_bills': 'बिल भुगतान',
        'helpdesk': 'हेल्पडेस्क',
        'my_profile': 'मेरी प्रोफ़ाइल',
        'approve': 'मंजूर करें',
        'reject': 'अस्वीकार करें',
      },
      'MR': {
        'greeting_morning': 'शुभ सकाळ',
        'greeting_afternoon': 'शुभ दुपार',
        'greeting_evening': 'शुभ संध्याकाळ',
        'new_visitor': 'नवीन अभ्यागत',
        'new_visitor_sub': 'फोटो आणि प्रवेश',
        'delivery': 'वितरण',
        'delivery_sub': 'कुरियर आणि पॅकेजेस',
        'scan_qr': 'क्यूआर स्कॅन',
        'scan_qr_sub': 'बाहेर जा',
        'find_visitor': 'अभ्यागत शोधा',
        'find_visitor_sub': 'मोबाईल / फ्लॅट',
        'currently_inside': 'सध्या आत',
        'currently_inside_sub': 'सक्रिय भेटी',
        'emergency': 'आणीबाणी दृश्य',
        'emergency_sub': 'तातडीने बाहेर काढा',
        'security_actions': 'सुरक्षा कृती',
        'logout': 'लॉग आउट',
        'visitor_history': 'अभ्यागत इतिहास',
        'resident_services': 'रहिवासी सेवा',
        'visitor_approval_req': 'अभ्यागत मान्यता विनंत्या',
        'my_flat_log': 'माझा फ्लॅट लॉग',
        'pay_bills': 'बिल भरा',
        'helpdesk': 'मदत केंद्र',
        'my_profile': 'माझे प्रोफाइल',
        'approve': 'मंजूर करा',
        'reject': 'नाकारा',
      },
    };

    return translations[state]?[key] ?? translations['EN']![key] ?? key;
  }
}
final languageProvider = NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);
