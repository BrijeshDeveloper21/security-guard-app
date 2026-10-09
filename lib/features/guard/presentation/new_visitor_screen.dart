import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/resident/models/flat.dart';
import 'package:security_app/features/guard/models/gate.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/widgets/camera_capture_dialog.dart';
import 'package:security_app/features/resident/widgets/qr_view_dialog.dart';

class NewVisitorScreen extends ConsumerStatefulWidget {
  final bool isDeliveryOnly;

  const NewVisitorScreen({super.key, this.isDeliveryOnly = false});

  @override
  ConsumerState<NewVisitorScreen> createState() => _NewVisitorScreenState();
}

class _NewVisitorScreenState extends ConsumerState<NewVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  String? _capturedPhotoUrl;
  Flat? _selectedFlat;
  Gate? _selectedEntryGate;
  VisitorType _selectedVisitorType = VisitorType.guest;
  VisitPurpose _selectedPurpose = VisitPurpose.meetingResident;
  String? _repeatVisitorBadge;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isDeliveryOnly) {
      _selectedVisitorType = VisitorType.delivery;
      _selectedPurpose = VisitPurpose.delivery;
    }
    // Default entry gate to active gate
    _selectedEntryGate = ref.read(activeGateProvider);

    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _nameController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.trim();
    if (text.length >= 10) {
      final tenant = ref.read(currentTenantProvider);
      if (tenant != null) {
        final visitorService = ref.read(visitorServiceProvider);
        final repeat = visitorService.findRepeatVisitor(
          tenantId: tenant.id,
          phone: text,
        );

        if (repeat != null && mounted) {
          setState(() {
            if (_nameController.text.isEmpty) {
              _nameController.text = repeat.name;
            }
            if (_vehicleController.text.isEmpty && repeat.vehicleNumber != null) {
              _vehicleController.text = repeat.vehicleNumber!;
            }
            if (_capturedPhotoUrl == null && repeat.photoUrl != null) {
              _capturedPhotoUrl = repeat.photoUrl;
            }
            _selectedVisitorType = repeat.visitorType;
            _repeatVisitorBadge =
                'Repeat Visitor • ${repeat.totalVisits} previous visits • Last flat: ${repeat.lastVisitedFlat ?? "N/A"}';
          });
        }
      }
    } else {
      if (_repeatVisitorBadge != null) {
        setState(() => _repeatVisitorBadge = null);
      }
    }
  }

  Future<void> _openCamera() async {
    final capturedUrl = await showDialog<String>(
      context: context,
      builder: (_) => const CameraCaptureDialog(),
    );

    if (capturedUrl != null && mounted) {
      setState(() {
        _capturedPhotoUrl = capturedUrl;
      });
    }
  }

  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final tenant = ref.read(currentTenantProvider);
    final user = ref.read(currentUserProvider);
    final gate = _selectedEntryGate ?? ref.read(activeGateProvider);

    if (tenant == null || user == null || gate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session or Gate information is missing')),
      );
      return;
    }

    if (_selectedFlat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the destination flat')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final visitorService = ref.read(visitorServiceProvider);
      final newVisit = await visitorService.recordNewEntry(
        tenantId: tenant.id,
        visitorName: _nameController.text.trim(),
        visitorPhone: _phoneController.text.trim(),
        visitorPhotoUrl: _capturedPhotoUrl,
        flatId: _selectedFlat!.id,
        flatNumber: _selectedFlat!.flatNumber,
        wingName: _selectedFlat!.wingName,
        visitorType: _selectedVisitorType,
        purpose: _selectedPurpose,
        vehicleNumber: _vehicleController.text.trim().isNotEmpty
            ? _vehicleController.text.trim().toUpperCase()
            : null,
        entryGateId: gate.id,
        entryGateName: gate.name,
        entryGuardId: user.id,
        entryGuardName: user.name,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Pop current form
      Navigator.pop(context);

      // Display newly generated QR Pass
      showDialog(
        context: context,
        builder: (_) => QrViewDialog(visit: newVisit),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Entry recorded! ${newVisit.visitorName} admitted via ${gate.name}',
          ),
          backgroundColor: AppColors.statusApproved,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording entry: $e'), backgroundColor: AppColors.statusRejected),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(currentTenantProvider);
    final flats = tenant != null ? ref.watch(societyServiceProvider).getFlats(tenant.id) : <Flat>[];
    final gates = tenant != null
        ? ref.watch(gateServiceProvider).getGates(tenant.id, activeOnly: true)
        : <Gate>[];

    final autoTime = DateFormat('hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          widget.isDeliveryOnly ? 'DELIVERY ENTRY' : 'NEW VISITOR ENTRY',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Mandatory Photo Capture Box
              Center(
                child: Column(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Take Photo',
                      child: InkWell(
                        onTap: _openCamera,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _capturedPhotoUrl != null
                                ? AppColors.statusApproved
                                : AppColors.accent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _capturedPhotoUrl != null
                              ? Image.network(
                                  _capturedPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      Icon(Icons.person, size: 70, color: Theme.of(context).colorScheme.onSurface),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.accent),
                                    const SizedBox(height: 6),
                                    Text(
                                      'TAKE PHOTO',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 8),
                    Semantics(
                      button: true,
                      label: 'Retake Photo',
                      child: TextButton.icon(
                        onPressed: _openCamera,
                      icon: Icon(
                        _capturedPhotoUrl != null ? Icons.refresh_rounded : Icons.photo_camera,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      label: Text(
                        _capturedPhotoUrl != null ? 'Retake Photo' : 'Capture Visitor Photograph',
                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Repeat visitor alert notification if recognized
              if (_repeatVisitorBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _repeatVisitorBadge!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 2. Mobile Number (Quick Lookup)
              Text('Mobile Number *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'e.g. 9876543210',
                  prefixIcon: Icon(Icons.phone_android, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter mobile number';
                  if (val.trim().length < 10) return 'Enter valid 10-digit mobile number';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 3. Visitor Name
              Text('Visitor Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. Rajesh Kumar',
                  prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter visitor name' : null,
              ),
              const SizedBox(height: 14),

              // 4. Flat Selection Dropdown
              Text('Destination Flat *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 6),
              DropdownButtonFormField<Flat>(
                initialValue: _selectedFlat,
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.apartment_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  hintText: 'Select flat number',
                ),
                items: flats.map((f) {
                  return DropdownMenuItem<Flat>(
                    value: f,
                    child: Text(
                      '${f.flatNumber} (${f.wingName}) - ${f.residentName ?? "Occupant"}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedFlat = val),
                validator: (val) => val == null ? 'Select flat' : null,
              ),
              const SizedBox(height: 14),

              // 5. Visitor Type Chips
              Text('Visitor Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: VisitorType.values.map((type) {
                  final isSelected = _selectedVisitorType == type;
                  return ChoiceChip(
                    label: Text('${type.iconAsset} ${type.nameDisplay}'),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Theme.of(context).cardColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedVisitorType = type;
                          if (type == VisitorType.delivery) _selectedPurpose = VisitPurpose.delivery;
                          if (type == VisitorType.cab) _selectedPurpose = VisitPurpose.cabPickupDrop;
                          if (type == VisitorType.technician) _selectedPurpose = VisitPurpose.repair;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // 6. Purpose Dropdown
              Text('Purpose of Visit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 6),
              DropdownButtonFormField<VisitPurpose>(
                initialValue: _selectedPurpose,
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.assignment_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                items: VisitPurpose.values.map((p) {
                  return DropdownMenuItem<VisitPurpose>(
                    value: p,
                    child: Text(p.nameDisplay, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPurpose = val);
                },
              ),
              const SizedBox(height: 14),

              // 7. Optional Vehicle Number
              Text('Vehicle Number (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _vehicleController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. MH-02-CB-1234',
                  prefixIcon: Icon(Icons.directions_car_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 14),

              // 8. Gate and Automatic Timestamp banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Entry Gate:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<Gate>(
                            value: _selectedEntryGate,
                            dropdownColor: Theme.of(context).cardColor,
                            items: gates.map((g) {
                              return DropdownMenuItem<Gate>(
                                value: g,
                                child: Text(g.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedEntryGate = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderLight, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Entry Timestamp:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                        Text(
                          '$autoTime (Automatic)',
                          style: const TextStyle(color: AppColors.statusApproved, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Large Confirm Entry Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitEntry,
                icon: _isLoading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface, strokeWidth: 2))
                    : const Icon(Icons.check_circle_rounded, size: 24),
                label: const Text(
                  'CONFIRM ENTRY (10-15s FLOW)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusApproved,
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
