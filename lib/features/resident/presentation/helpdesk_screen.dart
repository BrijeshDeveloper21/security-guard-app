import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/theme/app_colors.dart';

class HelpdeskScreen extends ConsumerStatefulWidget {
  const HelpdeskScreen({super.key});

  @override
  ConsumerState<HelpdeskScreen> createState() => _HelpdeskScreenState();
}

class _HelpdeskScreenState extends ConsumerState<HelpdeskScreen> {
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _activeTickets = [
    {
      'id': 'TKT-1049',
      'title': 'Plumbing leak in guest bathroom',
      'category': 'Plumbing',
      'status': 'In Progress',
      'date': 'Today, 10:30 AM',
      'statusColor': Colors.blue,
    },
    {
      'id': 'TKT-1048',
      'title': 'Lobby AC not working',
      'category': 'Common Area',
      'status': 'Open',
      'date': 'Yesterday, 04:15 PM',
      'statusColor': AppColors.statusPending,
    },
  ];

  final List<Map<String, dynamic>> _resolvedTickets = [
    {
      'id': 'TKT-0932',
      'title': 'Intercom dead',
      'category': 'Electrical',
      'status': 'Resolved',
      'date': '12 Sep 2026',
      'statusColor': AppColors.statusApproved,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text('Helpdesk & Complaints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showNewTicketDialog(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('RAISE TICKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: _buildTab('ACTIVE (${_activeTickets.length})', 0)),
                Expanded(child: _buildTab('RESOLVED (${_resolvedTickets.length})', 1)),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _selectedTabIndex == 0
                  ? _activeTickets.map((t) => _buildTicketCard(
                        id: t['id'],
                        title: t['title'],
                        category: t['category'],
                        status: t['status'],
                        date: t['date'],
                        statusColor: t['statusColor'],
                      )).toList()
                  : _resolvedTickets.map((t) => _buildTicketCard(
                        id: t['id'],
                        title: t['title'],
                        category: t['category'],
                        status: t['status'],
                        date: t['date'],
                        statusColor: t['statusColor'],
                      )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Semantics(
      button: true,
      label: 'Tab $title',
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    ));
  }

  Widget _buildTicketCard({
    required String id,
    required String title,
    required String category,
    required String status,
    required String date,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(id, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 14, color: AppColors.textSecondaryDark),
                  const SizedBox(width: 4),
                  Text(category, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textSecondaryDark),
                  const SizedBox(width: 4),
                  Text(date, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNewTicketDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final catCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Raise New Ticket', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: catCtrl,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Issue Category',
                  labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                  prefixIcon: const Icon(Icons.category, color: AppColors.textSecondaryDark),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Describe the issue...',
                  labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty && catCtrl.text.isNotEmpty) {
                    setState(() {
                      _activeTickets.insert(0, {
                        'id': 'TKT-${1050 + _activeTickets.length}',
                        'title': titleCtrl.text,
                        'category': catCtrl.text,
                        'status': 'Open',
                        'date': 'Just Now',
                        'statusColor': AppColors.statusPending,
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket raised successfully!')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SUBMIT TICKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
