import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/screens/patients_screen.dart';
import 'package:medisync_hms/screens/appointments_screen.dart';
import 'package:medisync_hms/screens/pharmacy_screen.dart';
import 'package:medisync_hms/screens/lab_screen.dart';
import 'package:medisync_hms/screens/billing_screen.dart';
import 'package:medisync_hms/screens/telematics_screen.dart';
import 'package:medisync_hms/screens/staff_screen.dart';
import 'package:medisync_hms/models/appointment.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();
    final role = provider.currentRole;

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, provider),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeCard(provider),
                const SizedBox(height: 20),
                _buildStatsRow(context, provider),
                const SizedBox(height: 20),
                _buildQuickActions(context, role),
                const SizedBox(height: 20),
                _buildTodaysAppointments(context, provider),
                const SizedBox(height: 20),
                if (role == UserRole.admin || role == UserRole.pharmacist)
                  _buildPharmacyAlerts(context, provider),
                if (role == UserRole.admin || role == UserRole.pharmacist)
                  const SizedBox(height: 20),
                _buildRecentActivity(context, provider),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, HMSProvider provider) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'MediSync',
            style: TextStyle(
              color: kTextDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: kTextDark),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kDangerColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            child: Icon(provider.currentRole.icon, color: kPrimaryColor, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(HMSProvider provider) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.currentUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    provider.currentRole.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Today: ${_formatDate(DateTime.now())}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              provider.currentRole.icon,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, HMSProvider provider) {
    final todayAppts = provider.todaysAppointments.length;
    final totalPatients = provider.patients.length;
    final pendingLabs = provider.pendingLabTests.length;
    final lowStock = provider.lowStockDrugs.length;

    return Row(
      children: [
        Expanded(child: _statCard('Patients Today', '$todayAppts', Icons.people_rounded, kPrimaryColor)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Total Patients', '$totalPatients', Icons.folder_shared_rounded, kAccentColor)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Pending Labs', '$pendingLabs', Icons.science_rounded, kWarningColor)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Low Stock', '$lowStock', Icons.medication_rounded, kDangerColor)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: kTextLight,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserRole role) {
    final actions = _getActionsForRole(context, role);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: actions,
        ),
      ],
    );
  }

  List<Widget> _getActionsForRole(BuildContext context, UserRole role) {
    final all = [
      _actionCard(context, 'Patients', Icons.people_rounded, kPrimaryColor, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientsScreen()));
      }),
      _actionCard(context, 'Appointments', Icons.calendar_month_rounded, kAccentColor, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
      }),
      _actionCard(context, 'Pharmacy', Icons.medication_rounded, kSuccessColor, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyScreen()));
      }),
      _actionCard(context, 'Lab Tests', Icons.science_rounded, kWarningColor, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LabScreen()));
      }),
      _actionCard(context, 'Billing', Icons.receipt_long_rounded, kDangerColor, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BillingScreen()));
      }),
      _actionCard(context, 'Telematics', Icons.video_call_rounded, const Color(0xFF6B46C1), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TelematicsScreen()));
      }),
    ];

    if (role == UserRole.admin) {
      all.add(_actionCard(context, 'Staff', Icons.badge_rounded, kInfoColor, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen()));
      }));
    }

    return all;
  }

  Widget _actionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius),
          boxShadow: kSoftShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysAppointments(BuildContext context, HMSProvider provider) {
    final appts = provider.todaysAppointments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Appointments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
              ),
              child: const Text('See All', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (appts.isEmpty)
          _emptyState('No appointments today')
        else
          ...appts.take(3).map((a) => _appointmentTile(a)),
      ],
    );
  }

  Widget _appointmentTile(appointment) {
    Color priorityColor;
    switch (appointment.priority) {
      case AppointmentPriority.emergency:
        priorityColor = kDangerColor;
        break;
      case AppointmentPriority.urgent:
        priorityColor = kWarningColor;
        break;
      default:
        priorityColor = kSuccessColor;
    }

    Color statusColor;
    switch (appointment.status) {
      case AppointmentStatus.completed:
        statusColor = kSuccessColor;
        break;
      case AppointmentStatus.inProgress:
        statusColor = kInfoColor;
        break;
      case AppointmentStatus.cancelled:
        statusColor = kDangerColor;
        break;
      default:
        statusColor = kTextLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
        border: Border(left: BorderSide(color: priorityColor, width: 3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            child: Text(
              appointment.patientName[0],
              style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  '${appointment.doctorName} • ${_formatTime(appointment.dateTime)}',
                  style: const TextStyle(color: kTextLight, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusLabel(appointment.status),
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyAlerts(BuildContext context, HMSProvider provider) {
    final lowStock = provider.lowStockDrugs;
    if (lowStock.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚠️ Pharmacy Alerts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kWarningColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(color: kWarningColor.withOpacity(0.3)),
          ),
          child: Column(
            children: lowStock.map((drug) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: kWarningColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      drug.name,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                  Text(
                    '${drug.quantity} ${drug.unit} left',
                    style: const TextStyle(color: kDangerColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, HMSProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kBorderRadius),
            boxShadow: kSoftShadow,
          ),
          child: Column(
            children: [
              _activityItem(Icons.person_add_rounded, kPrimaryColor, 'New patient registered', 'Efua Mensah - P004', '2 hours ago'),
              _activityItem(Icons.science_rounded, kWarningColor, 'Lab result uploaded', 'Renal Function Test - Kofi Acheampong', '3 hours ago'),
              _activityItem(Icons.receipt_long_rounded, kSuccessColor, 'Bill paid', 'GHS 193.00 - Kofi Acheampong', '4 hours ago'),
              _activityItem(Icons.video_call_rounded, const Color(0xFF6B46C1), 'Remote consultation', 'Ama Boateng - Vitals submitted', '5 hours ago'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityItem(IconData icon, Color color, String title, String subtitle, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: kTextLight, fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: kTextLight, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: kTextLight)),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String _statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled: return 'Scheduled';
      case AppointmentStatus.inProgress: return 'In Progress';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
    }
  }
}
