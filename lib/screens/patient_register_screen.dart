import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/models/patient.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _nokCtrl = TextEditingController();
  final _nokPhoneCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  String _gender = 'Male';
  String _bloodGroup = 'O+';

  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  void _register(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<HMSProvider>(context, listen: false);
    final id = 'P${(provider.patients.length + 1).toString().padLeft(3, '0')}';
    final patient = Patient(
      id: id,
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text) ?? 0,
      gender: _gender,
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      nextOfKin: _nokCtrl.text.trim(),
      nextOfKinPhone: _nokPhoneCtrl.text.trim(),
      allergies: _allergiesCtrl.text.isEmpty
          ? []
          : _allergiesCtrl.text.split(',').map((e) => e.trim()).toList(),
      chronicConditions: _conditionsCtrl.text.isEmpty
          ? []
          : _conditionsCtrl.text.split(',').map((e) => e.trim()).toList(),
      bloodGroup: _bloodGroup,
      registeredAt: DateTime.now(),
    );
    provider.addPatient(patient);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Patient ${patient.name} registered with ID: ${patient.id}'),
        backgroundColor: kSuccessColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(title: const Text('Register Patient')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('Personal Information'),
            _field('Full Name', _nameCtrl, required: true),
            Row(
              children: [
                Expanded(child: _field('Age', _ageCtrl, required: true, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMedium)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _gender,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (v) => setState(() => _gender = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Blood Group', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMedium)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: _bloodGroups.map((bg) => ChoiceChip(
                    label: Text(bg),
                    selected: _bloodGroup == bg,
                    selectedColor: kPrimaryColor,
                    labelStyle: TextStyle(
                      color: _bloodGroup == bg ? Colors.white : kTextDark,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _bloodGroup = bg),
                  )).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionHeader('Contact Details'),
            _field('Phone Number', _phoneCtrl, required: true, keyboardType: TextInputType.phone),
            _field('Email Address', _emailCtrl, keyboardType: TextInputType.emailAddress),
            _field('Home Address', _addressCtrl, maxLines: 2),
            const SizedBox(height: 8),
            _sectionHeader('Next of Kin'),
            _field('Next of Kin Name', _nokCtrl, required: true),
            _field('Next of Kin Phone', _nokPhoneCtrl, required: true, keyboardType: TextInputType.phone),
            const SizedBox(height: 8),
            _sectionHeader('Medical History'),
            _field('Allergies (comma-separated)', _allergiesCtrl, hint: 'e.g. Penicillin, Aspirin'),
            _field('Chronic Conditions (comma-separated)', _conditionsCtrl, hint: 'e.g. Hypertension, Diabetes'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _register(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Register Patient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMedium)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
            decoration: InputDecoration(
              hintText: hint ?? 'Enter $label',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
