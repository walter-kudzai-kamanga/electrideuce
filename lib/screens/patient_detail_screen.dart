import 'package:flutter/material.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/models/patient.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: kPrimaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          patient.name[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        patient.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${patient.id}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick info row
                Row(
                  children: [
                    _infoChip(Icons.cake_rounded, '${patient.age} years'),
                    const SizedBox(width: 8),
                    _infoChip(Icons.person, patient.gender),
                    const SizedBox(width: 8),
                    _infoChip(Icons.bloodtype, patient.bloodGroup),
                  ],
                ),
                const SizedBox(height: 16),
                // Contact info
                _sectionCard('Contact Information', [
                  _infoRow(Icons.phone, 'Phone', patient.phone),
                  if (patient.email.isNotEmpty)
                    _infoRow(Icons.email, 'Email', patient.email),
                  if (patient.address.isNotEmpty)
                    _infoRow(Icons.location_on, 'Address', patient.address),
                  _infoRow(Icons.emergency, 'Next of Kin', patient.nextOfKin),
                  _infoRow(Icons.phone_forwarded, 'NOK Phone', patient.nextOfKinPhone),
                ]),
                const SizedBox(height: 12),
                // Medical history
                _sectionCard('Medical History', [
                  if (patient.allergies.isNotEmpty) ...[
                    const Text('Allergies', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kTextMedium)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: patient.allergies.map((a) => Chip(
                        label: Text(a, style: const TextStyle(fontSize: 12)),
                        backgroundColor: kDangerColor.withOpacity(0.1),
                        side: BorderSide(color: kDangerColor.withOpacity(0.3)),
                        padding: EdgeInsets.zero,
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (patient.chronicConditions.isNotEmpty) ...[
                    const Text('Chronic Conditions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kTextMedium)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: patient.chronicConditions.map((c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        backgroundColor: kWarningColor.withOpacity(0.1),
                        side: BorderSide(color: kWarningColor.withOpacity(0.3)),
                        padding: EdgeInsets.zero,
                      )).toList(),
                    ),
                  ],
                  if (patient.allergies.isEmpty && patient.chronicConditions.isEmpty)
                    const Text('No medical history recorded.', style: TextStyle(color: kTextLight)),
                ]),
                const SizedBox(height: 12),
                // Visit timeline
                _buildVisitTimeline(patient),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kPrimaryColor),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kPrimaryColor),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: kTextLight, fontSize: 13)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitTimeline(Patient patient) {
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
          const Text('Visit Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
          const SizedBox(height: 12),
          if (patient.visitHistory.isEmpty)
            const Text('No visits recorded yet.', style: TextStyle(color: kTextLight))
          else
            ...patient.visitHistory.map((visit) => _visitTile(visit)),
        ],
      ),
    );
  }

  Widget _visitTile(Visit visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: kPrimaryColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(visit.doctorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(_formatDate(visit.date), style: const TextStyle(color: kTextLight, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Reason: ${visit.reason}', style: const TextStyle(fontSize: 12, color: kTextMedium)),
          Text('Diagnosis: ${visit.diagnosis}', style: const TextStyle(fontSize: 12, color: kTextMedium)),
          Text('Rx: ${visit.prescription}', style: const TextStyle(fontSize: 12, color: kPrimaryColor)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
