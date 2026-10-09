import 'package:flutter/material.dart';
import 'package:security_app/core/theme/app_colors.dart';

class CameraCaptureDialog extends StatefulWidget {
  const CameraCaptureDialog({super.key});

  @override
  State<CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<CameraCaptureDialog> {
  bool _isCaptured = false;
  String? _capturedPhotoPlaceholder;

  final List<String> _sampleAvatars = [
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&fit=crop&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&fit=crop&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&fit=crop&q=80',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300&fit=crop&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const Box320Constraint(),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.camera_alt_rounded, color: AppColors.accent, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Capture Visitor Photo',
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

            // Camera Viewfinder / Preview
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isCaptured ? AppColors.statusApproved : AppColors.accent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isCaptured)
                      Image.network(
                        _capturedPhotoPlaceholder ?? _sampleAvatars[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Icon(Icons.person, size: 100, color: Colors.white60),
                        ),
                      )
                    else ...[
                      // Realistic Simulated Camera Viewfinder
                      Container(
                        color: const Color(0xFF111827),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 160,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 1.5,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(80),
                                ),
                                child: const Icon(
                                  Icons.face_retouching_natural_rounded,
                                  size: 64,
                                  color: Colors.white30,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Align visitor face in oval',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Crosshair Corners
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.accent, width: 3),
                              left: BorderSide(color: AppColors.accent, width: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.accent, width: 3),
                              right: BorderSide(color: AppColors.accent, width: 3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Controls
            if (!_isCaptured)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isCaptured = true;
                    _capturedPhotoPlaceholder =
                        _sampleAvatars[DateTime.now().second % _sampleAvatars.length];
                  });
                },
                icon: const Icon(Icons.camera, size: 24),
                label: const Text(
                  'SNAP PHOTO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCaptured = false;
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('RETAKE'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        minimumSize: const Size(0, 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, _capturedPhotoPlaceholder);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('CONFIRM'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusApproved,
                        minimumSize: const Size(0, 50),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class Box320Constraint extends BoxConstraints {
  const Box320Constraint() : super(maxWidth: 420);
}
