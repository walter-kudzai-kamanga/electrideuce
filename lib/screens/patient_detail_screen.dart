import 'dart:ui';
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
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickOverview(),
                const SizedBox(height: 24),
                _sectionCard(
                    'Personal Information', Icons.person_outline_rounded, [
                  _infoRow(Icons.phone_rounded, 'Phone Number', patient.phone),
                  if (patient.email.isNotEmpty)
                    _infoRow(
                        Icons.email_outlined, 'Email Address', patient.email),
                  if (patient.address.isNotEmpty)
                    _infoRow(Icons.location_on_outlined, 'Residential Address',
                        patient.address),
                  _infoRow(Icons.family_restroom_rounded, 'Emergency Contact',
                      patient.nextOfKin),
                  _infoRow(Icons.settings_phone_rounded, 'Contact phone',
                      patient.nextOfKinPhone),
                ]),
                const SizedBox(height: 16),
                _sectionCard(
                    'Medical Conditions', Icons.medical_information_outlined, [
                  if (patient.allergies.isNotEmpty) ...[
                    const Text('Allergies',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: kTextMedium)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: patient.allergies
                          .map((a) => _tag(a, kDangerColor))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (patient.chronicConditions.isNotEmpty) ...[
                    const Text('Chronic Conditions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: kTextMedium)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: patient.chronicConditions
                          .map((c) => _tag(c, kWarningColor))
                          .toList(),
                    ),
                  ],
                  if (patient.allergies.isEmpty &&
                      patient.chronicConditions.isEmpty)
                    const Text('No records found.',
                        style: TextStyle(
                            color: kTextLight, fontStyle: FontStyle.italic)),
                ]),
                const SizedBox(height: 16),
                _buildVisitTimeline(patient),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        label: const Text('Update Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: kPrimaryColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
                decoration: const BoxDecoration(gradient: kPrimaryGradient)),
            // Decorative shapes
            Positioned(
              left: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05)),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        patient.name[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    patient.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                  ),
                  Text(
                    'P-ID: ${patient.id}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildQuickOverview() {
    return Row(
      children: [
        Expanded(
            child: _overviewItem(
                Icons.cake_rounded, '${patient.age}', 'Years Old')),
        const SizedBox(width: 12),
        Expanded(
            child: _overviewItem(Icons.wc_rounded, patient.gender, 'Gender')),
        const SizedBox(width: 12),
        Expanded(
            child: _overviewItem(
                Icons.bloodtype_rounded, patient.bloodGroup, 'Blood Group')),
      ],
    );
  }

  Widget _overviewItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimaryColor, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
          Text(label,
              style: const TextStyle(
                  color: kTextLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 20),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: kTextDark,
                      fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: kPrimaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: kTextLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: kTextMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildVisitTimeline(Patient patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text('Clinical History',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kTextDark,
                  fontFamily: 'Poppins')),
        ),
        if (patient.visitHistory.isEmpty)
          _emptyHistory()
        else
          ...patient.visitHistory.map((visit) => _visitTile(visit)),
      ],
    );
  }

  Widget _visitTile(Visit visit) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 4)
                      ]),
                ),
                Expanded(
                    child: Container(
                        width: 2, color: kPrimaryColor.withOpacity(0.2))),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBgWhite,
                borderRadius: BorderRadius.circular(kBorderRadius),
                boxShadow: kSoftShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(visit.doctorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: kPrimaryColor)),
                      Text(_formatDate(visit.date),
                          style: const TextStyle(
                              color: kTextLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _visitInfo('Indication', visit.reason),
                  _visitInfo('Diagnosis', visit.diagnosis),
                  _visitInfo('Prescription', visit.prescription, isRx: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitInfo(String label, String value, {bool isRx = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  color: kTextLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isRx ? kNeonGreen : kTextMedium))),
        ],
      ),
    );
  }

  Widget _emptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: kBgWhite,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: kBorderColor.withOpacity(0.3))),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, color: kTextLight, size: 40),
          SizedBox(height: 16),
          Text('No clinical visits recorded yet.',
              style: TextStyle(color: kTextLight, fontSize: 14)),
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
