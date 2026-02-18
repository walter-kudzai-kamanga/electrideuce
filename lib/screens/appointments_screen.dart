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
    final scheduled = all.where((a) => a.status == AppointmentStatus.scheduled).toList();
    final inProgress = all.where((a) => a.status == AppointmentStatus.inProgress).toList();
    final completed = all.where((a) => a.status == AppointmentStatus.completed).toList();

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: const Text('Appointments & Queue'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor,
          unselectedLabelColor: kTextLight,
          indicatorColor: kPrimaryColor,
          tabs: [
            Tab(text: 'Scheduled (${scheduled.length})'),
            Tab(text: 'In Progress (${inProgress.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookDialog(context, provider),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Book'),
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

  Widget _appointmentList(BuildContext context, HMSProvider provider, List<Appointment> list) {
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: kTextLight),
            SizedBox(height: 12),
            Text('No appointments', style: TextStyle(color: kTextLight)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _appointmentCard(context, provider, list[i]),
    );
  }

  Widget _appointmentCard(BuildContext context, HMSProvider provider, Appointment appt) {
    Color priorityColor;
    String priorityLabel;
    switch (appt.priority) {
      case AppointmentPriority.emergency:
        priorityColor = kDangerColor;
        priorityLabel = '🚨 Emergency';
        break;
      case AppointmentPriority.urgent:
        priorityColor = kWarningColor;
        priorityLabel = '⚠️ Urgent';
        break;
      default:
        priorityColor = kSuccessColor;
        priorityLabel = 'Normal';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
        border: Border(left: BorderSide(color: priorityColor, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  child: Text(appt.patientName[0],
                      style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt.patientName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(appt.doctorName,
                          style: const TextStyle(color: kTextLight, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(priorityLabel,
                      style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: kTextLight),
                const SizedBox(width: 4),
                Text(_formatDateTime(appt.dateTime),
                    style: const TextStyle(color: kTextLight, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.notes, size: 14, color: kTextLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(appt.reason,
                      style: const TextStyle(color: kTextMedium, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (appt.isWalkIn) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kInfoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Walk-in', style: TextStyle(color: kInfoColor, fontSize: 11)),
              ),
            ],
            if (appt.status == AppointmentStatus.scheduled) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.updateAppointmentStatus(appt.id, AppointmentStatus.inProgress);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConsultationScreen(appointment: appt),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: const BorderSide(color: kPrimaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Start', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => provider.updateAppointmentStatus(appt.id, AppointmentStatus.cancelled),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kDangerColor,
                        side: const BorderSide(color: kDangerColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
            if (appt.status == AppointmentStatus.inProgress) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => provider.updateAppointmentStatus(appt.id, AppointmentStatus.completed),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccessColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Mark Completed', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Book Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: patientCtrl,
                decoration: const InputDecoration(labelText: 'Patient Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedDoctor,
                decoration: const InputDecoration(labelText: 'Doctor'),
                items: provider.doctors.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                onChanged: (v) => setModalState(() => selectedDoctor = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Reason for visit'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Priority: '),
                  ...AppointmentPriority.values.map((p) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(p.name, style: const TextStyle(fontSize: 12)),
                      selected: priority == p,
                      selectedColor: p == AppointmentPriority.emergency
                          ? kDangerColor
                          : p == AppointmentPriority.urgent
                              ? kWarningColor
                              : kSuccessColor,
                      onSelected: (_) => setModalState(() => priority = p),
                    ),
                  )),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isWalkIn,
                    onChanged: (v) => setModalState(() => isWalkIn = v!),
                    activeColor: kPrimaryColor,
                  ),
                  const Text('Walk-in patient'),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (patientCtrl.text.isEmpty || reasonCtrl.text.isEmpty) return;
                    final appts = provider.appointments;
                    final id = 'A${(appts.length + 1).toString().padLeft(3, '0')}';
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment booked!'), backgroundColor: kSuccessColor),
                    );
                  },
                  child: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} • $h:$m $period';
  }
}
