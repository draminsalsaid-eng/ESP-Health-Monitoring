import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/esp_status.dart';
import '../models/user_input.dart';
import '../providers/health_provider.dart';

import 'home_navigation.dart';

class MonitoringScreen extends StatefulWidget {
  final UserInput userInput;

  const MonitoringScreen({
    super.key,
    required this.userInput,
  });

  @override
  State<MonitoringScreen> createState() =>
      _MonitoringScreenState();
}

class _MonitoringScreenState
    extends State<MonitoringScreen> {

  bool started = false;

  Future<void> _startMonitoring() async {
    setState(() {
      started = true;
    });

    final health =
        Provider.of<HealthProvider>(
      context,
      listen: false,
    );

    await health.startMonitoring(
      widget.userInput,
    );
  }

  @override
  Widget build(BuildContext context) {
    final health =
        Provider.of<HealthProvider>(
      context,
    );

    final esp = health.espState;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Monitoring',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              //================================
              // PROFILE
              //================================

              Card(
                elevation: 3,

                child: Padding(
                  padding:
                      const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        'Monitoring Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _infoRow(
                        'Worker',
                        widget.userInput.workerType,
                      ),

                      _infoRow(
                        'Activity',
                        widget.userInput.activity,
                      ),

                      _infoRow(
                        'Environment',
                        widget.userInput.environment,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //================================
              // STATUS ICON
              //================================

              _buildStatusIcon(esp),

              const SizedBox(height: 20),

              //================================
              // STATUS
              //================================

              Text(
                _statusTitle(esp),
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                esp.message,
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 25),

              //================================
              // PROGRESS
              //================================

              if (esp.isMeasuring &&
                  esp.progress != null) ...[
                LinearProgressIndicator(
                  value:
                      esp.progress! / 100,
                  minHeight: 10,
                  borderRadius:
                      BorderRadius.circular(10),
                ),

                const SizedBox(height: 10),

                Text(
                  '${esp.progress}%',

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],

              const Spacer(),

              //================================
              // START BUTTON
              //================================

              if (!started &&
                  esp.isIdle)

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed:
                        _startMonitoring,

                    child: const Text(
                      'START MONITORING',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              //================================
              // COMPLETED
              //================================

              if (esp.isCompleted &&
                  health.healthData != null)

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const HomeNavigation(),
                        ),
                      );
                    },

                    child: const Text(
                      'VIEW HEALTH DASHBOARD',

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              //================================
              // ERROR
              //================================

              if (esp.isError)

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        started = false;
                      });
                    },

                    child: const Text(
                      'TRY AGAIN',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),

      child: Row(
        children: [

          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(
    ESPState esp,
  ) {
    IconData icon;
    Color color;

    if (esp.isWaitingFinger) {
      icon = Icons.touch_app;
      color = Colors.orange;
    }

    else if (esp.isMeasuring) {
      icon = Icons.monitor_heart;
      color = Colors.red;
    }

    else if (esp.isProcessingAI) {
      icon = Icons.psychology;
      color = Colors.blue;
    }

    else if (esp.isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green;
    }

    else if (esp.isError) {
      icon = Icons.error;
      color = Colors.red;
    }

    else {
      icon = Icons.health_and_safety;
      color = Colors.blue;
    }

    return CircleAvatar(
      radius: 45,

      backgroundColor:
          color.withOpacity(0.12),

      child: Icon(
        icon,
        size: 55,
        color: color,
      ),
    );
  }

  String _statusTitle(
    ESPState esp,
  ) {
    if (esp.isWaitingFinger) {
      return 'Place Your Finger';
    }

    if (esp.isMeasuring) {
      return 'Measuring';
    }

    if (esp.isProcessingAI) {
      return 'AI Analysis';
    }

    if (esp.isCompleted) {
      return 'Measurement Completed';
    }

    if (esp.isError) {
      return 'Measurement Error';
    }

    if (!started) {
      return 'Ready';
    }

    return 'Connecting';
  }
}
