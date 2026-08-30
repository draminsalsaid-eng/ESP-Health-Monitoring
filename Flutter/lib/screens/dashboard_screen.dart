import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<HealthProvider>(
        context,
        listen: false,
      ).getLatestHealthData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final health =
        Provider.of<HealthProvider>(context);

    final data = health.healthData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Dashboard',
        ),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await health.getLatestHealthData();
        },

        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(16),

          children: [
            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Health Monitoring Results',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Latest completed measurement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // LOADING
            // ==================================================

            if (data == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              ),

            if (data != null) ...[
              // ==================================================
              // WORKER PROFILE
              // ==================================================

              _sectionTitle(
                'Worker Profile',
                Icons.person,
                Colors.blue,
              ),

              VitalCard(
                title: 'Worker Type',
                value: _displayText(data.workerType),
                icon: Icons.badge,
                color: Colors.blue,
              ),

              VitalCard(
                title: 'Activity',
                value: _displayText(data.activity),
                icon: Icons.directions_run,
                color: Colors.indigo,
              ),

              VitalCard(
                title: 'Environment',
                value: _displayText(data.environment),
                icon: Icons.location_on,
                color: Colors.teal,
              ),

              const SizedBox(height: 10),

              // ==================================================
              // PHYSIOLOGICAL DATA
              // ==================================================

              _sectionTitle(
                'Physiological Measurements',
                Icons.monitor_heart,
                Colors.red,
              ),

              VitalCard(
                title: 'Heart Rate',
                value:
                    '${data.heartRate} BPM',
                icon: Icons.favorite,
                color: Colors.red,
              ),

              VitalCard(
                title: 'Heart Rate Variability',
                value:
                    '${data.hrv} ms',
                icon: Icons.timeline,
                color: Colors.purple,
              ),

              VitalCard(
                title: 'Blood Oxygen (SpO₂)',
                value:
                    '${data.spo2} %',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),

              // ==================================================
              // TEMPERATURE
              // ==================================================

              _sectionTitle(
                'Temperature & Humidity',
                Icons.thermostat,
                Colors.orange,
              ),

              // --------------------------------------------------
              // BODY TEMPERATURE
              // --------------------------------------------------

              VitalCard(
                title: 'Body Temperature',
                value:
                    '${data.bodyTemperature.toStringAsFixed(2)} °C',
                icon: Icons.thermostat,
                color: Colors.deepOrange,
              ),

              // --------------------------------------------------
              // ENVIRONMENT TEMPERATURE
              // --------------------------------------------------

              VitalCard(
                title: 'Environment Temperature',
                value:
                    '${data.environmentTemperature.toStringAsFixed(2)} °C',
                icon: Icons.home_work,
                color: Colors.orange,
              ),

              // --------------------------------------------------
              // HUMIDITY
              // --------------------------------------------------

              VitalCard(
                title: 'Humidity',
                value:
                    '${data.humidity.toStringAsFixed(1)} %',
                icon: Icons.water_drop,
                color: Colors.cyan,
              ),

              // ==================================================
              // GAS / AIR QUALITY
              // ==================================================

              _sectionTitle(
                'Air & Gas Monitoring',
                Icons.air,
                Colors.brown,
              ),

              // --------------------------------------------------
              // MQ-2
              //
              // The ESP32 currently sends the raw ADC value.
              // We therefore do NOT display ppm.
              // --------------------------------------------------

              VitalCard(
                title: 'Combustible Gas',
                subtitle: 'MQ-2 sensor',
                value:
                    '${data.mq2}',
                icon: Icons.local_fire_department,
                color: Colors.brown,
              ),

              // --------------------------------------------------
              // MQ-5
              // --------------------------------------------------

              VitalCard(
                title: 'Natural Gas / LPG',
                subtitle: 'MQ-5 sensor',
                value:
                    '${data.mq5}',
                icon: Icons.gas_meter,
                color: Colors.deepPurple,
              ),

              // --------------------------------------------------
              // MQ-135
              // --------------------------------------------------

              VitalCard(
                title: 'Air Quality',
                subtitle: 'MQ-135 sensor',
                value:
                    '${data.mq135}',
                icon: Icons.air,
                color: Colors.blueGrey,
              ),

              const SizedBox(height: 10),

              // ==================================================
              // MOTION
              // ==================================================

              _sectionTitle(
                'Motion Measurements',
                Icons.directions_walk,
                Colors.green,
              ),

              VitalCard(
                title: 'Acceleration',
                value:
                    '${data.accMag.toStringAsFixed(2)} m/s²',
                icon: Icons.speed,
                color: Colors.green,
              ),

              VitalCard(
                title: 'Rotational Motion',
                value:
                    '${data.gyroMag.toStringAsFixed(2)} rad/s',
                icon: Icons.screen_rotation,
                color: Colors.lightGreen.shade700,
              ),

              // ==================================================
              // AI HEALTH ANALYSIS
              // ==================================================

              _sectionTitle(
                'AI Health Analysis',
                Icons.psychology,
                Colors.deepPurple,
              ),

              // --------------------------------------------------
              // SAFETY STATUS
              //
              // Comes from ESP32:
              // alert_level = green / yellow / red
              // --------------------------------------------------

              VitalCard(
                title: 'Safety Status',
                subtitle:
                    'Overall health alert',
                value:
                    _formatAlertLevel(
                      data.alertLevel,
                    ),
                icon:
                    _alertIcon(
                      data.alertLevel,
                    ),
                color:
                    _alertColor(
                      data.alertLevel,
                    ),
              ),

              // --------------------------------------------------
              // RISK LEVEL
              //
              // Comes from ESP32:
              // risk_level = low / medium / high
              // --------------------------------------------------

              VitalCard(
                title: 'Risk Level',
                subtitle:
                    'AI-assessed health risk',
                value:
                    _formatRiskLevel(
                      data.riskLevel,
                    ),
                icon:
                    Icons.warning_amber_rounded,
                color:
                    _riskColor(
                      data.riskLevel,
                    ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // USER NOTE
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12),

                  color:
                      Colors.grey.shade100,

                  border: Border.all(
                    color:
                        Colors.grey.shade300,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.info_outline,
                      color:
                          Colors.grey.shade700,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Gas sensor readings are shown as sensor '
                        'values. They are not displayed as ppm because '
                        'the current ESP32 system does not perform '
                        'gas-specific calibration.',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        bottom: 10,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAFE TEXT
  // ============================================================

  String _displayText(String value) {
    if (value.trim().isEmpty) {
      return 'Unknown';
    }

    return value.replaceAll('_', ' ');
  }

  // ============================================================
  // ALERT LEVEL
  // ============================================================

  String _formatAlertLevel(
    String value,
  ) {
    if (value.trim().isEmpty) {
      return 'Unknown';
    }

    switch (value.toLowerCase()) {
      case 'green':
        return 'SAFE';

      case 'yellow':
        return 'WARNING';

      case 'red':
        return 'DANGER';

      default:
        return value.toUpperCase();
    }
  }

  // ============================================================
  // ALERT COLOR
  // ============================================================

  Color _alertColor(
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'green':
        return Colors.green;

      case 'yellow':
        return Colors.orange;

      case 'red':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // ALERT ICON
  // ============================================================

  IconData _alertIcon(
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'green':
        return Icons.check_circle;

      case 'yellow':
        return Icons.warning_amber_rounded;

      case 'red':
        return Icons.dangerous;

      default:
        return Icons.help_outline;
    }
  }

  // ============================================================
  // RISK LEVEL
  // ============================================================

  String _formatRiskLevel(
    String value,
  ) {
    if (value.trim().isEmpty) {
      return 'Unknown';
    }

    switch (value.toLowerCase()) {
      case 'low':
        return 'LOW';

      case 'medium':
        return 'MEDIUM';

      case 'high':
        return 'HIGH';

      default:
        return value.toUpperCase();
    }
  }

  // ============================================================
  // RISK COLOR
  // ============================================================

  Color _riskColor(
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'low':
        return Colors.green;

      case 'medium':
        return Colors.orange;

      case 'high':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}


// =================================================================
// VITAL CARD
// =================================================================

class VitalCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const VitalCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 3,

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            // ==================================================
            // ICON
            // ==================================================

            CircleAvatar(
              radius: 24,

              backgroundColor:
                  color.withOpacity(0.12),

              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),

            const SizedBox(width: 15),

            // ==================================================
            // TITLE + SUBTITLE
            // ==================================================

            Expanded(
              flex: 6,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Text(
                    title,

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 3),

                    Text(
                      subtitle!,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ==================================================
            // VALUE
            // ==================================================

            Flexible(
              flex: 4,

              child: Text(
                value,

                textAlign:
                    TextAlign.right,

                maxLines: 2,

                overflow:
                    TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
