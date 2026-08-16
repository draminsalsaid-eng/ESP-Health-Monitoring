import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';
import '../models/esp_status.dart';

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
    final espState = health.espState;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Health Dashboard",
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

          padding:
              const EdgeInsets.all(16),

          children: [

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              "Health Monitoring Dashboard",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "ESP32 Biomedical Monitoring System",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ESP32 CURRENT STATUS
            // ==================================================

            ESPStatusCard(
              status: espState.status,
              message: espState.message,
              progress: espState.progress,
            ),

            const SizedBox(height: 20),

            // ==================================================
            // NO DATA
            // ==================================================

            if (data == null) ...[

              const SizedBox(height: 20),

              const Center(
                child: Column(
                  children: [

                    Icon(
                      Icons.monitor_heart,
                      size: 60,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 15),

                    Text(
                      "No completed measurement",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Start a new measurement "
                      "from the monitoring screen.",
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],

            // ==================================================
            // HEALTH DATA
            // ==================================================

            if (data != null) ...[

              // ==================================================
              // WORKER PROFILE
              // ==================================================

              _sectionTitle(
                "Worker Profile",
                Icons.person,
                Colors.blue,
              ),

              VitalCard(
                title: "Worker Type",
                value: data.workerType.isEmpty
                    ? "Unknown"
                    : data.workerType,
                icon: Icons.badge,
                color: Colors.blue,
              ),

              VitalCard(
                title: "Activity",
                value: data.activity.isEmpty
                    ? "Unknown"
                    : data.activity,
                icon: Icons.directions_run,
                color: Colors.indigo,
              ),

              VitalCard(
                title: "Environment",
                value: data.environment.isEmpty
                    ? "Unknown"
                    : data.environment,
                icon: Icons.location_on,
                color: Colors.teal,
              ),

              const SizedBox(height: 10),

              // ==================================================
              // PHYSIOLOGICAL DATA
              // ==================================================

              _sectionTitle(
                "Physiological Measurements",
                Icons.monitor_heart,
                Colors.red,
              ),

              VitalCard(
                title: "Heart Rate",
                value:
                    "${data.heartRate} BPM",
                icon: Icons.favorite,
                color: Colors.red,
              ),

              VitalCard(
                title: "Heart Rate Variability",
                value:
                    "${data.hrv} ms",
                icon: Icons.timeline,
                color: Colors.purple,
              ),

              VitalCard(
                title: "SpO₂",
                value:
                    "${data.spo2} %",
                icon: Icons.water_drop,
                color: Colors.blue,
              ),

              // ==================================================
              // TEMPERATURE
              // ==================================================

              _sectionTitle(
                "Temperature Measurements",
                Icons.thermostat,
                Colors.orange,
              ),

              // --------------------------------------------------
              // BODY TEMPERATURE
              // MAX30205
              // --------------------------------------------------

              VitalCard(
                title: "Body Temperature",
                value:
                    "${data.bodyTemperature.toStringAsFixed(2)} °C",
                icon: Icons.thermostat,
                color: Colors.deepOrange,
              ),

              // --------------------------------------------------
              // ENVIRONMENT TEMPERATURE
              // DHT22
              // --------------------------------------------------

              VitalCard(
                title: "Environment Temperature",
                value:
                    "${data.environmentTemperature.toStringAsFixed(2)} °C",
                icon: Icons.home_work,
                color: Colors.orange,
              ),

              VitalCard(
                title: "Humidity",
                value:
                    "${data.humidity.toStringAsFixed(1)} %",
                icon: Icons.water_drop,
                color: Colors.cyan,
              ),

              // ==================================================
              // GAS SENSORS
              // ==================================================

              _sectionTitle(
                "Gas Sensors",
                Icons.air,
                Colors.brown,
              ),

              VitalCard(
                title: "MQ-2",
                value:
                    "${data.mq2}",
                icon: Icons.cloud,
                color: Colors.brown,
              ),

              VitalCard(
                title: "MQ-5",
                value:
                    "${data.mq5}",
                icon: Icons.gas_meter,
                color: Colors.deepPurple,
              ),

              VitalCard(
                title: "MQ-135",
                value:
                    "${data.mq135}",
                icon: Icons.air,
                color: Colors.blueGrey,
              ),

              // ==================================================
              // MOTION
              // ==================================================

              _sectionTitle(
                "Motion Measurements",
                Icons.directions_walk,
                Colors.green,
              ),

              VitalCard(
                title: "Acceleration Magnitude",
                value:
                    "${data.accMag.toStringAsFixed(2)} m/s²",
                icon: Icons.speed,
                color: Colors.green,
              ),

              VitalCard(
                title: "Gyroscope Magnitude",
                value:
                    "${data.gyroMag.toStringAsFixed(2)} rad/s",
                icon: Icons.screen_rotation,
                color:
                    Colors.lightGreen.shade700,
              ),

              // ==================================================
              // AI RESULTS
              // ==================================================

              _sectionTitle(
                "AI Health Analysis",
                Icons.psychology,
                Colors.deepPurple,
              ),

              // --------------------------------------------------
              // PREDICTION
              // --------------------------------------------------

              VitalCard(
                title: "AI Prediction",
                value:
                    data.prediction.isEmpty
                        ? "Unknown"
                        : data.prediction
                            .toUpperCase(),
                icon: Icons.psychology,
                color:
                    _predictionColor(
                  data.prediction,
                ),
              ),

              // --------------------------------------------------
              // RISK SCORE
              // --------------------------------------------------

              VitalCard(
                title: "Risk Score",
                value:
                    data.riskScore
                        .toStringAsFixed(3),
                icon:
                    Icons.warning_amber,
                color: Colors.redAccent,
              ),

              // --------------------------------------------------
              // ENVIRONMENT STRESS
              // --------------------------------------------------

              VitalCard(
                title: "Environment Stress",
                value:
                    data.environmentStress
                        .toStringAsFixed(3),
                icon:
                    Icons.thermostat_auto,
                color: Colors.orange,
              ),

              // --------------------------------------------------
              // ACTIVITY STRESS
              // --------------------------------------------------

              VitalCard(
                title: "Activity Stress",
                value:
                    data.activityStress
                        .toStringAsFixed(3),
                icon:
                    Icons.fitness_center,
                color:
                    Colors.deepPurple,
              ),

              const SizedBox(height: 25),

              // ==================================================
              // COMPLETED MESSAGE
              // ==================================================

              if (espState.isCompleted)
                Container(
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.green
                        .withOpacity(0.10),

                    borderRadius:
                        BorderRadius.circular(12),

                    border: Border.all(
                      color:
                          Colors.green,
                    ),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.check_circle,
                        color:
                            Colors.green,
                        size: 30,
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Text(
                          espState.message,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ==================================================
              // REFRESH INFORMATION
              // ==================================================

              Center(
                child: Text(
                  "Pull down to refresh",
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
      padding:
          const EdgeInsets.only(
        top: 15,
        bottom: 10,
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: color,
            size: 28,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              title,
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
  // PREDICTION COLOR
  // ============================================================

  Color _predictionColor(
    String prediction,
  ) {
    switch (
        prediction.toLowerCase()) {

      case "green":
        return Colors.green;

      case "yellow":
        return Colors.orange;

      case "red":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}


// =================================================================
// ESP32 STATUS CARD
// =================================================================

class ESPStatusCard extends StatelessWidget {

  final ESPStatus status;
  final String message;
  final int? progress;

  const ESPStatusCard({
    super.key,
    required this.status,
    required this.message,
    required this.progress,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final color =
        _statusColor(status);

    final icon =
        _statusIcon(status);

    return Card(
      elevation: 4,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------

            Row(
              children: [

                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      color.withOpacity(0.12),

                  child: Icon(
                    icon,
                    color: color,
                    size: 27,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "ESP32 Status",
                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        _statusTitle(status),
                        style:
                            TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),

                if (status ==
                    ESPStatus.measuring)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            // ----------------------------------------------------
            // MESSAGE
            // ----------------------------------------------------

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(12),

              decoration:
                  BoxDecoration(
                color:
                    color.withOpacity(0.06),

                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Text(
                message,
                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            // ----------------------------------------------------
            // PROGRESS
            // ----------------------------------------------------

            if (progress != null &&
                status ==
                    ESPStatus.measuring) ...[

              const SizedBox(
                height: 14,
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  const Text(
                    "Measurement Progress",
                    style:
                        TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    "$progress%",
                    style:
                        TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 7,
              ),

              LinearProgressIndicator(
                value:
                    progress!
                        .clamp(0, 100) /
                    100,

                minHeight: 7,

                backgroundColor:
                    Colors.grey.shade200,

                color: color,

                borderRadius:
                    BorderRadius.circular(10),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
    ESPStatus status,
  ) {
    switch (status) {

      case ESPStatus.idle:
        return Colors.blueGrey;

      case ESPStatus.waitingFinger:
        return Colors.blue;

      case ESPStatus.measuring:
        return Colors.orange;

      case ESPStatus.processingAI:
        return Colors.deepPurple;

      case ESPStatus.completed:
        return Colors.green;

      case ESPStatus.error:
        return Colors.red;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(
    ESPStatus status,
  ) {
    switch (status) {

      case ESPStatus.idle:
        return Icons.power_settings_new;

      case ESPStatus.waitingFinger:
        return Icons.touch_app;

      case ESPStatus.measuring:
        return Icons.monitor_heart;

      case ESPStatus.processingAI:
        return Icons.psychology;

      case ESPStatus.completed:
        return Icons.check_circle;

      case ESPStatus.error:
        return Icons.error;
    }
  }

  // ============================================================
  // STATUS TITLE
  // ============================================================

  String _statusTitle(
    ESPStatus status,
  ) {
    switch (status) {

      case ESPStatus.idle:
        return "READY";

      case ESPStatus.waitingFinger:
        return "WAITING FOR FINGER";

      case ESPStatus.measuring:
        return "MEASURING";

      case ESPStatus.processingAI:
        return "AI PROCESSING";

      case ESPStatus.completed:
        return "COMPLETED";

      case ESPStatus.error:
        return "ERROR";
    }
  }
}


// =================================================================
// VITAL CARD
// =================================================================

class VitalCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const VitalCard({
    super.key,
    required this.title,
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
          children: [

            // ----------------------------------------------------
            // ICON
            // ----------------------------------------------------

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

            const SizedBox(
              width: 15,
            ),

            // ----------------------------------------------------
            // TITLE
            // ----------------------------------------------------

            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            // ----------------------------------------------------
            // VALUE
            // ----------------------------------------------------

            Flexible(
              child: Text(
                value,
                textAlign:
                    TextAlign.right,

                style:
                    TextStyle(
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
