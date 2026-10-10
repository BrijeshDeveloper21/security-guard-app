import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:security_app/core/theme/app_colors.dart';

class CameraCaptureDialog extends StatefulWidget {
  const CameraCaptureDialog({super.key});

  @override
  State<CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<CameraCaptureDialog> {
  bool _isCaptured = false;
  XFile? _capturedImageFile;

  // Function to open the real system camera using image_picker
  Future<void> _openSystemCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      // This will trigger the native camera on mobile devices and webcam on Web
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        setState(() {
          _capturedImageFile = photo;
          _isCaptured = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
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
                Row(
                  children: [
                    const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Capture Visitor Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                  color: _isCaptured ? AppColors.statusApproved : AppColors.primary,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isCaptured && _capturedImageFile != null)
                      // Use Image.network for web compatibility (even with local paths XFile returns)
                      // Use Image.file for native devices
                      kIsWeb() 
                        ? Image.network(
                            _capturedImageFile!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file(
                            File(_capturedImageFile!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                    else ...[
                      // Realistic Simulated Camera Viewfinder before taking the real picture
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
                                'Tap Snap Photo to open Camera',
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
                              top: BorderSide(color: AppColors.primary, width: 3),
                              left: BorderSide(color: AppColors.primary, width: 3),
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
                              top: BorderSide(color: AppColors.primary, width: 3),
                              right: BorderSide(color: AppColors.primary, width: 3),
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
                onPressed: _openSystemCamera,
                icon: const Icon(Icons.camera, size: 24),
                label: const Text(
                  'SNAP PHOTO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openSystemCamera, // Opens real camera again
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('RETAKE'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        minimumSize: const Size(0, 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Return the actual file path to the parent screen
                        Navigator.pop(context, _capturedImageFile!.path);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('CONFIRM'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusApproved,
                        foregroundColor: Colors.white,
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

  // Simple web check helper since we didn't import flutter/foundation.dart
  bool kIsWeb() {
    return const bool.fromEnvironment('dart.library.js_util');
  }
}

class Box320Constraint extends BoxConstraints {
  const Box320Constraint() : super(maxWidth: 420);
}
