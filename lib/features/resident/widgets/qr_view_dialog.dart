import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/widgets/status_chip.dart';

class QrViewDialog extends StatelessWidget {
  final Visit visit;

  const QrViewDialog({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.isPreApproved ? 'PRE-APPROVED PASS' : 'VISITOR ENTRY PASS',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      visit.id,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                StatusChip.fromVisitStatus(visit.status),
              ],
            ),
            const SizedBox(height: 20),

            // High Contrast QR Code Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: QrImageView(
                data: visit.secureVisitToken,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF0F172A),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Token security disclaimer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: AppColors.statusApproved),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Encrypted token • No private resident data stored in QR code',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Visitor Information Breakdown
            _buildDetailRow('Visitor Name', visit.visitorName),
            _buildDetailRow('Destination Flat', '${visit.flatNumber} (${visit.wingName})'),
            _buildDetailRow('Purpose', visit.purpose.nameDisplay),
            _buildDetailRow('Entry Gate', visit.entryGateName),
            _buildDetailRow('Entry Recorded', dateFormat.format(visit.entryTimestamp)),
            if (visit.exitTimestamp != null)
              _buildDetailRow(
                'Exit Recorded',
                '${dateFormat.format(visit.exitTimestamp!)} (${visit.exitGateName ?? "Gate"})',
                color: AppColors.statusExited,
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('CLOSE PASS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
