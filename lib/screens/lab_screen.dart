import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/models/lab_test.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();
    final tests = provider.labTests;

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: tests.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.biotech_rounded,
                              size: 80, color: kPrimaryColor.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          const Text('No Diagnostic Data',
                              style: TextStyle(
                                  color: kTextLight,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _testCard(
                          context, provider, tests[tests.length - 1 - i]),
                      childCount: tests.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOrderDialog(context, provider),
        backgroundColor: kWarningColor,
        icon: const Icon(Icons.add_to_home_screen_rounded, color: Colors.white),
        label: const Text('Order Diagnostic',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: kWarningColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Lab Diagnostics',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 18)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kWarningColor, kWarningColor.withBlue(150)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _testCard(BuildContext context, HMSProvider provider, LabTest test) {
    Color statusColor;
    IconData statusIcon;
    switch (test.status) {
      case LabTestStatus.completed:
        statusColor = kSuccessColor;
        statusIcon = Icons.verified_user_rounded;
        break;
      case LabTestStatus.inProgress:
        statusColor = kInfoColor;
        statusIcon = Icons.query_stats_rounded;
        break;
      default:
        statusColor = kWarningColor;
        statusIcon = Icons.hourglass_top_rounded;
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(test.testName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: kTextDark)),
                      Text(test.patientName,
                          style: const TextStyle(
                              color: kTextLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                _statusBadge(statusColor, test.status.name),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _infoRow(
                        Icons.person_pin_rounded, 'By: Dr. ${test.orderedBy}'),
                    const Spacer(),
                    _infoRow(Icons.calendar_month_rounded,
                        _formatDate(test.orderedAt)),
                  ],
                ),
                if (test.result != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSuccessColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kSuccessColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assessment_rounded,
                                color: kSuccessColor, size: 16),
                            SizedBox(width: 8),
                            Text('Diagnostic Result',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: kSuccessColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(test.result!,
                            style: const TextStyle(
                                fontSize: 14, height: 1.5, color: kTextMedium)),
                      ],
                    ),
                  ),
                ],
                if (test.status != LabTestStatus.completed) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showResultDialog(context, provider, test.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kWarningColor.withOpacity(0.1),
                        foregroundColor: kWarningColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Upload Scientific Data',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kTextLight),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: kTextLight, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showResultDialog(
      BuildContext context, HMSProvider provider, String testId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: kBgWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Enter Test Findings',
              style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Detailed scientific observations...',
              filled: true,
              fillColor: kBgLight,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:
                    const Text('Cancel', style: TextStyle(color: kTextLight))),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.isNotEmpty) {
                  provider.updateLabTestResult(testId, ctrl.text.trim());
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: kWarningColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Release Result',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDialog(BuildContext context, HMSProvider provider) {
    final patientCtrl = TextEditingController();
    final testCtrl = TextEditingController();
    String doctor = provider.doctors.first.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: kBgWhite,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Diagnostic Order',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 24),
                _inputField(
                    'Patient Identity', patientCtrl, Icons.fingerprint_rounded),
                const SizedBox(height: 16),
                _inputField(
                    'Test/Procedure Name', testCtrl, Icons.biotech_rounded),
                const SizedBox(height: 16),
                _dropdownField(
                    'Ordering Medical Officer',
                    doctor,
                    provider.doctors.map((d) => d.name).toList(),
                    (v) => setModalState(() => doctor = v!)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (patientCtrl.text.isEmpty || testCtrl.text.isEmpty)
                        return;
                      final tests = provider.labTests;
                      final id =
                          'L${(tests.length + 1).toString().padLeft(3, '0')}';
                      provider.addLabTest(LabTest(
                        id: id,
                        patientId: 'WALK',
                        patientName: patientCtrl.text.trim(),
                        testName: testCtrl.text.trim(),
                        orderedBy: doctor,
                        orderedAt: DateTime.now(),
                        status: LabTestStatus.pending,
                      ));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kWarningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm Diagnostic Order',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: kWarningColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _dropdownField(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.medical_services_rounded,
            size: 20, color: kWarningColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
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
