import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/widgets/status_chip.dart';

class VisitorDetailScreen extends ConsumerStatefulWidget {
  final Visit visit;

  const VisitorDetailScreen({super.key, required this.visit});

  @override
  ConsumerState<VisitorDetailScreen> createState() => _VisitorDetailScreenState();
}

class _VisitorDetailScreenState extends ConsumerState<VisitorDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _vehicleCtrl;
  
  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.visit.visitorName);
    _phoneCtrl = TextEditingController(text: widget.visit.visitorPhone);
    _vehicleCtrl = TextEditingController(text: widget.visit.vehicleNumber ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _vehicleCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // In a real app we would call a service method to update the database
    // For now we simulate success
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visitor details updated successfully!'), backgroundColor: AppColors.statusApproved),
    );
  }

  void _deleteVisitor() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Delete Visitor Record?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this record? This action cannot be undone and will be logged in the audit trail.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(visitorServiceProvider).deleteVisit(widget.visit.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visitor record deleted.'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Visitor Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              tooltip: 'Edit Visitor',
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.statusApproved),
              tooltip: 'Save Changes',
              onPressed: _saveChanges,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete Record',
            onPressed: _deleteVisitor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage: widget.visit.visitorPhotoUrl != null ? NetworkImage(widget.visit.visitorPhotoUrl!) : null,
                    child: widget.visit.visitorPhotoUrl == null ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
                    TextField(
                      controller: _nameCtrl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      decoration: const InputDecoration(border: UnderlineInputBorder()),
                    )
                  else
                    Text(
                      _nameCtrl.text,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  const SizedBox(height: 8),
                  StatusChip.fromVisitStatus(widget.visit.status),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VISIT INFORMATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const Divider(height: 24),
                  
                  _buildDetailRow('Visit ID', widget.visit.id),
                  _buildDetailRow('Destination Flat', '${widget.visit.flatNumber} (${widget.visit.wingName})'),
                  _buildDetailRow('Category', widget.visit.visitorType.nameDisplay),
                  _buildDetailRow('Purpose', widget.visit.purpose.nameDisplay),
                  
                  const SizedBox(height: 16),
                  Text('CONTACT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const Divider(height: 24),
                  
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                      ),
                    )
                  else
                    _buildDetailRow('Mobile Number', _phoneCtrl.text),
                    
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: _vehicleCtrl,
                        decoration: const InputDecoration(labelText: 'Vehicle Number', border: OutlineInputBorder()),
                      ),
                    )
                  else if (_vehicleCtrl.text.isNotEmpty)
                    _buildDetailRow('Vehicle', _vehicleCtrl.text),

                  const SizedBox(height: 16),
                  Text('TIMESTAMPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const Divider(height: 24),
                  
                  _buildDetailRow('Entered', dateFormat.format(widget.visit.entryTimestamp)),
                  _buildDetailRow('Entry Gate', widget.visit.entryGateName),
                  if (widget.visit.exitTimestamp != null) ...[
                    _buildDetailRow('Exited', dateFormat.format(widget.visit.exitTimestamp!)),
                    _buildDetailRow('Exit Gate', widget.visit.exitGateName ?? 'Unknown'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
