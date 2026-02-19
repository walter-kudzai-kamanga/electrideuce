import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/screens/onboding_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(
              provider.currentUserName, provider.currentRole.name),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildSectionTitle('Administrative Controls'),
                  _settingsTile(Icons.people_alt_rounded, 'Staff Management',
                      'Manage medical & support staff', kPrimaryColor, () {}),
                  _settingsTile(
                      Icons.account_balance_rounded,
                      'Hospital Treasury',
                      'Financial reports & analytics',
                      kSuccessColor,
                      () {}),
                  _settingsTile(Icons.inventory_2_rounded, 'Stock & Logistics',
                      'Drug supply & equipment tracking', kWarningColor, () {}),
                  const SizedBox(height: 32),
                  _buildSectionTitle('System Preferences'),
                  _settingsTile(
                      Icons.notifications_active_rounded,
                      'Health Alerts',
                      'Configure critical notification rules',
                      kInfoColor,
                      () {}),
                  _settingsTile(Icons.security_rounded, 'Access Security',
                      'Manage 2FA & biometric access', kTextDark, () {}),
                  _settingsTile(Icons.language_rounded, 'Portal Language',
                      'Switch system display language', kTextLight, () {}),
                  const Spacer(),
                  const SizedBox(height: 32),
                  _logoutButton(context),
                  const SizedBox(height: 16),
                  const Text('MediSync HMS v2.4.0 • Premium Edition',
                      style: TextStyle(
                          color: kTextLight,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String name, String role) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: kPrimaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
                decoration: const BoxDecoration(gradient: kPrimaryGradient)),
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(role.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
              color: kTextLight,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kSoftShadow,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: kTextDark)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: kTextLight, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: kTextLight),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => const OnboardingScreen()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kDangerColor.withOpacity(0.1),
          foregroundColor: kDangerColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: kDangerColor, width: 1)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 12),
            Text('TERMINATE SESSION',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
