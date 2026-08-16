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

          padding: const EdgeInsets.all(16),

          children: [

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              "Health Monitoring Results",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Latest completed measurement",
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
                "Worker Profile",
                Icons.person,
                Colors.blue,
              ),

              VitalCard(
                title: "Worker Type",
                value: data.workerType,
                icon: Icons.badge,
                color: Colors.blue,
              ),

              VitalCard(
                title: "Activity",
                value: data.activity,
                icon: Icons.directions_run,
                color: Colors.indigo,
              ),

              VitalCard(
                title: "Environment",
                value: data.environment,
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
                "Temperature",
                Icons.thermostat,
                Colors.orange,
              ),

              // BODY TEMPERATURE
              VitalCard(
                title: "Body Temperature",
                value:
                    "${data.bodyTemperature.toStringAsFixed(2)} °C",
                icon: Icons.thermostat,
                color: Colors.deepOrange,
              ),

              // ENVIRONMENT TEMPERATURE
              VitalCard(
                title: "Environment Temperature",
                value:
                    "${data.environmentTemperature.toStringAsFixed(2)} °C",
                icon: Icons.home_work,
                color: Colors.orange,
              ),

              // HUMIDITY
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
                color: Colors.lightGreen.shade700,
              ),

              // ==================================================
              // AI RESULTS
              // ==================================================

              _sectionTitle(
                "AI Health Analysis",
                Icons.psychology,
                Colors.deepPurple,
              ),

              // Prediction
              VitalCard(
                title: "AI Prediction",
                value:
                    data.prediction.isEmpty
                        ? "Unknown"
                        : data.prediction.toUpperCase(),
                icon: Icons.psychology,
                color:
                    _predictionColor(
                      data.prediction,
                    ),
              ),

              VitalCard(
                title: "Risk Score",
                value:
                    data.riskScore.toStringAsFixed(3),
                icon: Icons.warning_amber,
                color: Colors.redAccent,
              ),

              VitalCard(
                title: "Environment Stress",
                value:
                    data.environmentStress
                        .toStringAsFixed(3),
                icon: Icons.thermostat_auto,
                color: Colors.orange,
              ),

              VitalCard(
                title: "Activity Stress",
                value:
                    data.activityStress
                        .toStringAsFixed(3),
                icon: Icons.fitness_center,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // REFRESH INFORMATION
              // ==================================================

              Center(
                child: Text(
                  "Pull down to refresh",
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
        children: [

          Icon(
            icon,
            color: color,
            size: 28,
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
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


// ================================================================
// VITAL CARD
// ================================================================

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

      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(

        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        child: Row(

          children: [

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

            Expanded(

              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Flexible(

              child: Text(

                value,

                textAlign:
                    TextAlign.right,

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
