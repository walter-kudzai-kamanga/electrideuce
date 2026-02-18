import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();
    final tests = provider.labTests;

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(title: const Text('Lab Tests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOrderDialog(context, provider),
        backgroundColor: kWarningColor,
        icon: const Icon(Icons.add),
        label: const Text('Order Test'),
      ),
      body: tests.isEmpty
          ? const Center(child: Text('No lab tests ordered', style: TextStyle(color: kTextLight)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tests.length,
              itemBuilder: (ctx, i) => _testCard(context, provider, tests[i]),
            ),
    );
  }

  Widget _testCard(BuildContext context, HMSProvider provider, test) {
    Color statusColor;
    IconData statusIcon;
    switch (test.status.name) {
      case 'completed':
        statusColor = kSuccessColor;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'inProgress':
        statusColor = kInfoColor;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      default:
        statusColor = kWarningColor;
        statusIcon = Icons.pending_rounded;
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kWarningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.science_rounded, color: kWarningColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(test.testName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(test.patientName,
                        style: const TextStyle(color: kTextLight, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  Text(test.status.name,
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ordered by: ${test.orderedBy}',
              style: const TextStyle(color: kTextLight, fontSize: 12)),
          Text('Ordered: ${_formatDate(test.orderedAt)}',
              style: const TextStyle(color: kTextLight, fontSize: 12)),
          if (test.result != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kSuccessColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kSuccessColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Results:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: kSuccessColor)),
                  const SizedBox(height: 4),
                  Text(test.result!, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
          if (test.status.name == 'pending' || test.status.name == 'inProgress') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showResultDialog(context, provider, test.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kWarningColor,
                  side: const BorderSide(color: kWarningColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Upload Result', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, HMSProvider provider, String testId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Lab Result'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter test results here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                provider.updateLabTestResult(testId, ctrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Result uploaded!'), backgroundColor: kSuccessColor),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kWarningColor),
            child: const Text('Upload'),
          ),
        ],
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Lab Test', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: patientCtrl, decoration: const InputDecoration(labelText: 'Patient Name')),
              const SizedBox(height: 12),
              TextField(controller: testCtrl, decoration: const InputDecoration(labelText: 'Test Name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: doctor,
                decoration: const InputDecoration(labelText: 'Ordering Doctor'),
                items: provider.doctors.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                onChanged: (v) => setModalState(() => doctor = v!),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (patientCtrl.text.isEmpty || testCtrl.text.isEmpty) return;
                    final tests = provider.labTests;
                    final id = 'L${(tests.length + 1).toString().padLeft(3, '0')}';
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lab test ordered!'), backgroundColor: kSuccessColor),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kWarningColor),
                  child: const Text('Order Test'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
