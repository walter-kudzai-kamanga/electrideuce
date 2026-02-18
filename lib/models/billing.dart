class Bill {
  final String id;
  final String patientId;
  final String patientName;
  final List<BillItem> items;
  final double totalAmount;
  final DateTime issuedAt;
  BillStatus status;
  PaymentMethod? paymentMethod;

  Bill({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.items,
    required this.totalAmount,
    required this.issuedAt,
    this.status = BillStatus.pending,
    this.paymentMethod,
  });
}

class BillItem {
  final String description;
  final BillItemType type;
  final double amount;
  final int quantity;

  BillItem({
    required this.description,
    required this.type,
    required this.amount,
    this.quantity = 1,
  });

  double get total => amount * quantity;
}

enum BillStatus { pending, paid, partiallyPaid, cancelled }
enum BillItemType { consultation, labTest, medication, procedure, other }
enum PaymentMethod { cash, insurance, card, mobile }
