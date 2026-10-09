import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';

class QrScannerDialog extends ConsumerStatefulWidget {
  const QrScannerDialog({super.key});

  @override
  ConsumerState<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends ConsumerState<QrScannerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _manualController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _processScannedCode(String code) {
    if (code.trim().isEmpty) return;
    final tenant = ref.read(currentTenantProvider);
    if (tenant == null) return;

    final visitorService = ref.read(visitorServiceProvider);
    final visit = visitorService.findActiveVisitByIdOrToken(
      tenantId: tenant.id,
      query: code.trim(),
    );

    if (visit != null) {
      Navigator.pop(context, visit);
    } else {
      setState(() {
        _errorMessage = 'No active visit found for token: "$code"';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final insideList = ref.watch(currentlyInsideListProvider);

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: AppColors.statusApproved, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Cross-Gate QR Scanner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animated Scanner Viewport
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Camera feed background simulation
                    Container(
                      color: const Color(0xFF0B1329),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.white.withValues(alpha: 0.15)),
                            const SizedBox(height: 8),
                            const Text(
                              'Center visitor QR pass in frame',
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Scanning Laser Animation
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Positioned(
                          top: 20 + (_animController.value * 170),
                          left: 30,
                          right: 30,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.statusApproved,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.statusApproved.withValues(alpha: 0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Targeting Frame Box
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.statusApproved, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.statusRejected.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.statusRejected),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.statusRejected, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.statusRejected, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Quick Scan Simulation buttons for active inside visitors
            if (insideList.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tap active visitor pass to simulate scan:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: insideList.map((visit) {
                  return ActionChip(
                    backgroundColor: AppColors.surfaceDark,
                    side: const BorderSide(color: AppColors.accent),
                    avatar: const Icon(Icons.qr_code, size: 16, color: AppColors.accent),
                    label: Text(
                      '${visit.visitorName} (${visit.flatNumber})',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _processScannedCode(visit.secureVisitToken),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // Manual Code Input option
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter Visit ID (e.g. VIS-2026-...)',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMutedDark),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.white70),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onSubmitted: _processScannedCode,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _processScannedCode(_manualController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(60, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('FIND'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
