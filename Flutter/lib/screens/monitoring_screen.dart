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

  @override
  Widget build(BuildContext context) {
    final health = Provider.of<HealthProvider>(
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

              // ================================================
              // PROFILE
              // ================================================

              Card(
                elevation: 3,

                child: Padding(
                  padding: const EdgeInsets.all(18),

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

                      const SizedBox(
                        height: 15,
                      ),

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

              const SizedBox(
                height: 25,
              ),

              // ================================================
              // STATUS ICON
              // ================================================

              _buildStatusIcon(esp),

              const SizedBox(
                height: 20,
              ),

              // ================================================
              // STATUS TITLE
              // ================================================

              Text(
                _statusTitle(esp),

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ================================================
              // STATUS MESSAGE
              // ================================================

              Text(
                esp.message,

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ================================================
              // PROGRESS
              // ================================================

              if (esp.isMeasuring &&
                  esp.progress != null) ...[

                LinearProgressIndicator(
                  value: esp.progress! / 100,

                  minHeight: 10,

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  '${esp.progress}%',

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],

              const Spacer(),

              // ================================================
              // WAITING FOR FINGER INFORMATION
              // ================================================

              if (esp.isWaitingFinger)

                Card(
                  color: Colors.orange.shade50,

                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),

                    child: Row(
                      children: [

                        Icon(
                          Icons.touch_app,
                          color: Colors.orange.shade800,
                          size: 32,
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Text(
                            'Place your finger on the '
                            'MAX30105 and MAX30205 sensors.',

                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  Colors.orange.shade900,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ================================================
              // COMPLETED
              // ================================================

              if (esp.isCompleted &&
                  health.healthData != null)

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: () {

                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const HomeNavigation(),
                        ),
                      );

                    },

                    icon: const Icon(
                      Icons.dashboard,
                    ),

                    label: const Text(
                      'VIEW HEALTH DASHBOARD',

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // ================================================
              // ERROR
              // ================================================

              if (esp.isError)

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: () {

                      Navigator.pop(context);

                    },

                    icon: const Icon(
                      Icons.arrow_back,
                    ),

                    label: const Text(
                      'BACK',
                    ),
                  ),
                ),

              // ================================================
              // PROCESSING AI
              // ================================================

              if (esp.isProcessingAI)

                Card(
                  color: Colors.blue.shade50,

                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),

                    child: Row(
                      children: [

                        const SizedBox(
                          width: 24,
                          height: 24,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),

                        const SizedBox(
                          width: 15,
                        ),

                        Expanded(
                          child: Text(
                            'The AI is analyzing your '
                            'health data. Please wait...',

                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(
    String title,
    String value,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),

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
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  Widget _buildStatusIcon(
    ESPState esp,
  ) {

    IconData icon;
    Color color;

    // ============================================
    // WAITING FOR FINGER
    // ============================================

    if (esp.isWaitingFinger) {

      icon = Icons.touch_app;
      color = Colors.orange;
    }

    // ============================================
    // MEASURING
    // ============================================

    else if (esp.isMeasuring) {

      icon = Icons.monitor_heart;
      color = Colors.red;
    }

    // ============================================
    // AI PROCESSING
    // ============================================

    else if (esp.isProcessingAI) {

      icon = Icons.psychology;
      color = Colors.blue;
    }

    // ============================================
    // COMPLETED
    // ============================================

    else if (esp.isCompleted) {

      icon = Icons.check_circle;
      color = Colors.green;
    }

    // ============================================
    // ERROR
    // ============================================

    else if (esp.isError) {

      icon = Icons.error;
      color = Colors.red;
    }

    // ============================================
    // DEFAULT
    // ============================================

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

  // ============================================================
  // STATUS TITLE
  // ============================================================

  String _statusTitle(
    ESPState esp,
  ) {

    // ============================================
    // WAITING FOR FINGER
    // ============================================

    if (esp.isWaitingFinger) {

      return 'Place Your Finger';
    }

    // ============================================
    // MEASURING
    // ============================================

    if (esp.isMeasuring) {

      return 'Measuring';
    }

    // ============================================
    // AI ANALYSIS
    // ============================================

    if (esp.isProcessingAI) {

      return 'AI Analysis';
    }

    // ============================================
    // COMPLETED
    // ============================================

    if (esp.isCompleted) {

      return 'Measurement Completed';
    }

    // ============================================
    // ERROR
    // ============================================

    if (esp.isError) {

      return 'Measurement Error';
    }

    // ============================================
    // DEFAULT
    // ============================================

    return 'Connecting to ESP32...';
  }
}
