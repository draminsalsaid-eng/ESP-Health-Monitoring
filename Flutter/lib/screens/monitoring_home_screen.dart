import 'package:flutter/material.dart';

import 'worker_setup_screen.dart';

class MonitoringHomeScreen extends StatelessWidget {
  final String userId;

  const MonitoringHomeScreen({
    super.key,
    required this.userId,
  });

  void _startMonitoring(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerSetupScreen(
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ESP Health Monitoring",
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const SizedBox(height: 30),

              // System icon
              Container(
                width: 110,
                height: 110,

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.health_and_safety,
                  size: 70,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Health Monitoring System",
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Welcome, User $userId",
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 35),

              Card(
                elevation: 3,

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      const Icon(
                        Icons.monitor_heart,
                        size: 45,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Start a new health monitoring session",
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "You will first enter the worker profile, "
                        "then the ESP32 measurement process will begin.",
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton.icon(
                  onPressed: () {
                    _startMonitoring(context);
                  },

                  icon: const Icon(
                    Icons.play_arrow,
                    size: 30,
                  ),

                  label: const Text(
                    "START MONITORING",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
