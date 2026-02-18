import 'package:medisync_hms/constants.dart';

class Staff {
  final String id;
  final String name;
  final UserRole role;
  final String specialization;
  final String phone;
  final String email;
  final bool isAvailable;
  final String department;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    this.specialization = '',
    required this.phone,
    required this.email,
    this.isAvailable = true,
    this.department = '',
  });
}
