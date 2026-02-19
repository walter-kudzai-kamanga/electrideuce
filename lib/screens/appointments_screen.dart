import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/models/appointment.dart';
import 'package:medisync_hms/screens/consultation_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();
    final all = provider.appointments;
    final scheduled =
        all.where((a) => a.status == AppointmentStatus.scheduled).toList();
    final inProgress =
        all.where((a) => a.status == AppointmentStatus.inProgress).toList();
    final completed =
        all.where((a) => a.status == AppointmentStatus.completed).toList();

    return Scaffold(
      backgroundColor: kBgLight,
      appBar:
          _buildAppBar(scheduled.length, inProgress.length, completed.length),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookDialog(context, provider),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('New Booking',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _appointmentList(context, provider, scheduled),
          _appointmentList(context, provider, inProgress),
          _appointmentList(context, provider, completed),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int s, int p, int c) {
    return AppBar(
      title: const Text('Queue Manager',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      backgroundColor: kBgLight.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: kPrimaryColor,
        unselectedLabelColor: kTextLight,
        indicatorColor: kPrimaryColor,
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
        tabs: [
          Tab(text: 'Pending ($s)'),
          Tab(text: 'Active ($p)'),
          Tab(text: 'Done ($c)'),
        ],
      ),
    );
  }

  Widget _appointmentList(
      BuildContext context, HMSProvider provider, List<Appointment> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded,
                size: 60, color: kPrimaryColor.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('Clear Schedule',
                style: TextStyle(
                    color: kTextLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _appointmentCard(context, provider, list[i]),
    );
  }

  Widget _appointmentCard(
      BuildContext context, HMSProvider provider, Appointment appt) {
    Color priorityColor;
    IconData priorityIcon;
    switch (appt.priority) {
      case AppointmentPriority.emergency:
        priorityColor = kDangerColor;
        priorityIcon = Icons.emergency_rounded;
        break;
      case AppointmentPriority.urgent:
        priorityColor = kWarningColor;
        priorityIcon = Icons.priority_high_rounded;
        break;
      default:
        priorityColor = kSuccessColor;
        priorityIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(appt.patientName[0],
                        style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt.patientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: kTextDark)),
                      const SizedBox(height: 2),
                      Text(appt.doctorName,
                          style: const TextStyle(
                              color: kTextLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                _priorityBadge(priorityColor, priorityIcon),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _infoTag(Icons.access_time_filled_rounded,
                    _formatDateTime(appt.dateTime)),
                const SizedBox(width: 12),
                if (appt.isWalkIn)
                  _infoTag(Icons.directions_walk_rounded, 'Walk-In',
                      color: kInfoColor),
              ],
            ),
          ),
          if (appt.status != AppointmentStatus.completed)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  if (appt.status == AppointmentStatus.scheduled) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          provider.updateAppointmentStatus(
                              appt.id, AppointmentStatus.inProgress);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ConsultationScreen(appointment: appt)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Begin Session',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => provider.updateAppointmentStatus(
                          appt.id, AppointmentStatus.cancelled),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: kDangerColor.withOpacity(0.1),
                        foregroundColor: kDangerColor,
                      ),
                    ),
                  ],
                  if (appt.status == AppointmentStatus.inProgress)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => provider.updateAppointmentStatus(
                            appt.id, AppointmentStatus.completed),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSuccessColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Complete Consultation',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _priorityBadge(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text('Alert',
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _infoTag(IconData icon, String text, {Color color = kTextLight}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showBookDialog(BuildContext context, HMSProvider provider) {
    final patientCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String selectedDoctor = provider.doctors.first.name;
    AppointmentPriority priority = AppointmentPriority.normal;
    bool isWalkIn = false;

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
          child: StatefulBuilder(
            builder: (ctx, setModalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Consultation',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 24),
                _inputField('Patient Name', patientCtrl, Icons.person_rounded),
                const SizedBox(height: 16),
                _dropdownField(
                    'Doctor In Charge',
                    selectedDoctor,
                    provider.doctors.map((d) => d.name).toList(),
                    (v) => setModalState(() => selectedDoctor = v!)),
                const SizedBox(height: 16),
                _inputField(
                    'Reason for Visit', reasonCtrl, Icons.note_add_rounded),
                const SizedBox(height: 24),
                const Text('Priority Level',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: kTextMedium)),
                const SizedBox(height: 12),
                Row(
                  children: AppointmentPriority.values
                      .map((p) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(
                                    p.name[0].toUpperCase() +
                                        p.name.substring(1),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                                selected: priority == p,
                                onSelected: (_) =>
                                    setModalState(() => priority = p),
                                selectedColor: kPrimaryColor.withOpacity(0.2),
                                checkmarkColor: kPrimaryColor,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: isWalkIn,
                  onChanged: (v) => setModalState(() => isWalkIn = v),
                  title: const Text('Walk-in Patient',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  activeColor: kPrimaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (patientCtrl.text.isEmpty || reasonCtrl.text.isEmpty)
                        return;
                      final appts = provider.appointments;
                      final id =
                          'A${(appts.length + 1).toString().padLeft(3, '0')}';
                      provider.addAppointment(Appointment(
                        id: id,
                        patientId: 'WALK',
                        patientName: patientCtrl.text.trim(),
                        doctorId: 'S001',
                        doctorName: selectedDoctor,
                        dateTime: DateTime.now(),
                        priority: priority,
                        reason: reasonCtrl.text.trim(),
                        isWalkIn: isWalkIn,
                      ));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm Booking',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: kPrimaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _dropdownField(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.medical_services_rounded,
            size: 20, color: kPrimaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  String _formatDateTime(DateTime dt) {
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
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} • $h:$m $period';
  }
}
