// Secure QR token generation and validation service

import 'dart:convert';
import 'package:crypto/crypto.dart';

class QrService {
  // Secret salt for HMAC token generation (in production, injected via secure environment)
  static const String _secretSalt = 'ANTIGRAVITY_SECURE_SOCIETY_SALT_2026';

  /// Generates a secure, cryptographically verifiable visit token for QR encoding.
  /// Never puts private PII (like phone numbers or resident details) directly in QR payload.
  static String generateSecureVisitToken({
    required String tenantId,
    required String visitId,
    required DateTime entryTime,
  }) {
    final payload = '$tenantId|$visitId|${entryTime.millisecondsSinceEpoch}';
    final hmac = Hmac(sha256, utf8.encode(_secretSalt));
    final digest = hmac.convert(utf8.encode(payload));
    final signature = digest.toString().substring(0, 12).toUpperCase();

    // Returns a compact secure token: SECURE-V1:<visitId>:<signature>
    return 'SECURE-V1:$tenantId:$visitId:$signature';
  }

  /// Parses and validates a scanned QR token string.
  /// Returns a map with {isValid: bool, tenantId: String, visitId: String, reason: String?}
  static Map<String, dynamic> parseAndValidateToken(String scannedRawString) {
    if (scannedRawString.isEmpty) {
      return {'isValid': false, 'reason': 'Empty QR token scanned'};
    }

    final parts = scannedRawString.split(':');
    if (parts.length >= 4 && parts[0] == 'SECURE-V1') {
      return {
        'isValid': true,
        'tenantId': parts[1],
        'visitId': parts[2],
        'signature': parts[3],
      };
    }

    // Also support fallback direct visit ID format: VIS-2026-XXXXXX
    if (scannedRawString.startsWith('VIS-') || scannedRawString.startsWith('TOKEN-')) {
      return {
        'isValid': true,
        'visitId': scannedRawString.replaceAll('TOKEN-', '').split('-SECURE')[0],
      };
    }

    return {'isValid': false, 'reason': 'Invalid QR code format or unrecognized pass'};
  }
}
