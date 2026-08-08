import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'monitoring_screen.dart';
import '../constants/worker_constants.dart';
import '../models/user_input.dart';
import '../providers/health_provider.dart';

import 'measurement_screen.dart';

class WorkerSetupScreen extends StatefulWidget {
  final String userId;

  const WorkerSetupScreen({
    super.key,
    required this.userId,
  });

  @override
  State<WorkerSetupScreen> createState() =>
      _WorkerSetupScreenState();
}

class _WorkerSetupScreenState
    extends State<WorkerSetupScreen> {

  String worker = workerTypes.first;
  String activity = activities.first;
  String environment = environments.first;

  bool loading = false;

  Future<void> _startMeasurement() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    final health =
        Provider.of<HealthProvider>(
      context,
      listen: false,
    );

    final userInput = UserInput(
      userId: widget.userId,
      workerType: worker,
      activity: activity,
      environment: environment,
    );

    /*
     * This starts the real monitoring communication:
     *
     * Flutter
     *   ↓
     * ESP32 /start
     *   ↓
     * ESP32 stores worker profile
     *   ↓
     * Flutter polls /health
     */
    await health.startMonitoring(userInput);

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    /*
     * Move to the live measurement screen.
     *
     * The measurement screen will now listen to
     * HealthProvider and display the current status.
     */
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MeasurementScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Worker Profile",
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Measurement Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "User ID: ${widget.userId}",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 25),

              DropdownButtonFormField<String>(
                value: worker,

                decoration: const InputDecoration(
                  labelText: "Worker Type",
                  prefixIcon: Icon(
                    Icons.person,
                  ),
                  border: OutlineInputBorder(),
                ),

                items: workerTypes.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),

                onChanged: loading
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          worker = value;
                        });
                      },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: activity,

                decoration: const InputDecoration(
                  labelText: "Activity",
                  prefixIcon: Icon(
                    Icons.directions_run,
                  ),
                  border: OutlineInputBorder(),
                ),

                items: activities.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),

                onChanged: loading
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          activity = value;
                        });
                      },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: environment,

                decoration: const InputDecoration(
                  labelText: "Working Place",
                  prefixIcon: Icon(
                    Icons.factory,
                  ),
                  border: OutlineInputBorder(),
                ),

                items: environments.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),

                onChanged: loading
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          environment = value;
                        });
                      },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton.icon(
                  onPressed:
                      loading ? null : _startMeasurement,

                  icon: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 30,
                        ),

                  label: Text(
                    loading
                        ? "CONNECTING TO ESP32..."
                        : "START MEASUREMENT",

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "The selected profile will be sent to ESP32.",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
```
