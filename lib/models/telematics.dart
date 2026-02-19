class RemoteVitals {
  final String patientId;
  final String patientName;
  final double temperature;
  final double weight;
  final String bloodPressure;
  final double glucoseLevel;
  final DateTime recordedAt;

  RemoteVitals({
    required this.patientId,
    required this.patientName,
    required this.temperature,
    required this.weight,
    required this.bloodPressure,
    required this.glucoseLevel,
    required this.recordedAt,
  });

  bool get hasAbnormalValues {
    return temperature > 37.5 ||
        temperature < 36.0 ||
        glucoseLevel > 11.1 ||
        glucoseLevel < 3.9 ||
        weight < 40;
  }
}
