import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/screens/pharmacy_screen.dart';
import 'package:medisync_hms/screens/lab_screen.dart';
import 'package:medisync_hms/screens/billing_screen.dart';
import 'package:medisync_hms/screens/telematics_screen.dart';
import 'package:medisync_hms/screens/staff_screen.dart';
import 'package:medisync_hms/screens/onboding_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(provider.currentRole.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.currentUserName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        provider.currentRole.displayName,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'MediSync HMS v1.0',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Modules section
          _sectionHeader('Modules'),
          _menuItem(context, Icons.medication_rounded, kSuccessColor, 'Pharmacy', 'Drug inventory & prescriptions', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyScreen()));
          }),
          _menuItem(context, Icons.science_rounded, kWarningColor, 'Laboratory', 'Test orders & results', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LabScreen()));
          }),
          _menuItem(context, Icons.receipt_long_rounded, kDangerColor, 'Billing', 'Invoices & payments', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BillingScreen()));
          }),
          _menuItem(context, Icons.video_call_rounded, const Color(0xFF6B46C1), 'Telematics', 'Remote care & vitals', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TelematicsScreen()));
          }),
          if (provider.currentRole == UserRole.admin)
            _menuItem(context, Icons.badge_rounded, kInfoColor, 'Staff Management', 'Doctors, nurses & staff', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen()));
            }),
          const SizedBox(height: 8),
          _sectionHeader('System'),
          _menuItem(context, Icons.info_outline_rounded, kTextLight, 'About MediSync', 'Version 1.0.0 MVP', () {
            _showAboutDialog(context);
          }),
          _menuItem(context, Icons.logout_rounded, kDangerColor, 'Sign Out', 'Return to login screen', () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              (route) => false,
            );
          }),
          const SizedBox(height: 32),
          // HMS modules overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBorderRadius),
              boxShadow: kSoftShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('System Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                _overviewRow('Total Patients', '${provider.patients.length}', kPrimaryColor),
                _overviewRow('Total Staff', '${provider.staff.length}', kInfoColor),
                _overviewRow('Today\'s Appointments', '${provider.todaysAppointments.length}', kAccentColor),
                _overviewRow('Pending Lab Tests', '${provider.pendingLabTests.length}', kWarningColor),
                _overviewRow('Low Stock Drugs', '${provider.lowStockDrugs.length}', kDangerColor),
                _overviewRow('Today\'s Revenue', 'GHS ${provider.todayRevenue.toStringAsFixed(2)}', kSuccessColor),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: kTextLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius),
          boxShadow: kSoftShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: kTextLight, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextLight),
          ],
        ),
      ),
    );
  }

  Widget _overviewRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kTextMedium, fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.local_hospital, color: kPrimaryColor),
            SizedBox(width: 8),
            Text('MediSync HMS'),
          ],
        ),
        content: const Text(
          'MediSync Hospital Management System v1.0\n\n'
          'MVP Features:\n'
          '• Patient Management\n'
          '• Doctor & Staff Management\n'
          '• Appointments & Queue\n'
          '• Consultations & Treatment\n'
          '• Pharmacy & Prescriptions\n'
          '• Billing & Payments\n'
          '• Lab Tests & Results\n'
          '• Telematics & Remote Monitoring\n\n'
          'Built with Flutter • Provider State Management',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
