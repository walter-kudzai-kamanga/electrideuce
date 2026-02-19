import 'dart:ui';
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
      body: Stack(
        children: [
          // Subtle background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor.withOpacity(0.05),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeCard(provider),
                    const SizedBox(height: 28),
                    _buildStatsRow(context, provider),
                    const SizedBox(height: 28),
                    _buildQuickActions(context, role),
                    const SizedBox(height: 28),
                    _buildTodaysAppointments(context, provider),
                    const SizedBox(height: 28),
                    if (role == UserRole.admin || role == UserRole.pharmacist)
                      _buildPharmacyAlerts(context, provider),
                    if (role == UserRole.admin || role == UserRole.pharmacist)
                      const SizedBox(height: 28),
                    _buildRecentActivity(context, provider),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
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
      backgroundColor: kBgLight.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: kGlowShadow,
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'MediSync',
            style: TextStyle(
              color: kTextDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Badge(
            backgroundColor: kDangerColor,
            child:
                const Icon(Icons.notifications_none_rounded, color: kTextDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: 18,
              backgroundColor: kPrimaryColor.withOpacity(0.1),
              child: Icon(provider.currentRole.icon,
                  color: kPrimaryColor, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(HMSProvider provider) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        boxShadow: kGlowShadow,
      ),
      child: Stack(
        children: [
          // Decorative shapes
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.currentUserName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        provider.currentRole.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, HMSProvider provider) {
    return Row(
      children: [
        Expanded(
            child: _statCard(
                'Appointments',
                '${provider.todaysAppointments.length}',
                Icons.calendar_month_rounded,
                kPrimaryColor)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard('Patients', '${provider.patients.length}',
                Icons.groups_rounded, kAccentColor)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard('Lab Files', '${provider.pendingLabTests.length}',
                Icons.science_rounded, kWarningColor)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: kTextDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: kTextLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
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
    final List<Widget> items = [
      _actionCard(context, 'Patients', Icons.people_alt_rounded, kPrimaryColor,
          () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PatientsScreen()));
      }),
      _actionCard(context, 'Calendar', Icons.event_note_rounded, kAccentColor,
          () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
      }),
      _actionCard(
          context, 'Pharmacy', Icons.medication_liquid_rounded, kNeonGreen, () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PharmacyScreen()));
      }),
      _actionCard(context, 'Laboratory', Icons.biotech_rounded, kWarningColor,
          () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LabScreen()));
      }),
      _actionCard(context, 'Finances', Icons.account_balance_wallet_rounded,
          kDangerColor, () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BillingScreen()));
      }),
      _actionCard(
          context, 'Telematics', Icons.video_camera_front_rounded, kRoyalPurple,
          () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TelematicsScreen()));
      }),
    ];

    if (role == UserRole.admin) {
      items.add(
          _actionCard(context, 'Staff', Icons.badge_rounded, kInfoColor, () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const StaffScreen()));
      }));
    }

    return items;
  }

  Widget _actionCard(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kBgWhite,
          borderRadius: BorderRadius.circular(kBorderRadius),
          boxShadow: kCardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kTextMedium,
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
              "Today's Schedule",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  fontFamily: 'Poppins'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
              ),
              child: const Text('View All',
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (appts.isEmpty)
          _emptyState('No appointments scheduled for today.')
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              appointment.patientName[0],
              style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: kTextDark),
                ),
                Text(
                  '${appointment.doctorName} • ${_formatTime(appointment.dateTime)}',
                  style: const TextStyle(
                      color: kTextLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: priorityColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2),
              ],
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
          'Inventory Alerts',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kDangerColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(color: kDangerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: lowStock
                .map((drug) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: kDangerColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              drug.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: kTextDark),
                            ),
                          ),
                          Text(
                            '${drug.quantity} left',
                            style: const TextStyle(
                                color: kDangerColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ))
                .toList(),
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
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: kBgWhite,
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            boxShadow: kSoftShadow,
          ),
          child: Column(
            children: [
              _activityItem(Icons.person_add_rounded, kPrimaryColor,
                  'New Patient', 'Efua Mensah registered', '2h ago'),
              _activityItem(Icons.science_rounded, kWarningColor, 'Lab Result',
                  'Renal Test uploaded', '3h ago'),
              _activityItem(Icons.payments_rounded, kSuccessColor, 'Billing',
                  'GHS 193.00 payment', '4h ago'),
              _activityItem(Icons.videocam_rounded, kRoyalPurple, 'Telematics',
                  'Remote vitals synced', '5h ago'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityItem(
      IconData icon, Color color, String title, String subtitle, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: kBorderColor.withOpacity(0.5), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: kTextDark)),
                Text(subtitle,
                    style: const TextStyle(color: kTextLight, fontSize: 12)),
              ],
            ),
          ),
          Text(time,
              style: const TextStyle(
                  color: kTextLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
            color: kBorderColor.withOpacity(0.5), style: BorderStyle.none),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded,
              color: kTextLight.withOpacity(0.3), size: 48),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  color: kTextLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }
}
