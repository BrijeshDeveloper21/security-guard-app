import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/core/theme/app_colors.dart';

class MaintenanceBillingScreen extends ConsumerStatefulWidget {
  const MaintenanceBillingScreen({super.key});

  @override
  ConsumerState<MaintenanceBillingScreen> createState() => _MaintenanceBillingScreenState();
}

class _MaintenanceBillingScreenState extends ConsumerState<MaintenanceBillingScreen> {
  bool _isPaid = false;

  void _processPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Processing Secure Payment...', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      setState(() => _isPaid = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!'), backgroundColor: AppColors.statusApproved),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final monthFormat = DateFormat('MMMM yyyy');

    final currentMonth = monthFormat.format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text('Maintenance & Bills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Due Amount Card (Premium Gradient)
            if (!_isPaid)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEA580C), Color(0xFF9A3412)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DUE FOR $currentMonth'.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Due in 5 Days', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormatter.format(4500),
                      style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text('Includes Common Area Maintenance & Water Charges', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF9A3412),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('PAY NOW SECURELY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.statusApproved, Color(0xFF065F46)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.statusApproved.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PAID FOR $currentMonth'.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Paid Today', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
                        SizedBox(width: 16),
                        Expanded(child: Text('All Clear!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Thank you for paying your maintenance on time.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Past Invoices
            const Text(
              'RECENT INVOICES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondaryDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildInvoiceTile('September 2026', 4500, true),
            _buildInvoiceTile('August 2026', 4500, true),
            _buildInvoiceTile('July 2026', 4500, true),
            _buildInvoiceTile('June 2026', 4200, true),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTile(String month, double amount, bool isPaid) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long_rounded, color: isPaid ? AppColors.statusApproved : AppColors.statusPending),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(isPaid ? 'Paid on time' : 'Pending', style: TextStyle(color: isPaid ? AppColors.textSecondaryDark : AppColors.statusPending, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currencyFormatter.format(amount), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(isPaid ? 'PAID' : 'DUE', style: TextStyle(color: isPaid ? AppColors.statusApproved : AppColors.statusPending, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(width: 4),
                  Icon(isPaid ? Icons.check_circle : Icons.error, size: 14, color: isPaid ? AppColors.statusApproved : AppColors.statusPending),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
