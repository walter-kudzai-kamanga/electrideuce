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
        content: Text('Patient ${patient.name} registered successfully'),
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Primary Identity'),
                    _field('Full Legal Name', _nameCtrl,
                        icon: Icons.person_rounded, required: true),
                    Row(
                      children: [
                        Expanded(
                            child: _field('Age', _ageCtrl,
                                icon: Icons.calendar_today_rounded,
                                required: true,
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _genderDropdown()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _bloodGroupSelector(),
                    const SizedBox(height: 32),
                    _sectionHeader('Communication Channels'),
                    _field('Primary Phone', _phoneCtrl,
                        icon: Icons.phone_android_rounded,
                        required: true,
                        keyboardType: TextInputType.phone),
                    _field('Email Address', _emailCtrl,
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress),
                    _field('Residential Address', _addressCtrl,
                        icon: Icons.location_on_rounded, maxLines: 2),
                    const SizedBox(height: 32),
                    _sectionHeader('Emergency Contact (NOK)'),
                    _field('NOK Full Name', _nokCtrl,
                        icon: Icons.supervised_user_circle_rounded,
                        required: true),
                    _field('NOK Contact Phone', _nokPhoneCtrl,
                        icon: Icons.contact_phone_rounded,
                        required: true,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 32),
                    _sectionHeader('Medical Background'),
                    _field('Allergies', _allergiesCtrl,
                        icon: Icons.warning_amber_rounded,
                        hint: 'e.g. Penicillin, Pollen'),
                    _field('Chronic Conditions', _conditionsCtrl,
                        icon: Icons.medical_information_rounded,
                        hint: 'e.g. Asthma, Hypertension'),
                    const SizedBox(height: 48),
                    _submitButton(context),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: kPrimaryColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.all(16),
        title: const Text('Patient Registration',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 18)),
        background: Container(
          decoration: const BoxDecoration(gradient: kOceanGradient),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(Icons.how_to_reg_rounded,
                    size: 160, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                  letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w600, color: kTextDark),
        validator: required
            ? (v) => (v == null || v.isEmpty)
                ? 'Policy violation: Field required'
                : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon, color: kPrimaryColor, size: 20) : null,
          filled: true,
          fillColor: kBgWhite,
          labelStyle: const TextStyle(color: kTextMedium, fontSize: 14),
          floatingLabelStyle: const TextStyle(
              color: kPrimaryColor, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kBorderColor, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _gender,
          isExpanded: true,
          items: ['Male', 'Female', 'Other']
              .map((g) => DropdownMenuItem(
                  value: g,
                  child: Text(g,
                      style: const TextStyle(fontWeight: FontWeight.w600))))
              .toList(),
          onChanged: (v) => setState(() => _gender = v!),
        ),
      ),
    );
  }

  Widget _bloodGroupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BLOOD TYPE',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: kTextMedium,
                letterSpacing: 1)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _bloodGroups
                .map((bg) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(bg,
                            style: TextStyle(
                                color: _bloodGroup == bg
                                    ? Colors.white
                                    : kTextDark,
                                fontWeight: FontWeight.bold)),
                        selected: _bloodGroup == bg,
                        selectedColor: kPrimaryColor,
                        backgroundColor: kBgWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          // border: BorderSide(
                          //     color: _bloodGroup == bg
                          //         ? kPrimaryColor
                          //         : kBorderColor)
                        ),
                        onSelected: (_) => setState(() => _bloodGroup = bg),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: kGlowShadow,
      ),
      child: ElevatedButton(
        onPressed: () => _register(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Text('ENGAGE REGISTRATION',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}
