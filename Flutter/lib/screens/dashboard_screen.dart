import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';
import '../models/health_response.dart';
import '../screens/ai_health_analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  // ============================================================
  // INIT
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final health =
        Provider.of<HealthProvider>(context);

    final data = health.healthData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
            // HEADER
            // ==================================================

            const Text(
              'Health Monitoring',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Latest completed measurement',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // LOADING
            // ==================================================

            if (data == null)
              const Padding(
                padding: EdgeInsets.all(40),

                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              ),

            // ==================================================
            // DATA
            // ==================================================

            if (data != null) ...[

              // =================================================
              // WORKER PROFILE
              // =================================================

              _sectionTitle(
                'Worker Profile',
                Icons.person,
                Colors.blue,
              ),

              VitalCard(
                title: 'Worker Type',
                value:
                    _displayText(
                      data.workerType,
                    ),
                icon: Icons.badge_outlined,
                color: Colors.blue,
              ),

              VitalCard(
                title: 'Activity',
                value:
                    _displayText(
                      data.activity,
                    ),
                icon:
                    Icons.directions_run,
                color: Colors.indigo,
              ),

              VitalCard(
                title: 'Environment',
                value:
                    _displayText(
                      data.environment,
                    ),
                icon:
                    Icons.location_on_outlined,
                color: Colors.teal,
              ),

              // =================================================
              // PHYSIOLOGICAL
              // =================================================

              _sectionTitle(
                'Physiological Measurements',
                Icons.monitor_heart,
                Colors.red,
              ),

              VitalCard(
                title: 'Heart Rate',
                value:
                    '${data.heartRate} BPM',
                icon:
                    Icons.favorite,
                color: Colors.red,
              ),

              VitalCard(
                title:
                    'Heart Rate Variability',
                value:
                    '${data.hrv} ms',
                icon:
                    Icons.timeline,
                color: Colors.purple,
              ),

              VitalCard(
                title:
                    'Blood Oxygen',
                subtitle:
                    'SpO₂',
                value:
                    '${data.spo2} %',
                icon:
                    Icons.water_drop,
                color: Colors.blue,
              ),

              // =================================================
              // TEMPERATURE
              // =================================================

              _sectionTitle(
                'Temperature & Humidity',
                Icons.thermostat,
                Colors.orange,
              ),

              VitalCard(
                title:
                    'Body Temperature',
                value:
                    '${data.bodyTemperature.toStringAsFixed(1)} °C',
                icon:
                    Icons.thermostat,
                color:
                    Colors.deepOrange,
              ),

              VitalCard(
                title:
                    'Environment Temperature',
                value:
                    '${data.environmentTemperature.toStringAsFixed(1)} °C',
                icon:
                    Icons.home_work_outlined,
                color:
                    Colors.orange,
              ),

              VitalCard(
                title:
                    'Humidity',
                value:
                    '${data.humidity.toStringAsFixed(1)} %',
                icon:
                    Icons.water_drop_outlined,
                color:
                    Colors.cyan,
              ),

              // =================================================
              // AIR / GAS
              // =================================================

              _sectionTitle(
                'Air & Gas Monitoring',
                Icons.air,
                Colors.brown,
              ),

              // -------------------------------------------------
              // MQ2
              // -------------------------------------------------

              VitalCard(
                title:
                    'Combustible Gas',
                subtitle:
                    'MQ-2 sensor',
                value:
                    '${data.mq2}',
                icon:
                    Icons.local_fire_department,
                color:
                    Colors.brown,
              ),

              // -------------------------------------------------
              // MQ5
              // -------------------------------------------------

              VitalCard(
                title:
                    'Natural Gas / LPG',
                subtitle:
                    'MQ-5 sensor',
                value:
                    '${data.mq5}',
                icon:
                    Icons.gas_meter,
                color:
                    Colors.deepPurple,
              ),

              // -------------------------------------------------
              // MQ135
              // -------------------------------------------------

              VitalCard(
                title:
                    'Air Quality',
                subtitle:
                    'MQ-135 sensor',
                value:
                    '${data.mq135}',
                icon:
                    Icons.air,
                color:
                    Colors.blueGrey,
              ),

              // =================================================
              // MOTION
              // =================================================

              _sectionTitle(
                'Motion Measurements',
                Icons.directions_walk,
                Colors.green,
              ),

              VitalCard(
                title:
                    'Acceleration',
                value:
                    '${data.accMag.toStringAsFixed(2)} m/s²',
                icon:
                    Icons.speed,
                color:
                    Colors.green,
              ),

              VitalCard(
                title:
                    'Rotational Motion',
                value:
                    '${data.gyroMag.toStringAsFixed(2)} rad/s',
                icon:
                    Icons.screen_rotation,
                color:
                    Colors.lightGreen.shade700,
              ),

              // =================================================
              // AI SUMMARY
              // =================================================

              _sectionTitle(
                'AI Health Analysis',
                Icons.psychology,
                Colors.deepPurple,
              ),

              // -------------------------------------------------
              // SAFETY STATUS
              // -------------------------------------------------

              VitalCard(
                title:
                    'Safety Status',
                subtitle:
                    'Overall workplace health alert',
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

              // -------------------------------------------------
              // RISK LEVEL
              // -------------------------------------------------

              VitalCard(
                title:
                    'Risk Level',
                subtitle:
                    'AI-assessed health risk',
                value:
                    _formatRiskLevel(
                      data.riskLevel,
                    ),
                icon:
                    _riskIcon(
                      data.riskLevel,
                    ),
                color:
                    _riskColor(
                      data.riskLevel,
                    ),
              ),

              const SizedBox(height: 6),

              // =================================================
              // VIEW FULL AI ANALYSIS
              // =================================================

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            AIHealthAnalysisScreen(
                          healthData: data,
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.analytics_outlined,
                  ),

                  label: const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 13,
                    ),

                    child: Text(
                      'View Full AI Health Analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // GAS INFORMATION
              // =================================================

              _buildGasInformation(),

              const SizedBox(height: 18),

              // =================================================
              // REFRESH INFORMATION
              // =================================================

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

              const SizedBox(height: 15),
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
      padding:
          const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: color,
            size: 27,
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

  String _displayText(
    String value,
  ) {
    if (value.trim().isEmpty) {
      return 'Unknown';
    }

    return value
        .replaceAll('_', ' ')
        .trim();
  }

  // ============================================================
  // ALERT FORMAT
  // ============================================================

  String _formatAlertLevel(
    String value,
  ) {
    switch (
        value.toLowerCase().trim()) {

      case 'green':
        return 'SAFE';

      case 'yellow':
        return 'WARNING';

      case 'red':
        return 'DANGER';

      default:
        return value.trim().isEmpty
            ? 'Unknown'
            : value.toUpperCase();
    }
  }

  // ============================================================
  // ALERT COLOR
  // ============================================================

  Color _alertColor(
    String value,
  ) {
    switch (
        value.toLowerCase().trim()) {

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
    switch (
        value.toLowerCase().trim()) {

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
  // RISK FORMAT
  // ============================================================

  String _formatRiskLevel(
    String value,
  ) {
    switch (
        value.toLowerCase().trim()) {

      case 'low':
        return 'LOW';

      case 'medium':
        return 'MODERATE';

      case 'high':
        return 'HIGH';

      default:
        return value.trim().isEmpty
            ? 'Unknown'
            : value.toUpperCase();
    }
  }

  // ============================================================
  // RISK COLOR
  // ============================================================

  Color _riskColor(
    String value,
  ) {
    switch (
        value.toLowerCase().trim()) {

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

  // ============================================================
  // RISK ICON
  // ============================================================

  IconData _riskIcon(
    String value,
  ) {
    switch (
        value.toLowerCase().trim()) {

      case 'low':
        return Icons.check_circle_rounded;

      case 'medium':
        return Icons.warning_amber_rounded;

      case 'high':
        return Icons.error_rounded;

      default:
        return Icons.help_outline;
    }
  }

  // ============================================================
  // GAS INFORMATION
  // ============================================================

  Widget _buildGasInformation() {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(14),

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
              'Gas readings are displayed as sensor values. '
              'They are not ppm measurements because the current '
              'ESP32 system uses raw sensor readings without '
              'gas-specific calibration.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color:
                    Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// VITAL CARD
// =================================================================

class VitalCard
    extends StatelessWidget {

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
      elevation: 2,

      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),

        child: Row(
          children: [

            // ==================================================
            // ICON
            // ==================================================

            Container(
              width: 48,
              height: 48,

              decoration:
                  BoxDecoration(
                color:
                    color.withOpacity(
                  0.12,
                ),

                shape:
                    BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            // ==================================================
            // TITLE
            // ==================================================

            Expanded(
              flex: 6,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle!,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

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
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
