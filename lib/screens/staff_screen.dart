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
      appBar: AppBar(title: const Text('Staff Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context, provider),
        backgroundColor: kInfoColor,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Role summary
          _buildRoleSummary(staff),
          const SizedBox(height: 16),
          ...staff.map((s) => _staffCard(s)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildRoleSummary(List<Staff> staff) {
    final roles = {
      UserRole.doctor: staff.where((s) => s.role == UserRole.doctor).length,
      UserRole.nurse: staff.where((s) => s.role == UserRole.nurse).length,
      UserRole.labTech: staff.where((s) => s.role == UserRole.labTech).length,
      UserRole.pharmacist: staff.where((s) => s.role == UserRole.pharmacist).length,
      UserRole.cashier: staff.where((s) => s.role == UserRole.cashier).length,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Staff: ${staff.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roles.entries.map((e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: e.key.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(e.key.icon, size: 14, color: e.key.color),
                  const SizedBox(width: 4),
                  Text('${e.value} ${e.key.displayName}${e.value != 1 ? 's' : ''}',
                      style: TextStyle(color: e.key.color, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _staffCard(Staff staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: staff.role.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(staff.role.icon, color: staff.role.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(staff.specialization.isNotEmpty
                    ? '${staff.role.displayName} • ${staff.specialization}'
                    : staff.role.displayName,
                    style: const TextStyle(color: kTextLight, fontSize: 12)),
                Text(staff.department,
                    style: const TextStyle(color: kTextLight, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: staff.isAvailable
                      ? kSuccessColor.withOpacity(0.1)
                      : kDangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  staff.isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: staff.isAvailable ? kSuccessColor : kDangerColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(staff.id, style: const TextStyle(color: kTextLight, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context, HMSProvider provider) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    UserRole selectedRole = UserRole.doctor;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Staff Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 10),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: UserRole.values
                      .where((r) => r != UserRole.patient)
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.displayName)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedRole = v!),
                ),
                const SizedBox(height: 10),
                TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Specialization (optional)')),
                const SizedBox(height: 10),
                TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department')),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.isEmpty) return;
                      final id = 'S${(provider.staff.length + 1).toString().padLeft(3, '0')}';
                      provider.addStaff(Staff(
                        id: id,
                        name: nameCtrl.text.trim(),
                        role: selectedRole,
                        specialization: specCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        department: deptCtrl.text.trim(),
                      ));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Staff member added!'), backgroundColor: kSuccessColor),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: kInfoColor),
                    child: const Text('Add Staff Member'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
