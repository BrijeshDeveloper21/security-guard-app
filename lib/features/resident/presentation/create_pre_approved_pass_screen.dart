import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/features/resident/widgets/qr_view_dialog.dart';

class CreatePreApprovedPassScreen extends ConsumerStatefulWidget {
  const CreatePreApprovedPassScreen({super.key});

  @override
  ConsumerState<CreatePreApprovedPassScreen> createState() =>
      _CreatePreApprovedPassScreenState();
}

class _CreatePreApprovedPassScreenState
    extends ConsumerState<CreatePreApprovedPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _guestCountController = TextEditingController(text: '1');

  DateTime _expectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  VisitorType _visitorType = VisitorType.guest;
  final VisitPurpose _purpose = VisitPurpose.meetingResident;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _guestCountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _expectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _generatePass() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    final tenant = ref.read(currentTenantProvider);

    if (user == null || tenant == null) return;

    setState(() => _isLoading = true);

    try {
      final residentService = ref.read(residentServiceProvider);
      final validFrom = DateTime(
        _expectedDate.year,
        _expectedDate.month,
        _expectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      
      final validUntil = DateTime(
        _expectedDate.year,
        _expectedDate.month,
        _expectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      if (validUntil.isBefore(validFrom)) {
        throw Exception("End time cannot be before start time.");
      }

      final pass = await residentService.createPreApprovedPass(
        tenantId: tenant.id,
        residentId: user.id,
        residentName: user.name,
        flatId: user.flatId ?? 'flat_b_1204',
        flatNumber: user.flatNumber ?? 'B-1204',
        wingName: user.wingName ?? 'Wing B',
        visitorName: _nameController.text.trim(),
        visitorPhone: _phoneController.text.trim(),
        visitorType: _visitorType,
        purpose: _purpose,
        validFrom: validFrom,
        validUntil: validUntil,
        guestCount: int.tryParse(_guestCountController.text) ?? 1,
        vehicleNumber: _vehicleController.text.trim().isNotEmpty ? _vehicleController.text.trim() : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (_) => QrViewDialog(visit: pass),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Pre-approved pass generated for ${pass.visitorName}! Share QR with guest.'),
          backgroundColor: AppColors.statusApproved,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating pass: $e'), backgroundColor: AppColors.statusRejected),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('CREATE PRE-APPROVED PASS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate an instant pass & QR code for your expected guest or delivery to skip guard interrogation at the gate.',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Guest Name
              Text('Guest / Visitor Name *', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'e.g. Rajesh Kumar',
                  prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 14),

              // Guest Mobile
              Text('Guest Mobile Number *', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'e.g. 9876543210',
                  prefixIcon: Icon(Icons.phone, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                validator: (val) => val == null || val.trim().length < 10 ? 'Enter valid 10-digit phone' : null,
              ),
              const SizedBox(height: 14),

              // Visitor Type
              Text('Visitor Category', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  VisitorType.guest,
                  VisitorType.delivery,
                  VisitorType.technician,
                  VisitorType.cab,
                  VisitorType.vendor,
                ].map((type) {
                  final isSel = _visitorType == type;
                  return ChoiceChip(
                    label: Text('${type.iconAsset} ${type.nameDisplay}'),
                    selected: isSel,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundColor: Theme.of(context).cardColor,
                    labelStyle: TextStyle(
                      color: isSel ? AppColors.primaryDark : AppColors.textSecondaryLight,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _visitorType = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Guests and Vehicle Number Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guest Count', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _guestCountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.group, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          validator: (val) => val == null || int.tryParse(val) == null || int.parse(val) < 1 ? 'Invalid' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle Number (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _vehicleController,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'MH-02-CB-1234',
                            prefixIcon: Icon(Icons.directions_car, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date & Time Slottings
              Text('Expected Arrival Date', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
              const SizedBox(height: 6),
              Semantics(
                button: true,
                label: 'Pick Date',
                child: InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateFormat.format(_expectedDate),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valid From Time', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                        const SizedBox(height: 6),
                        Semantics(
                          button: true,
                          label: 'Pick Start Time',
                          child: InkWell(
                            onTap: () => _pickTime(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                                boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: AppColors.statusApproved),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _startTime.format(context),
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('to', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valid Until Time', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                        const SizedBox(height: 6),
                        Semantics(
                          button: true,
                          label: 'Pick End Time',
                          child: InkWell(
                            onTap: () => _pickTime(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                                boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_filled, size: 16, color: AppColors.statusRejected),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _endTime.format(context),
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Security Warning: QR code scanner will reject the guest outside this selected time window.',
                style: TextStyle(fontSize: 11, color: AppColors.statusRejected, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generatePass,
                icon: _isLoading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface, strokeWidth: 2))
                    : const Icon(Icons.qr_code_2_rounded, size: 24),
                label: const Text(
                  'GENERATE VISITOR QR PASS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusApproved,
                  minimumSize: const Size(double.infinity, 54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
