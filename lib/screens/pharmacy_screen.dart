import 'dart:ui';
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
      appBar: _buildAppBar(
          provider.lowStockDrugs.length, provider.prescriptions.length),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInventory(context, provider),
          _buildPrescriptions(context, provider),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int lowStock, int rxCount) {
    return AppBar(
      title: const Text('Pharmacy Portal',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      backgroundColor: kBgLight.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: kPrimaryColor,
        unselectedLabelColor: kTextLight,
        indicatorColor: kPrimaryColor,
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
        tabs: [
          Tab(text: 'Drug Supply ${lowStock > 0 ? "($lowStock)" : ""}'),
          Tab(text: 'Prescriptions ($rxCount)'),
        ],
      ),
    );
  }

  Widget _buildInventory(BuildContext context, HMSProvider provider) {
    final drugs = provider.drugs;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        if (provider.lowStockDrugs.isNotEmpty)
          _buildLowStockBanner(provider.lowStockDrugs.length),
        ...drugs.map((drug) => _drugCard(drug)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildLowStockBanner(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDangerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: kDangerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: kDangerColor, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inventory Alert',
                    style: TextStyle(
                        color: kDangerColor.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text('$count medications require immediate restock.',
                    style: TextStyle(
                        color: kDangerColor.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: kDangerColor, size: 20),
        ],
      ),
    );
  }

  Widget _drugCard(Drug drug) {
    final isLow = drug.isLowStock;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
        border: isLow ? Border.all(color: kDangerColor.withOpacity(0.2)) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (isLow ? kDangerColor : kSuccessColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isLow ? Icons.error_outline_rounded : Icons.medication_rounded,
                color: isLow ? kDangerColor : kSuccessColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drug.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kTextDark)),
                  const SizedBox(height: 2),
                  Text(drug.category,
                      style: const TextStyle(
                          color: kTextLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  _expiryTag(drug.expiryDate),
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
                      fontSize: 16,
                      color: isLow ? kDangerColor : kPrimaryColor),
                ),
                Text(
                  'GHS ${drug.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: kTextMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _expiryTag(DateTime date) {
    final isNearExpiry = date.difference(DateTime.now()).inDays < 30;
    return Row(
      children: [
        Icon(Icons.event_available_rounded,
            size: 12, color: isNearExpiry ? kWarningColor : kTextLight),
        const SizedBox(width: 4),
        Text(
          'Exp: ${_formatDate(date)}',
          style: TextStyle(
              color: isNearExpiry ? kWarningColor : kTextLight,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPrescriptions(BuildContext context, HMSProvider provider) {
    final prescriptions = provider.prescriptions;
    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 60, color: kPrimaryColor.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('No Incoming Orders',
                style: TextStyle(
                    color: kTextLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: prescriptions.length,
      itemBuilder: (ctx, i) => _prescriptionCard(prescriptions[i]),
    );
  }

  Widget _prescriptionCard(Prescription rx) {
    Color statusColor;
    IconData statusIcon;
    switch (rx.status) {
      case PrescriptionStatus.dispensed:
        statusColor = kSuccessColor;
        statusIcon = Icons.verified_rounded;
        break;
      case PrescriptionStatus.cancelled:
        statusColor = kDangerColor;
        statusIcon = Icons.cancel_rounded;
        break;
      case PrescriptionStatus.partiallyDispensed:
        statusColor = kWarningColor;
        statusIcon = Icons.pending_rounded;
        break;
      default:
        statusColor = kInfoColor;
        statusIcon = Icons.hourglass_empty_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rx.patientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: kTextDark)),
                      Text('Dr. ${rx.doctorName}',
                          style:
                              const TextStyle(color: kTextLight, fontSize: 12)),
                    ],
                  ),
                ),
                _statusBadge(statusColor, statusIcon, rx.status.name),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(16),
            color: kBgLight.withOpacity(0.5),
            child: Column(
              children: rx.items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 14,
                                  color: kPrimaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${item.drugName} • ${item.dosage}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: kTextMedium),
                              ),
                            ),
                            Text(
                              '${item.frequency}',
                              style: const TextStyle(
                                  color: kTextLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ).copyWith(
                          bottom:
                              (rx.items.indexOf(item) == rx.items.length - 1)
                                  ? 0
                                  : 8))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

extension RxWidgetExtensions on Widget {
  Widget copyWith({double? bottom}) =>
      Padding(padding: EdgeInsets.only(bottom: bottom ?? 0), child: this);
}
