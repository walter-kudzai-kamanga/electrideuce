import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medisync_hms/constants.dart';
import 'package:medisync_hms/providers/hms_provider.dart';

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
      patientName: _patientCtrl.text.isEmpty ? 'Remote Patient' : _patientCtrl.text,
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
      appBar: AppBar(title: const Text('Telematics & Remote Care')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remote consultation card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B46C1), Color(0xFF553C9A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.video_call_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Remote Consultation',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Connect with a doctor via secure video call from anywhere.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showVideoCallDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6B46C1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.videocam_rounded),
                    label: const Text('Start Video Call', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Vitals entry
            const Text(
              'Remote Vitals Entry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Patient enters vitals from home. Alerts trigger for abnormal values.',
              style: TextStyle(color: kTextLight, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (_submitted && _hasAlert)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kDangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  border: Border.all(color: kDangerColor.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_rounded, color: kDangerColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '⚠️ Abnormal vitals detected! Doctor has been notified.',
                        style: TextStyle(color: kDangerColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            if (_submitted && !_hasAlert)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kSuccessColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  border: Border.all(color: kSuccessColor.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: kSuccessColor),
                    SizedBox(width: 10),
                    Text('Vitals recorded. All values are within normal range.',
                        style: TextStyle(color: kSuccessColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(kBorderRadius),
                boxShadow: kSoftShadow,
              ),
              child: Column(
                children: [
                  _vitalsField('Patient Name', _patientCtrl, Icons.person, 'e.g. Kwame Asante'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _vitalsField('Temperature (°C)', _tempCtrl, Icons.thermostat, '37.0', TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _vitalsField('Weight (kg)', _weightCtrl, Icons.monitor_weight, '70.0', TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _vitalsField('Blood Pressure', _bpCtrl, Icons.favorite, '120/80')),
                      const SizedBox(width: 12),
                      Expanded(child: _vitalsField('Glucose (mmol/L)', _glucoseCtrl, Icons.water_drop, '5.0', TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Normal ranges reference
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kBgLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Normal Ranges:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextMedium)),
                        SizedBox(height: 4),
                        Text('• Temperature: 36.0–37.5°C  • Glucose: 3.9–11.1 mmol/L',
                            style: TextStyle(fontSize: 11, color: kTextLight)),
                        Text('• Blood Pressure: <130/80 mmHg  • Weight: >40 kg',
                            style: TextStyle(fontSize: 11, color: kTextLight)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _submitVitals(context),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Submit Vitals', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFF6B46C1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Recent remote vitals
            if (provider.remoteVitals.isNotEmpty) ...[
              const Text(
                'Recent Remote Vitals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark),
              ),
              const SizedBox(height: 12),
              ...provider.remoteVitals.reversed.take(5).map((v) => _vitalsHistoryCard(v)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _vitalsField(String label, TextEditingController ctrl, IconData icon, String hint, [TextInputType? type]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kTextMedium)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: type ?? TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: kPrimaryColor),
            filled: true,
            fillColor: kBgLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _vitalsHistoryCard(RemoteVitals v) {
    final isAbnormal = v.hasAbnormalValues;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isAbnormal ? Border.all(color: kDangerColor.withOpacity(0.4)) : null,
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          Icon(
            isAbnormal ? Icons.warning_rounded : Icons.check_circle_rounded,
            color: isAbnormal ? kDangerColor : kSuccessColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  'Temp: ${v.temperature}°C  BP: ${v.bloodPressure}  Glucose: ${v.glucoseLevel} mmol/L',
                  style: const TextStyle(color: kTextLight, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${v.recordedAt.hour}:${v.recordedAt.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: kTextLight, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showVideoCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.video_call_rounded, color: Color(0xFF6B46C1)),
            SizedBox(width: 8),
            Text('Remote Consultation'),
          ],
        ),
        content: const Text(
          'Video call feature requires WebRTC integration.\n\nIn production, this would connect to your telemedicine platform (e.g., Agora, Twilio Video, or Jitsi Meet).',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B46C1)),
            child: const Text('Simulate Call'),
          ),
        ],
      ),
    );
  }
}
