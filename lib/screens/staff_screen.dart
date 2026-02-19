import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/models/staff.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();
    final staff = provider.staff;

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(staff.length),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _staffCard(staff[i]),
                childCount: staff.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffSheet(context, provider),
        backgroundColor: kSuccessColor,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Register Personnel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSliverAppBar(int count) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: kSuccessColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.all(16),
        title: const Text('Medical Personnel',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 18)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kSuccessColor, kSuccessColor.withBlue(100)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.badge_rounded,
                    size: 140, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _staffCard(Staff member) {
    Color roleColor;
    IconData roleIcon;
    switch (member.role) {
      case UserRole.doctor:
        roleColor = kPrimaryColor;
        roleIcon = Icons.medical_services_rounded;
        break;
      case UserRole.nurse:
        roleColor = kInfoColor;
        roleIcon = Icons.health_and_safety_rounded;
        break;
      case UserRole.pharmacist:
        roleColor = kWarningColor;
        roleIcon = Icons.medication_rounded;
        break;
      case UserRole.labTech:
        roleColor = kDangerColor;
        roleIcon = Icons.science_rounded;
        break;
      default:
        roleColor = kTextMedium;
        roleIcon = Icons.person_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(roleIcon, color: roleColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kTextDark)),
                  Text(member.specialization ?? member.role.name.toUpperCase(),
                      style: const TextStyle(
                          color: kTextLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _contactInfo(Icons.phone_rounded, member.phone),
                      const SizedBox(width: 12),
                      _contactInfo(Icons.email_rounded, member.email),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(member.department,
                  style: TextStyle(
                      color: roleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: kTextLight),
        const SizedBox(width: 4),
        Text(text.contains('@') ? text.split('@').first : text,
            style: const TextStyle(color: kTextLight, fontSize: 11)),
      ],
    );
  }

  void _showAddStaffSheet(BuildContext context, HMSProvider provider) {
    final nameCtrl = TextEditingController();
    UserRole selectedRole = UserRole.doctor;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Register Personnel',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins')),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon:
                      const Icon(Icons.person_rounded, color: kSuccessColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    provider.addStaff(Staff(
                      id: 'S${(provider.staff.length + 1).toString().padLeft(3, '0')}',
                      name: nameCtrl.text.trim(),
                      role: selectedRole,
                      phone: '+233 00 000 0000',
                      email:
                          '${nameCtrl.text.toLowerCase().replaceAll(' ', '.')}@medisync.gh',
                      department: 'General',
                    ));
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccessColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Complete Registration',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
