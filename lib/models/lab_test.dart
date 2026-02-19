class LabTest {
  final String id;
  final String patientId;
  final String patientName;
  final String testName;
  final String orderedBy;
  final DateTime orderedAt;
  final LabTestStatus status;
  final String? result;

  LabTest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.testName,
    required this.orderedBy,
    required this.orderedAt,
    required this.status,
    this.result,
  });
}

enum LabTestStatus { pending, inProgress, completed }
