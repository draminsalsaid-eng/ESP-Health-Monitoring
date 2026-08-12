import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/worker_constants.dart';
import '../models/user_input.dart';
import '../providers/health_provider.dart';
import 'monitoring_screen.dart';
import 'home_navigation.dart';

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

  // ============================================================
  // USER SELECTIONS
  // ============================================================

  String worker =
      workerTypes.first;

  String activity =
      activities.first;

  String environment =
      environments.first;

  // ============================================================
  // LOCAL LOADING
  // ============================================================

  bool loading = false;

  // ============================================================
  // START MONITORING
  // ============================================================

  Future<void> _startMonitoring() async {
    if (loading) {
      return;
    }

    setState(() {
      loading = true;
    });

    final health =
        Provider.of<HealthProvider>(
      context,
      listen: false,
    );

    // ==========================================================
    // CREATE USER INPUT
    // ==========================================================

    final userInput = UserInput(
      userId: widget.userId,
      workerType: worker,
      activity: activity,
      environment: environment,
    );

    // ==========================================================
    // START ESP32 MONITORING
    // ==========================================================

    final success =
        await health.startMonitoring(
      userInput,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      loading = false;
    });

    // ==========================================================
    // IF ESP32 CONNECTION FAILED
    // ==========================================================

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            health.state.message,
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ==========================================================
    // SUCCESS
    //
    // At this point:
    //
    // Flutter
    //    ↓
    // ESP32 connected
    //    ↓
    // User data sent
    //    ↓
    // ESP32 waiting for finger
    //
    // ==========================================================

   Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => MonitoringScreen(
      userInput: userInput,
    ),
  ),
);

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),

      items: items.map(
        (item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item.replaceAll('_', ' '),
            ),
          );
        },
      ).toList(),

      onChanged: loading
          ? null
          : onChanged,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Worker Setup',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [

              // ==================================================
              // HEADER
              // ==================================================

              const Icon(
                Icons.health_and_safety,
                size: 70,
                color: Colors.blue,
              ),

              const SizedBox(
                height: 12,
              ),

              const Text(
                'Prepare Monitoring Session',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'User ID: ${widget.userId}',
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // WORKER TYPE
              // ==================================================

              _buildDropdown(
                label: 'Worker Type',
                value: worker,
                items: workerTypes,
                icon: Icons.person,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    worker = value;
                  });
                },
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // ACTIVITY
              // ==================================================

              _buildDropdown(
                label: 'Activity',
                value: activity,
                items: activities,
                icon: Icons.directions_run,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    activity = value;
                  });
                },
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // WORKPLACE
              // ==================================================

              _buildDropdown(
                label: 'Workplace',
                value: environment,
                items: environments,
                icon: Icons.factory,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    environment = value;
                  });
                },
              ),

              const Spacer(),

              // ==================================================
              // CURRENT SELECTION SUMMARY
              // ==================================================

              Card(
                elevation: 2,

                child: Padding(
                  padding:
                      const EdgeInsets.all(14),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Monitoring Profile',

                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Worker: '
                        '${worker.replaceAll('_', ' ')}',
                      ),

                      Text(
                        'Activity: '
                        '${activity.replaceAll('_', ' ')}',
                      ),

                      Text(
                        'Workplace: '
                        '${environment.replaceAll('_', ' ')}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // ==================================================
              // START MONITORING BUTTON
              // ==================================================

              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed:
                      loading
                          ? null
                          : _startMonitoring,

                  icon: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.play_arrow,
                        ),

                  label: Text(
                    loading
                        ? 'CONNECTING TO ESP32...'
                        : 'START MONITORING',

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                'Press Start Monitoring to connect '
                'to the ESP32 and begin the measurement session.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
