class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime dateTime;
  final AppointmentStatus status;
  final AppointmentPriority priority;
  final String reason;
  final bool isWalkIn;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
    this.priority = AppointmentPriority.normal,
    required this.reason,
    this.isWalkIn = false,
  });
}

enum AppointmentStatus { scheduled, inProgress, completed, cancelled }
enum AppointmentPriority { normal, urgent, emergency }
