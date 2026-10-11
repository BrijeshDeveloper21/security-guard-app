// Central Riverpod state providers for the SaaS platform

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

final subscriptionServiceProvider = ChangeNotifierProvider<SubscriptionService>(
  (ref) {
    return SubscriptionService();
  },
);

final societyServiceProvider = ChangeNotifierProvider<SocietyService>((ref) {
  return SocietyService();
});

final superAdminServiceProvider = ChangeNotifierProvider<SuperAdminService>((
  ref,
) {
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
class AppPreferencesData {
  const AppPreferencesData({
    this.language = 'EN',
    this.fontScale = 1,
    this.highContrast = false,
    this.loadFailed = false,
  });

  static const languageKey = 'app_language';
  static const fontScaleKey = 'app_font_scale';
  static const highContrastKey = 'app_high_contrast';
  static const supportedLanguages = {'EN', 'HI', 'MR'};

  final String language;
  final double fontScale;
  final bool highContrast;
  final bool loadFailed;

  static Future<AppPreferencesData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(languageKey);
    final savedFontScale = prefs.getDouble(fontScaleKey);
    return AppPreferencesData(
      language: supportedLanguages.contains(savedLanguage)
          ? savedLanguage!
          : 'EN',
      fontScale: (savedFontScale ?? 1).clamp(0.9, 1.6).toDouble(),
      highContrast: prefs.getBool(highContrastKey) ?? false,
    );
  }
}

final initialAppPreferencesProvider = Provider<AppPreferencesData>(
  (ref) => const AppPreferencesData(),
);

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(initialAppPreferencesProvider).language;

  Future<void> setLang(String val) async {
    if (!AppPreferencesData.supportedLanguages.contains(val)) {
      throw ArgumentError.value(val, 'val', 'Unsupported application language');
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(AppPreferencesData.languageKey, val)) {
      throw StateError('Could not save the selected language');
    }
    state = val;
  }

  static const Map<String, Map<String, String>> _translations = {
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
      'settings_title': 'Accessibility & language',
      'settings_intro': 'Language updates translated copy and system controls. Text size and contrast apply across the app. Choices are saved on this device.',
      'language_label': 'Language',
      'language_english': 'English',
      'language_hindi': 'Hindi',
      'language_marathi': 'Marathi',
      'accessibility_label': 'Accessibility',
      'high_contrast': 'High contrast',
      'high_contrast_help': 'Use stronger text, borders, and focus indicators.',
      'text_size': 'Text size',
      'text_size_help': 'This is applied in addition to your device text size.',
      'small': 'Small',
      'large': 'Large',
      'login_badge': 'SMARTER COMMUNITY SECURITY',
      'login_intro': 'A safer, more welcoming community starts at the gate. Keep visitors moving and residents in control.',
      'login_benefit_checkin': 'Fast, simple visitor check-in',
      'login_benefit_approvals': 'Instant resident approvals',
      'login_benefit_passes': 'Secure passes and gate activity',
      'login_mobile_description': 'Visitor management, resident approvals and gate security — all in one simple place.',
      'login_continue': 'Continue with mobile',
      'login_legal': 'By continuing, you agree to our Terms of Service and Privacy Policy.',
      'login_caption_gate': 'A smoother welcome at every gate',
      'login_caption_approval': 'Visitor requests, handled in seconds',
      'login_caption_pass': 'Verified passes. Effortless entry.',
      'login_caption_emergency': 'Help is always within reach',
      'login_headline_first': 'Every arrival,',
      'login_headline_second': 'a little more ',
      'login_headline_secure': 'secure.',
      'language_picker': 'Select application language',
      'accessibility_settings': 'Accessibility settings',
      'preferences_load_error': 'Saved preferences could not be loaded. Changes will be temporary until storage is available.',
      'dismiss': 'Dismiss',
      'auth_welcome': 'Welcome to Dwarivo',
      'auth_enter_code': 'Enter your code',
      'auth_enter_phone': 'Sign in with your registered mobile number.',
      'auth_code_sent': 'Enter the 4-digit code sent to +91 ',
      'auth_phone_label': 'Mobile Number',
      'auth_send_code': 'Send verification code',
      'auth_code_label': '4-digit verification code',
      'auth_change_number': 'Change number',
      'auth_verify': 'Verify and sign in',
      'auth_demo_title': 'Explore a demo account  ·  OTP: 1234',
      'auth_demo_resident': 'Resident',
      'auth_demo_guard': 'Guard',
      'auth_demo_admin': 'Admin',
      'auth_demo_super_admin': 'Super admin',
      'auth_phone_invalid': 'Please enter a valid 10-digit mobile number',
      'auth_number_not_found': 'Number not found in Society Database. OTP sent for new registration.',
      'auth_code_required': 'Please enter the 4-digit OTP',
      'auth_code_invalid': 'Invalid OTP. Please try again.',
      'auth_sending': 'Sending verification code',
      'auth_verifying': 'Verifying code',
      'auth_send_failed':
          'Could not send the verification code. Please try again.',
      'auth_verify_failed': 'Could not verify the code. Please try again.',
      'settings_save_error':
          'Could not save this preference. Please try again.',
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
      'settings_title': 'सुगम्यता और भाषा',
      'settings_intro': 'भाषा बदलने से अनुवादित पाठ और सिस्टम नियंत्रण बदलते हैं। पाठ आकार और कंट्रास्ट पूरे ऐप पर लागू होते हैं। विकल्प इस डिवाइस पर सहेजे जाते हैं।',
      'language_label': 'भाषा',
      'language_english': 'अंग्रेज़ी',
      'language_hindi': 'हिन्दी',
      'language_marathi': 'मराठी',
      'accessibility_label': 'सुगम्यता',
      'high_contrast': 'उच्च कंट्रास्ट',
      'high_contrast_help': 'पाठ, बॉर्डर और फोकस संकेतों को अधिक स्पष्ट करें।',
      'text_size': 'पाठ का आकार',
      'text_size_help': 'यह आपके डिवाइस के पाठ आकार के साथ लागू होगा।',
      'small': 'छोटा',
      'large': 'बड़ा',
      'login_badge': 'बेहतर सामुदायिक सुरक्षा',
      'login_intro': 'सुरक्षित और स्वागतपूर्ण समुदाय की शुरुआत गेट से होती है। आगंतुकों का प्रबंधन करें और निवासियों को नियंत्रण दें।',
      'login_benefit_checkin': 'आगंतुकों का तेज़ और सरल प्रवेश',
      'login_benefit_approvals': 'निवासियों से तुरंत अनुमति',
      'login_benefit_passes': 'सुरक्षित पास और गेट गतिविधि',
      'login_mobile_description':
          'आगंतुक प्रबंधन, निवासी अनुमोदन और गेट सुरक्षा — सब एक ही जगह।',
      'login_continue': 'मोबाइल से जारी रखें',
      'login_legal': 'जारी रखकर, आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत होते हैं।',
      'login_caption_gate': 'हर गेट पर सहज स्वागत',
      'login_caption_approval': 'आगंतुक अनुरोधों का तुरंत प्रबंधन',
      'login_caption_pass': 'सत्यापित पास। आसान प्रवेश।',
      'login_caption_emergency': 'मदद हमेशा पास है',
      'login_headline_first': 'हर आगमन,',
      'login_headline_second': 'थोड़ा अधिक ',
      'login_headline_secure': 'सुरक्षित।',
      'language_picker': 'ऐप की भाषा चुनें',
      'accessibility_settings': 'सुगम्यता सेटिंग',
      'preferences_load_error': 'सहेजी गई सेटिंग लोड नहीं हो सकीं। स्टोरेज उपलब्ध होने तक बदलाव अस्थायी रहेंगे।',
      'dismiss': 'बंद करें',
      'auth_welcome': 'द्वारिवो में आपका स्वागत है',
      'auth_enter_code': 'कोड दर्ज करें',
      'auth_enter_phone': 'अपने पंजीकृत मोबाइल नंबर से साइन इन करें।',
      'auth_code_sent': '+91 पर भेजा गया 4 अंकों का कोड दर्ज करें: ',
      'auth_phone_label': 'मोबाइल नंबर',
      'auth_send_code': 'सत्यापन कोड भेजें',
      'auth_code_label': '4 अंकों का सत्यापन कोड',
      'auth_change_number': 'नंबर बदलें',
      'auth_verify': 'सत्यापित करें और साइन इन करें',
      'auth_demo_title': 'डेमो खाता देखें  ·  OTP: 1234',
      'auth_demo_resident': 'निवासी',
      'auth_demo_guard': 'गार्ड',
      'auth_demo_admin': 'एडमिन',
      'auth_demo_super_admin': 'सुपर एडमिन',
      'auth_phone_invalid': 'कृपया मान्य 10 अंकों का मोबाइल नंबर दर्ज करें',
      'auth_number_not_found':
          'सोसाइटी डेटाबेस में नंबर नहीं मिला। नए पंजीकरण के लिए OTP भेजा गया।',
      'auth_code_required': 'कृपया 4 अंकों का OTP दर्ज करें',
      'auth_code_invalid': 'गलत OTP। कृपया फिर से प्रयास करें।',
      'auth_sending': 'सत्यापन कोड भेजा जा रहा है',
      'auth_verifying': 'कोड सत्यापित हो रहा है',
      'auth_send_failed':
          'सत्यापन कोड नहीं भेजा जा सका। कृपया फिर से प्रयास करें।',
      'auth_verify_failed':
          'कोड सत्यापित नहीं हो सका। कृपया फिर से प्रयास करें।',
      'settings_save_error':
          'यह सेटिंग सहेजी नहीं जा सकी। कृपया फिर से प्रयास करें।',
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
      'settings_title': 'सुलभता आणि भाषा',
      'settings_intro': 'भाषा बदलल्याने अनुवादित मजकूर आणि सिस्टम नियंत्रणे बदलतात. मजकूराचा आकार आणि कॉन्ट्रास्ट संपूर्ण ॲपमध्ये लागू होतात. निवडी या डिव्हाइसवर जतन होतात.',
      'language_label': 'भाषा',
      'language_english': 'इंग्रजी',
      'language_hindi': 'हिंदी',
      'language_marathi': 'मराठी',
      'accessibility_label': 'सुलभता',
      'high_contrast': 'उच्च कॉन्ट्रास्ट',
      'high_contrast_help': 'मजकूर, सीमा आणि फोकस संकेत अधिक स्पष्ट करा.',
      'text_size': 'मजकूराचा आकार',
      'text_size_help': 'हे तुमच्या डिव्हाइसच्या मजकूर आकारासोबत लागू होईल.',
      'small': 'लहान',
      'large': 'मोठा',
      'login_badge': 'अधिक सुरक्षित समुदाय',
      'login_intro': 'सुरक्षित आणि स्वागतशील समुदायाची सुरुवात प्रवेशद्वारापासून होते. अभ्यागतांचे व्यवस्थापन करा आणि रहिवाशांना नियंत्रण द्या.',
      'login_benefit_checkin': 'अभ्यागतांची जलद आणि सोपी नोंद',
      'login_benefit_approvals': 'रहिवाशांकडून त्वरित मंजुरी',
      'login_benefit_passes': 'सुरक्षित पास आणि गेटवरील हालचाली',
      'login_mobile_description': 'अभ्यागत व्यवस्थापन, रहिवासी मंजुरी आणि गेट सुरक्षा — सर्व एका ठिकाणी.',
      'login_continue': 'मोबाइलने पुढे जा',
      'login_legal':
          'पुढे जाऊन, तुम्ही आमच्या सेवा अटी आणि गोपनीयता धोरणाशी सहमत होता.',
      'login_caption_gate': 'प्रत्येक गेटवर आपले स्वागत',
      'login_caption_approval': 'अभ्यागत विनंत्यांचे क्षणार्धात व्यवस्थापन',
      'login_caption_pass': 'सत्यापित पास. सहज प्रवेश.',
      'login_caption_emergency': 'मदत नेहमी जवळ आहे',
      'login_headline_first': 'प्रत्येक आगमन,',
      'login_headline_second': 'अधिक ',
      'login_headline_secure': 'सुरक्षित.',
      'language_picker': 'ॲपची भाषा निवडा',
      'accessibility_settings': 'सुलभता सेटिंग्ज',
      'preferences_load_error': 'जतन केलेल्या सेटिंग्ज लोड करता आल्या नाहीत. स्टोरेज उपलब्ध होईपर्यंत बदल तात्पुरते राहतील.',
      'dismiss': 'बंद करा',
      'auth_welcome': 'द्वारिवोमध्ये आपले स्वागत आहे',
      'auth_enter_code': 'कोड प्रविष्ट करा',
      'auth_enter_phone': 'नोंदणीकृत मोबाइल क्रमांकाने साइन इन करा.',
      'auth_code_sent': '+91 वर पाठवलेला 4 अंकी कोड प्रविष्ट करा: ',
      'auth_phone_label': 'मोबाइल क्रमांक',
      'auth_send_code': 'पडताळणी कोड पाठवा',
      'auth_code_label': '4 अंकी पडताळणी कोड',
      'auth_change_number': 'क्रमांक बदला',
      'auth_verify': 'पडताळणी करून साइन इन करा',
      'auth_demo_title': 'डेमो खाते पहा  ·  OTP: 1234',
      'auth_demo_resident': 'रहिवासी',
      'auth_demo_guard': 'सुरक्षा रक्षक',
      'auth_demo_admin': 'प्रशासक',
      'auth_demo_super_admin': 'मुख्य प्रशासक',
      'auth_phone_invalid': 'कृपया वैध 10 अंकी मोबाइल क्रमांक प्रविष्ट करा',
      'auth_number_not_found': 'सोसायटी डेटाबेसमध्ये क्रमांक सापडला नाही. नवीन नोंदणीसाठी OTP पाठवला.',
      'auth_code_required': 'कृपया 4 अंकी OTP प्रविष्ट करा',
      'auth_code_invalid': 'अवैध OTP. कृपया पुन्हा प्रयत्न करा.',
      'auth_sending': 'पडताळणी कोड पाठवत आहे',
      'auth_verifying': 'कोड पडताळत आहे',
      'auth_send_failed':
          'पडताळणी कोड पाठवता आला नाही. कृपया पुन्हा प्रयत्न करा.',
      'auth_verify_failed': 'कोड पडताळता आला नाही. कृपया पुन्हा प्रयत्न करा.',
      'settings_save_error':
          'ही सेटिंग जतन करता आली नाही. कृपया पुन्हा प्रयत्न करा.',
    },
  };

  String translate(String key) =>
      _translations[state]?[key] ?? _translations['EN']![key] ?? key;
}

class AccessibilitySettings {
  const AccessibilitySettings({
    required this.fontScale,
    required this.highContrast,
  });

  final double fontScale;
  final bool highContrast;

  AccessibilitySettings copyWith({double? fontScale, bool? highContrast}) {
    return AccessibilitySettings(
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
    );
  }
}

class AccessibilitySettingsNotifier extends Notifier<AccessibilitySettings> {
  @override
  AccessibilitySettings build() {
    final preferences = ref.watch(initialAppPreferencesProvider);
    return AccessibilitySettings(
      fontScale: preferences.fontScale,
      highContrast: preferences.highContrast,
    );
  }

  Future<void> setFontScale(double value) async {
    final next = state.copyWith(fontScale: value.clamp(0.9, 1.6).toDouble());
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setDouble(
      AppPreferencesData.fontScaleKey,
      next.fontScale,
    )) {
      throw StateError('Could not save the text size preference');
    }
    state = next;
  }

  Future<void> setHighContrast(bool value) async {
    final next = state.copyWith(highContrast: value);
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setBool(AppPreferencesData.highContrastKey, value)) {
      throw StateError('Could not save the contrast preference');
    }
    state = next;
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);
final accessibilityProvider =
    NotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
      AccessibilitySettingsNotifier.new,
    );
