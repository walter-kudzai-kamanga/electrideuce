class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String address;
  final String nextOfKin;
  final String nextOfKinPhone;
  final List<String> allergies;
  final List<String> chronicConditions;
  final String bloodGroup;
  final DateTime registeredAt;
  final List<Visit> visitHistory;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.email = '',
    this.address = '',
    required this.nextOfKin,
    required this.nextOfKinPhone,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.bloodGroup = 'Unknown',
    required this.registeredAt,
    this.visitHistory = const [],
  });
}

class Visit {
  final String id;
  final DateTime date;
  final String doctorName;
  final String reason;
  final String diagnosis;
  final String prescription;
  final String? nextAppointment;
  final VisitType type;

  Visit({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.reason,
    required this.diagnosis,
    required this.prescription,
    this.nextAppointment,
    this.type = VisitType.outpatient,
  });
}

enum VisitType { outpatient, emergency, telemedicine }
