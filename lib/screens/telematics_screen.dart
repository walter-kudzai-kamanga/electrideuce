import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';
import 'package:medisync_hms/models/telematics.dart';

class TelematicsScreen extends StatefulWidget {
  const TelematicsScreen({super.key});

  @override
  State<TelematicsScreen> createState() => _TelematicsScreenState();
}

class _TelematicsScreenState extends State<TelematicsScreen> {
  final _tempCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  final _glucoseCtrl = TextEditingController();
  final _patientCtrl = TextEditingController();
  bool _submitted = false;
  bool _hasAlert = false;

  void _submitVitals(BuildContext context) {
    final provider = Provider.of<HMSProvider>(context, listen: false);
    final temp = double.tryParse(_tempCtrl.text) ?? 37.0;
    final weight = double.tryParse(_weightCtrl.text) ?? 70.0;
    final glucose = double.tryParse(_glucoseCtrl.text) ?? 5.0;
    final bp = _bpCtrl.text.isEmpty ? '120/80' : _bpCtrl.text;

    final vitals = RemoteVitals(
      patientId: 'REMOTE',
      patientName:
          _patientCtrl.text.isEmpty ? 'Remote Patient' : _patientCtrl.text,
      temperature: temp,
      weight: weight,
      bloodPressure: bp,
      glucoseLevel: glucose,
      recordedAt: DateTime.now(),
    );

    provider.addRemoteVitals(vitals);
    setState(() {
      _submitted = true;
      _hasAlert = vitals.hasAbnormalValues;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HMSProvider>();

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildConsultationBanner(),
                const SizedBox(height: 32),
                _buildVitalsInputSection(),
                const SizedBox(height: 32),
                if (provider.remoteVitals.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      'Monitoring History',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                  ...provider.remoteVitals.reversed
                      .take(5)
                      .map((v) => _vitalsHistoryCard(v)),
                ],
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: kPrimaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Telematics Command',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 18)),
        background: Container(
            decoration: const BoxDecoration(gradient: kPrimaryGradient)),
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.settings_input_antenna_rounded),
            onPressed: () {}),
      ],
    );
  }

  Widget _buildConsultationBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSecondaryColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kGlowShadow,
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.video_call_rounded,
                color: Colors.white.withOpacity(0.1), size: 140),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.wifi_tethering_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Active Consultations',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Encrypted video link ready. Connect with specialized diagnostics remotely.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showVideoCallDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Start Remote Session',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Biometric Entry',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  fontFamily: 'Poppins'),
            ),
            if (_submitted)
              IconButton(
                  onPressed: () => setState(() => _submitted = false),
                  icon: const Icon(Icons.refresh_rounded,
                      color: kPrimaryColor, size: 20)),
          ],
        ),
        const SizedBox(height: 16),
        if (_submitted) _statusMessage(),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kBgWhite,
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            boxShadow: kCardShadow,
            border: Border.all(color: kBorderColor.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _vitalsField('Patient Identity', _patientCtrl,
                  Icons.fingerprint_rounded, 'Enter Patient Name'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _vitalsField(
                          'Temp (°C)',
                          _tempCtrl,
                          Icons.thermostat_rounded,
                          '37.0',
                          TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _vitalsField(
                          'Weight (kg)',
                          _weightCtrl,
                          Icons.monitor_weight_rounded,
                          '70.0',
                          TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _vitalsField(
                          'Pressure', _bpCtrl, Icons.speed_rounded, '120/80')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _vitalsField('Glucose', _glucoseCtrl,
                          Icons.opacity_rounded, '5.0', TextInputType.number)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: kPrimaryGradient,
                    boxShadow: [
                      BoxShadow(
                          color: kPrimaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _submitVitals(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Broadcast Vitals',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusMessage() {
    final color = _hasAlert ? kDangerColor : kSuccessColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(_hasAlert ? Icons.error_outline_rounded : Icons.verified_rounded,
              color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _hasAlert
                  ? 'Alert: Abnormal biometrics detected!'
                  : 'Status: Vitals synchronized successfully.',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalsField(
      String label, TextEditingController ctrl, IconData icon, String hint,
      [TextInputType? type]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: kTextMedium,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type ?? TextInputType.text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontWeight: FontWeight.normal, color: kTextLight),
            prefixIcon: Icon(icon, size: 18, color: kPrimaryColor),
            filled: true,
            fillColor: kBgLight.withOpacity(0.5),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _vitalsHistoryCard(RemoteVitals v) {
    final isAbnormal = v.hasAbnormalValues;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  (isAbnormal ? kDangerColor : kSuccessColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAbnormal ? Icons.warning_amber_rounded : Icons.api_rounded,
              color: isAbnormal ? kDangerColor : kSuccessColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.patientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: kTextDark)),
                const SizedBox(height: 4),
                Text(
                  'BP: ${v.bloodPressure} • Temp: ${v.temperature}°C • GL: ${v.glucoseLevel}',
                  style: const TextStyle(
                      color: kTextLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            '${v.recordedAt.hour}:${v.recordedAt.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
                color: kTextLight, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showVideoCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: kBgWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.private_connectivity_rounded,
                  color: kPrimaryColor, size: 48),
              SizedBox(height: 16),
              Text('Initialize Consultation',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Establishing end-to-end encrypted medical tunnel. Video stream requires permissions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextMedium, height: 1.5),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:
                    const Text('Cancel', style: TextStyle(color: kTextLight))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Connect Now',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
