import 'package:flutter/foundation.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/models/patient.dart';
import 'package:medisync_hms/models/staff.dart';
import 'package:medisync_hms/models/appointment.dart';
import 'package:medisync_hms/models/pharmacy.dart';
import 'package:medisync_hms/models/billing.dart';
import 'package:medisync_hms/models/lab_test.dart';
import 'package:medisync_hms/models/telematics.dart';

class HMSProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.admin;
  String _currentUserName = 'Dr. Admin';

  UserRole get currentRole => _currentRole;
  String get currentUserName => _currentUserName;

  void setRole(UserRole role, String name) {
    _currentRole = role;
    _currentUserName = name;
    notifyListeners();
  }

  // ─── PATIENTS ────────────────────────────────────────────────────────────────
  final List<Patient> _patients = [
    Patient(
      id: 'P001',
      name: 'Kwame Asante',
      age: 34,
      gender: 'Male',
      phone: '+233 24 123 4567',
      nextOfKin: 'Abena Asante',
      nextOfKinPhone: '+233 24 765 4321',
      allergies: ['Penicillin', 'Aspirin'],
      chronicConditions: ['Hypertension'],
      bloodGroup: 'O+',
      registeredAt: DateTime(2024, 1, 15),
      visitHistory: [
        Visit(
          id: 'V001',
          date: DateTime(2024, 12, 10),
          doctorName: 'Dr. Mensah',
          reason: 'Chest pain',
          diagnosis: 'Hypertensive crisis',
          prescription: 'Amlodipine 5mg OD, Lisinopril 10mg OD',
          type: VisitType.outpatient,
        ),
      ],
    ),
    Patient(
      id: 'P002',
      name: 'Ama Boateng',
      age: 28,
      gender: 'Female',
      phone: '+233 20 987 6543',
      nextOfKin: 'Kofi Boateng',
      nextOfKinPhone: '+233 20 123 4567',
      allergies: [],
      chronicConditions: ['Diabetes Type 2'],
      bloodGroup: 'A+',
      registeredAt: DateTime(2024, 3, 22),
      visitHistory: [],
    ),
    Patient(
      id: 'P003',
      name: 'Yaw Darko',
      age: 52,
      gender: 'Male',
      phone: '+233 26 555 7890',
      nextOfKin: 'Akua Darko',
      nextOfKinPhone: '+233 26 555 1234',
      allergies: ['Sulfa drugs'],
      chronicConditions: ['Asthma', 'Arthritis'],
      bloodGroup: 'B-',
      registeredAt: DateTime(2023, 11, 5),
      visitHistory: [],
    ),
    Patient(
      id: 'P004',
      name: 'Efua Mensah',
      age: 19,
      gender: 'Female',
      phone: '+233 55 234 5678',
      nextOfKin: 'Kojo Mensah',
      nextOfKinPhone: '+233 55 876 5432',
      allergies: [],
      chronicConditions: [],
      bloodGroup: 'AB+',
      registeredAt: DateTime(2025, 1, 8),
      visitHistory: [],
    ),
    Patient(
      id: 'P005',
      name: 'Kofi Acheampong',
      age: 67,
      gender: 'Male',
      phone: '+233 24 456 7890',
      nextOfKin: 'Adwoa Acheampong',
      nextOfKinPhone: '+233 24 098 7654',
      allergies: ['Ibuprofen'],
      chronicConditions: ['Hypertension', 'Diabetes Type 2', 'CKD Stage 3'],
      bloodGroup: 'O-',
      registeredAt: DateTime(2022, 7, 19),
      visitHistory: [],
    ),
  ];

  List<Patient> get patients => List.unmodifiable(_patients);

  void addPatient(Patient patient) {
    _patients.add(patient);
    notifyListeners();
  }

  void addVisitToPatient(String patientId, Visit visit) {
    final idx = _patients.indexWhere((p) => p.id == patientId);
    if (idx != -1) {
      _patients[idx].visitHistory.add(visit);
      notifyListeners();
    }
  }

  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── STAFF ───────────────────────────────────────────────────────────────────
  final List<Staff> _staff = [
    Staff(
      id: 'S001',
      name: 'Dr. Kwabena Mensah',
      role: UserRole.doctor,
      specialization: 'Cardiologist',
      phone: '+233 24 111 2222',
      email: 'k.mensah@medisync.gh',
      department: 'Cardiology',
    ),
    Staff(
      id: 'S002',
      name: 'Dr. Abena Owusu',
      role: UserRole.doctor,
      specialization: 'General Practitioner',
      phone: '+233 20 333 4444',
      email: 'a.owusu@medisync.gh',
      department: 'General Medicine',
    ),
    Staff(
      id: 'S003',
      name: 'Nurse Akosua Frimpong',
      role: UserRole.nurse,
      phone: '+233 26 555 6666',
      email: 'a.frimpong@medisync.gh',
      department: 'General Ward',
    ),
    Staff(
      id: 'S004',
      name: 'Emmanuel Tetteh',
      role: UserRole.labTech,
      phone: '+233 55 777 8888',
      email: 'e.tetteh@medisync.gh',
      department: 'Laboratory',
    ),
    Staff(
      id: 'S005',
      name: 'Pharmacist Grace Asare',
      role: UserRole.pharmacist,
      phone: '+233 24 999 0000',
      email: 'g.asare@medisync.gh',
      department: 'Pharmacy',
    ),
    Staff(
      id: 'S006',
      name: 'Cashier Nana Osei',
      role: UserRole.cashier,
      phone: '+233 20 111 3333',
      email: 'n.osei@medisync.gh',
      department: 'Finance',
    ),
  ];

  List<Staff> get staff => List.unmodifiable(_staff);

  List<Staff> get doctors =>
      _staff.where((s) => s.role == UserRole.doctor).toList();

  void addStaff(Staff member) {
    _staff.add(member);
    notifyListeners();
  }

  // ─── APPOINTMENTS ─────────────────────────────────────────────────────────────
  final List<Appointment> _appointments = [
    Appointment(
      id: 'A001',
      patientId: 'P001',
      patientName: 'Kwame Asante',
      doctorId: 'S001',
      doctorName: 'Dr. Kwabena Mensah',
      dateTime: DateTime(2026, 2, 18, 9, 0),
      status: AppointmentStatus.scheduled,
      priority: AppointmentPriority.normal,
      reason: 'Follow-up on hypertension',
    ),
    Appointment(
      id: 'A002',
      patientId: 'P002',
      patientName: 'Ama Boateng',
      doctorId: 'S002',
      doctorName: 'Dr. Abena Owusu',
      dateTime: DateTime(2026, 2, 18, 10, 30),
      status: AppointmentStatus.inProgress,
      priority: AppointmentPriority.normal,
      reason: 'Diabetes management',
    ),
    Appointment(
      id: 'A003',
      patientId: 'P003',
      patientName: 'Yaw Darko',
      doctorId: 'S001',
      doctorName: 'Dr. Kwabena Mensah',
      dateTime: DateTime(2026, 2, 18, 11, 0),
      status: AppointmentStatus.scheduled,
      priority: AppointmentPriority.urgent,
      reason: 'Chest tightness',
    ),
    Appointment(
      id: 'A004',
      patientId: 'P004',
      patientName: 'Efua Mensah',
      doctorId: 'S002',
      doctorName: 'Dr. Abena Owusu',
      dateTime: DateTime(2026, 2, 18, 14, 0),
      status: AppointmentStatus.scheduled,
      priority: AppointmentPriority.emergency,
      reason: 'Severe abdominal pain',
      isWalkIn: true,
    ),
    Appointment(
      id: 'A005',
      patientId: 'P005',
      patientName: 'Kofi Acheampong',
      doctorId: 'S001',
      doctorName: 'Dr. Kwabena Mensah',
      dateTime: DateTime(2026, 2, 18, 15, 30),
      status: AppointmentStatus.completed,
      priority: AppointmentPriority.normal,
      reason: 'Monthly check-up',
    ),
  ];

  List<Appointment> get appointments => List.unmodifiable(_appointments);

  List<Appointment> get todaysAppointments {
    final now = DateTime.now();
    return _appointments
        .where((a) =>
            a.dateTime.year == now.year &&
            a.dateTime.month == now.month &&
            a.dateTime.day == now.day)
        .toList();
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  void updateAppointmentStatus(String id, AppointmentStatus status) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _appointments[idx] = Appointment(
        id: _appointments[idx].id,
        patientId: _appointments[idx].patientId,
        patientName: _appointments[idx].patientName,
        doctorId: _appointments[idx].doctorId,
        doctorName: _appointments[idx].doctorName,
        dateTime: _appointments[idx].dateTime,
        status: status,
        priority: _appointments[idx].priority,
        reason: _appointments[idx].reason,
        isWalkIn: _appointments[idx].isWalkIn,
      );
      notifyListeners();
    }
  }

  // ─── PHARMACY ─────────────────────────────────────────────────────────────────
  final List<Drug> _drugs = [
    Drug(
      id: 'D001',
      name: 'Amlodipine 5mg',
      category: 'Antihypertensive',
      quantity: 500,
      unit: 'tablets',
      price: 2.50,
      expiryDate: DateTime(2026, 12, 31),
    ),
    Drug(
      id: 'D002',
      name: 'Metformin 500mg',
      category: 'Antidiabetic',
      quantity: 12,
      unit: 'tablets',
      price: 1.80,
      expiryDate: DateTime(2026, 8, 15),
      isLowStock: true,
    ),
    Drug(
      id: 'D003',
      name: 'Amoxicillin 250mg',
      category: 'Antibiotic',
      quantity: 300,
      unit: 'capsules',
      price: 3.20,
      expiryDate: DateTime(2026, 6, 30),
    ),
    Drug(
      id: 'D004',
      name: 'Paracetamol 500mg',
      category: 'Analgesic',
      quantity: 8,
      unit: 'tablets',
      price: 0.50,
      expiryDate: DateTime(2027, 1, 31),
      isLowStock: true,
    ),
    Drug(
      id: 'D005',
      name: 'Salbutamol Inhaler',
      category: 'Bronchodilator',
      quantity: 45,
      unit: 'inhalers',
      price: 15.00,
      expiryDate: DateTime(2026, 10, 31),
    ),
  ];

  List<Drug> get drugs => List.unmodifiable(_drugs);
  List<Drug> get lowStockDrugs => _drugs.where((d) => d.isLowStock).toList();

  final List<Prescription> _prescriptions = [];
  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);

  void addPrescription(Prescription prescription) {
    _prescriptions.add(prescription);
    notifyListeners();
  }

  // ─── BILLING ─────────────────────────────────────────────────────────────────
  final List<Bill> _bills = [
    Bill(
      id: 'B001',
      patientId: 'P001',
      patientName: 'Kwame Asante',
      items: [
        BillItem(
            description: 'Consultation Fee',
            type: BillItemType.consultation,
            amount: 50.0),
        BillItem(
            description: 'Amlodipine 5mg x30',
            type: BillItemType.medication,
            amount: 75.0),
        BillItem(
            description: 'ECG', type: BillItemType.procedure, amount: 120.0),
      ],
      totalAmount: 245.0,
      issuedAt: DateTime(2026, 2, 18),
      status: BillStatus.pending,
    ),
    Bill(
      id: 'B002',
      patientId: 'P005',
      patientName: 'Kofi Acheampong',
      items: [
        BillItem(
            description: 'Consultation Fee',
            type: BillItemType.consultation,
            amount: 50.0),
        BillItem(
            description: 'Blood Sugar Test',
            type: BillItemType.labTest,
            amount: 35.0),
        BillItem(
            description: 'Metformin 500mg x60',
            type: BillItemType.medication,
            amount: 108.0),
      ],
      totalAmount: 193.0,
      issuedAt: DateTime(2026, 2, 18),
      status: BillStatus.paid,
      paymentMethod: PaymentMethod.cash,
    ),
  ];

  List<Bill> get bills => List.unmodifiable(_bills);

  double get todayRevenue => _bills
      .where((b) =>
          b.status == BillStatus.paid &&
          b.issuedAt.day == DateTime.now().day &&
          b.issuedAt.month == DateTime.now().month &&
          b.issuedAt.year == DateTime.now().year)
      .fold(0.0, (sum, b) => sum + b.totalAmount);

  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
  }

  // ─── LAB TESTS ────────────────────────────────────────────────────────────────
  final List<LabTest> _labTests = [
    LabTest(
      id: 'L001',
      patientId: 'P001',
      patientName: 'Kwame Asante',
      testName: 'Complete Blood Count',
      orderedBy: 'Dr. Kwabena Mensah',
      orderedAt: DateTime(2026, 2, 18, 9, 30),
      status: LabTestStatus.pending,
    ),
    LabTest(
      id: 'L002',
      patientId: 'P002',
      patientName: 'Ama Boateng',
      testName: 'HbA1c',
      orderedBy: 'Dr. Abena Owusu',
      orderedAt: DateTime(2026, 2, 18, 10, 45),
      status: LabTestStatus.inProgress,
    ),
    LabTest(
      id: 'L003',
      patientId: 'P005',
      patientName: 'Kofi Acheampong',
      testName: 'Renal Function Test',
      orderedBy: 'Dr. Kwabena Mensah',
      orderedAt: DateTime(2026, 2, 17, 14, 0),
      status: LabTestStatus.completed,
      result: 'Creatinine: 1.8 mg/dL (High). eGFR: 42 mL/min. Urea: 28 mg/dL.',
    ),
  ];

  List<LabTest> get labTests => List.unmodifiable(_labTests);
  List<LabTest> get pendingLabTests =>
      _labTests.where((t) => t.status == LabTestStatus.pending).toList();

  void addLabTest(LabTest test) {
    _labTests.add(test);
    notifyListeners();
  }

  void updateLabTestResult(String id, String result) {
    final idx = _labTests.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _labTests[idx] = LabTest(
        id: _labTests[idx].id,
        patientId: _labTests[idx].patientId,
        patientName: _labTests[idx].patientName,
        testName: _labTests[idx].testName,
        orderedBy: _labTests[idx].orderedBy,
        orderedAt: _labTests[idx].orderedAt,
        status: LabTestStatus.completed,
        result: result,
      );
      notifyListeners();
    }
  }

  // ─── TELEMATICS ───────────────────────────────────────────────────────────────
  final List<RemoteVitals> _remoteVitals = [];
  List<RemoteVitals> get remoteVitals => List.unmodifiable(_remoteVitals);

  void addRemoteVitals(RemoteVitals vitals) {
    _remoteVitals.add(vitals);
    notifyListeners();
  }
}
