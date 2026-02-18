class Drug {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final double price;
  final DateTime expiryDate;
  final bool isLowStock;

  Drug({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.expiryDate,
    this.isLowStock = false,
  });
}

class Prescription {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final List<PrescriptionItem> items;
  final DateTime issuedAt;
  PrescriptionStatus status;

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.items,
    required this.issuedAt,
    this.status = PrescriptionStatus.pending,
  });
}

class PrescriptionItem {
  final String drugName;
  final String dosage;
  final String frequency;
  final int duration;
  PrescriptionItemStatus status;

  PrescriptionItem({
    required this.drugName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.status = PrescriptionItemStatus.available,
  });
}

enum PrescriptionStatus { pending, partiallyDispensed, dispensed, cancelled }
enum PrescriptionItemStatus { available, outOfStock, dispensed }
