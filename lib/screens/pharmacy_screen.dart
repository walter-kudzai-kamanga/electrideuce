import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/models/pharmacy.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: const Text('Pharmacy'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor,
          unselectedLabelColor: kTextLight,
          indicatorColor: kPrimaryColor,
          tabs: const [
            Tab(text: 'Drug Inventory'),
            Tab(text: 'Prescriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInventory(context, provider),
          _buildPrescriptions(context, provider),
        ],
      ),
    );
  }

  Widget _buildInventory(BuildContext context, HMSProvider provider) {
    final drugs = provider.drugs;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Low stock alert
        if (provider.lowStockDrugs.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWarningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(kBorderRadius),
              border: Border.all(color: kWarningColor.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: kWarningColor),
                const SizedBox(width: 10),
                Text(
                  '${provider.lowStockDrugs.length} drug(s) running low',
                  style: const TextStyle(color: kWarningColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ...drugs.map((drug) => _drugCard(drug)),
      ],
    );
  }

  Widget _drugCard(Drug drug) {
    final isLow = drug.isLowStock;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
        border: isLow ? Border.all(color: kWarningColor.withOpacity(0.4)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kSuccessColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_rounded, color: kSuccessColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drug.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(drug.category,
                    style: const TextStyle(color: kTextLight, fontSize: 12)),
                Text('Expires: ${_formatDate(drug.expiryDate)}',
                    style: const TextStyle(color: kTextLight, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${drug.quantity} ${drug.unit}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isLow ? kDangerColor : kTextDark,
                ),
              ),
              Text(
                'GHS ${drug.price.toStringAsFixed(2)}',
                style: const TextStyle(color: kTextLight, fontSize: 12),
              ),
              if (isLow)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: kDangerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('LOW STOCK',
                      style: TextStyle(color: kDangerColor, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptions(BuildContext context, HMSProvider provider) {
    final prescriptions = provider.prescriptions;
    if (prescriptions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: kTextLight),
            SizedBox(height: 12),
            Text('No prescriptions yet', style: TextStyle(color: kTextLight)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prescriptions.length,
      itemBuilder: (ctx, i) => _prescriptionCard(prescriptions[i]),
    );
  }

  Widget _prescriptionCard(Prescription rx) {
    Color statusColor;
    switch (rx.status) {
      case PrescriptionStatus.dispensed:
        statusColor = kSuccessColor;
        break;
      case PrescriptionStatus.cancelled:
        statusColor = kDangerColor;
        break;
      case PrescriptionStatus.partiallyDispensed:
        statusColor = kWarningColor;
        break;
      default:
        statusColor = kInfoColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rx.patientName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(rx.status.name,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Text('Prescribed by: ${rx.doctorName}',
              style: const TextStyle(color: kTextLight, fontSize: 12)),
          const Divider(height: 16),
          ...rx.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: kPrimaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.drugName} - ${item.dosage} ${item.frequency} x${item.duration} days',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
