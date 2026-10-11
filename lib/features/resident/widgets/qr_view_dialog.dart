import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/widgets/status_chip.dart';

class QrViewDialog extends StatefulWidget {
  final Visit visit;

  const QrViewDialog({super.key, required this.visit});

  @override
  State<QrViewDialog> createState() => _QrViewDialogState();
}

class _QrViewDialogState extends State<QrViewDialog> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareQrCode() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 2.0,
      );

      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/gatepass_${widget.visit.id}.png').create();
        await imagePath.writeAsBytes(image);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(imagePath.path)],
            text: 'Here is your security gate pass for ${widget.visit.wingName} - Flat ${widget.visit.flatNumber}. Show this QR at the gate.',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    // Display string for the time window validity
    String validTimeString = 'Unknown';
    if (widget.visit.validFrom != null && widget.visit.validUntil != null) {
      validTimeString = '${timeFormat.format(widget.visit.validFrom!)} to ${timeFormat.format(widget.visit.validUntil!)}';
    }

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The area that gets captured in the screenshot
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Theme.of(context).cardColor,
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
                              widget.visit.isPreApproved ? 'PRE-APPROVED PASS' : 'VISITOR ENTRY PASS',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              widget.visit.id,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        StatusChip.fromVisitStatus(widget.visit.status),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // High Contrast QR Code Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight, width: 2),
                      ),
                      child: QrImageView(
                        data: widget.visit.secureVisitToken,
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

                    // Validity and extra info for guards
                    if (widget.visit.isPreApproved)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.statusRejected.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.statusRejected.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'VALID ONLY BETWEEN',
                              style: TextStyle(fontSize: 10, color: AppColors.statusRejected, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              validTimeString,
                              style: const TextStyle(fontSize: 16, color: AppColors.statusRejected, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),

                    // Visitor Information Breakdown
                    _buildDetailRow(context, 'Visitor Name', widget.visit.visitorName),
                    _buildDetailRow(context, 'Destination Flat', '${widget.visit.flatNumber} (${widget.visit.wingName})'),
                    _buildDetailRow(context, 'Purpose', widget.visit.purpose.nameDisplay),
                    
                    // Conditionally show extra details if provided
                    if (widget.visit.expectedGuestCount != null && widget.visit.expectedGuestCount! > 1)
                      _buildDetailRow(context, 'Guest Count', '${widget.visit.expectedGuestCount} People', color: AppColors.primaryDark),
                    if (widget.visit.vehicleNumber != null && widget.visit.vehicleNumber!.isNotEmpty)
                      _buildDetailRow(context, 'Vehicle No.', widget.visit.vehicleNumber!, color: AppColors.primaryDark),
                    
                    if (!widget.visit.isPreApproved)
                      _buildDetailRow(context, 'Entry Recorded', dateFormat.format(widget.visit.entryTimestamp)),
                      
                  ],
                ),
              ),
            ),
            
            // Action Buttons (Not included in screenshot)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  const Divider(color: AppColors.borderLight, height: 1),
                  const SizedBox(height: 16),
                  
                  if (widget.visit.isPreApproved)
                    ElevatedButton.icon(
                      onPressed: _isSharing ? null : _shareQrCode,
                      icon: _isSharing 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.share, size: 18),
                      label: const Text('SHARE TICKET', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // WhatsApp Green-ish
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  
                  if (widget.visit.isPreApproved) const SizedBox(height: 12),
                  
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
