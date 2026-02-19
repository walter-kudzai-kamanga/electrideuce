import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/models/lab_test.dart';
import 'package:medisync_hms/models/appointment.dart';
import 'package:medisync_hms/models/patient.dart';
import 'package:medisync_hms/models/pharmacy.dart';
import 'package:medisync_hms/models/billing.dart';

class ConsultationScreen extends StatefulWidget {
  final Appointment appointment;
  const ConsultationScreen({super.key, required this.appointment});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _symptomsCtrl = TextEditingController();
  final _findingsCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final List<PrescriptionItem> _prescribedItems = [];
  final List<String> _orderedLabs = [];

  void _addPrescription() {
    final drugCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final durCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Prescription'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: drugCtrl,
                  decoration: const InputDecoration(labelText: 'Drug Name')),
              TextField(
                  controller: dosageCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Dosage (e.g. 500mg)')),
              TextField(
                  controller: freqCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Frequency (e.g. 1x3)')),
              TextField(
                  controller: durCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Duration (days)'),
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (drugCtrl.text.isNotEmpty) {
                setState(() {
                  _prescribedItems.add(PrescriptionItem(
                    drugName: drugCtrl.text.trim(),
                    dosage: dosageCtrl.text.trim(),
                    frequency: freqCtrl.text.trim(),
                    duration: int.tryParse(durCtrl.text) ?? 1,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _finishConsultation() {
    if (_diagnosisCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a diagnosis'),
            backgroundColor: kDangerColor),
      );
      return;
    }

    final provider = Provider.of<HMSProvider>(context, listen: false);

    // 1. Add visit to patient history
    final visit = Visit(
      id: 'V${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      doctorName: widget.appointment.doctorName,
      reason: widget.appointment.reason,
      diagnosis: _diagnosisCtrl.text.trim(),
      prescription: _prescribedItems.map((e) => e.drugName).join(', '),
      type: VisitType.outpatient,
    );
    provider.addVisitToPatient(widget.appointment.patientId, visit);

    // 2. Create Prescription if items added
    if (_prescribedItems.isNotEmpty) {
      provider.addPrescription(Prescription(
        id: 'RX${DateTime.now().millisecondsSinceEpoch}',
        patientId: widget.appointment.patientId,
        patientName: widget.appointment.patientName,
        doctorName: widget.appointment.doctorName,
        items: _prescribedItems,
        issuedAt: DateTime.now(),
      ));
    }

    // 3. Create Lab Tests if ordered
    for (var testName in _orderedLabs) {
      provider.addLabTest(LabTest(
        id: 'L${DateTime.now().millisecondsSinceEpoch}',
        patientId: widget.appointment.patientId,
        patientName: widget.appointment.patientName,
        testName: testName,
        orderedBy: widget.appointment.doctorName,
        orderedAt: DateTime.now(),
        status: LabTestStatus.pending,
      ));
    }

    // 4. Update appointment status
    provider.updateAppointmentStatus(
        widget.appointment.id, AppointmentStatus.completed);

    // 5. Generate Bill
    final billItems = [
      BillItem(
          description: 'Consultation Fee',
          type: BillItemType.consultation,
          amount: 50.0),
    ];
    if (_prescribedItems.isNotEmpty) {
      billItems.add(BillItem(
          description: 'Pharmacy Invoice',
          type: BillItemType.medication,
          amount: 120.0)); // Placeholder amount
    }
    if (_orderedLabs.isNotEmpty) {
      billItems.add(BillItem(
          description: 'Lab Investigations',
          type: BillItemType.labTest,
          amount: 80.0)); // Placeholder amount
    }

    provider.addBill(Bill(
      id: 'B${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.appointment.patientId,
      patientName: widget.appointment.patientName,
      items: billItems,
      totalAmount: billItems.fold(0.0, (sum, item) => sum + item.total),
      issuedAt: DateTime.now(),
    ));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Consultation completed successfully!'),
          backgroundColor: kSuccessColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: Text('Consultation: ${widget.appointment.patientName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: kPrimaryColor),
            onPressed: _finishConsultation,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard('Clinical History', [
            _field('Symptoms / Presenting Complaints', _symptomsCtrl,
                maxLines: 3),
            const SizedBox(height: 12),
            _field('Examination Findings', _findingsCtrl, maxLines: 3),
          ]),
          const SizedBox(height: 16),
          _sectionCard('Assessment & Diagnosis', [
            _field('Diagnosis', _diagnosisCtrl, maxLines: 2, required: true),
          ]),
          const SizedBox(height: 16),
          _sectionCard('Prescriptions', [
            if (_prescribedItems.isEmpty)
              const Text('No medications prescribed.',
                  style: TextStyle(color: kTextLight, fontSize: 13))
            else
              ..._prescribedItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.medication,
                            size: 16, color: kSuccessColor),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text('${item.drugName} (${item.dosage})')),
                        Text('${item.frequency} x ${item.duration}d',
                            style: const TextStyle(
                                color: kTextLight, fontSize: 12)),
                      ],
                    ),
                  )),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addPrescription,
              icon: Icon(Icons.add),
              label: const Text('Add Medication'),
              style: OutlinedButton.styleFrom(foregroundColor: kSuccessColor),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionCard('Investigations', [
            Wrap(
              spacing: 8,
              children: [
                'Full Blood Count',
                'Urinalysis',
                'Malaria RDT',
                'Widal Test',
                'Blood Sugar'
              ]
                  .map((test) => FilterChip(
                        label: Text(test, style: const TextStyle(fontSize: 12)),
                        selected: _orderedLabs.contains(test),
                        onSelected: (selected) {
                          setState(() {
                            if (selected)
                              _orderedLabs.add(test);
                            else
                              _orderedLabs.remove(test);
                          });
                        },
                        selectedColor: kWarningColor.withOpacity(0.2),
                        checkmarkColor: kWarningColor,
                      ))
                  .toList(),
            ),
          ]),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _finishConsultation,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: kPrimaryColor,
            ),
            child: const Text('Complete Consultation & Generate Bill'),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: kTextMedium)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Enter $label...',
            filled: true,
            fillColor: kBgLight,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
