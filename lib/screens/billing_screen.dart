import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/models/billing.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();
    final bills = provider.bills;

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: const Text('Billing & Payments'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Today\'s Revenue', style: TextStyle(fontSize: 10, color: kTextLight)),
                Text(
                  'GHS ${provider.todayRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(color: kSuccessColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBillDialog(context, provider),
        backgroundColor: kDangerColor,
        icon: const Icon(Icons.add),
        label: const Text('New Bill'),
      ),
      body: bills.isEmpty
          ? const Center(child: Text('No bills yet', style: TextStyle(color: kTextLight)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bills.length,
              itemBuilder: (ctx, i) => _billCard(context, bills[i]),
            ),
    );
  }

  Widget _billCard(BuildContext context, Bill bill) {
    Color statusColor;
    switch (bill.status) {
      case BillStatus.paid:
        statusColor = kSuccessColor;
        break;
      case BillStatus.cancelled:
        statusColor = kDangerColor;
        break;
      case BillStatus.partiallyPaid:
        statusColor = kWarningColor;
        break;
      default:
        statusColor = kInfoColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bill.patientName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Bill #${bill.id} • ${_formatDate(bill.issuedAt)}',
                            style: const TextStyle(color: kTextLight, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(bill.status.name,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
                const Divider(height: 16),
                ...bill.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      _itemTypeIcon(item.type),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.description, style: const TextStyle(fontSize: 13))),
                      Text('GHS ${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    ],
                  ),
                )),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      'GHS ${bill.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (bill.status == BillStatus.pending)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: kBorderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showPaymentDialog(context, bill),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Pay Cash'),
                      style: TextButton.styleFrom(foregroundColor: kSuccessColor),
                    ),
                  ),
                  Container(width: 1, height: 40, color: kBorderColor),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.health_and_safety, size: 16),
                      label: const Text('Insurance'),
                      style: TextButton.styleFrom(foregroundColor: kInfoColor),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _itemTypeIcon(BillItemType type) {
    IconData icon;
    Color color;
    switch (type) {
      case BillItemType.consultation:
        icon = Icons.medical_services;
        color = kPrimaryColor;
        break;
      case BillItemType.labTest:
        icon = Icons.science;
        color = kWarningColor;
        break;
      case BillItemType.medication:
        icon = Icons.medication;
        color = kSuccessColor;
        break;
      case BillItemType.procedure:
        icon = Icons.healing;
        color = kInfoColor;
        break;
      default:
        icon = Icons.receipt;
        color = kTextLight;
    }
    return Icon(icon, size: 14, color: color);
  }

  void _showPaymentDialog(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Mark GHS ${bill.totalAmount.toStringAsFixed(2)} as paid for ${bill.patientName}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              bill.status = BillStatus.paid;
              bill.paymentMethod = PaymentMethod.cash;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment of GHS ${bill.totalAmount.toStringAsFixed(2)} received!'),
                  backgroundColor: kSuccessColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kSuccessColor),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCreateBillDialog(BuildContext context, HMSProvider provider) {
    final patientCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create New Bill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: patientCtrl, decoration: const InputDecoration(labelText: 'Patient Name')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (patientCtrl.text.isEmpty) return;
                  final bills = provider.bills;
                  final id = 'B${(bills.length + 1).toString().padLeft(3, '0')}';
                  provider.addBill(Bill(
                    id: id,
                    patientId: 'WALK',
                    patientName: patientCtrl.text.trim(),
                    items: [
                      BillItem(description: 'Consultation Fee', type: BillItemType.consultation, amount: 50.0),
                    ],
                    totalAmount: 50.0,
                    issuedAt: DateTime.now(),
                  ));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bill created!'), backgroundColor: kSuccessColor),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: kDangerColor),
                child: const Text('Create Bill'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
