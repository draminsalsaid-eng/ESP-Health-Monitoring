import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/esp_status.dart';
import '../models/user_input.dart';
import '../providers/health_provider.dart';

import 'dashboard_screen.dart';

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

    // ==========================================================
    // START MONITORING AFTER SCREEN IS CREATED
    // ==========================================================

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      Provider.of<HealthProvider>(
        context,
        listen: false,
      ).startMonitoring(
        widget.userInput,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final health =
        Provider.of<HealthProvider>(context);

    final ESPState esp =
        health.espState;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Monitoring',
        ),
        centerTitle: true,

        // Prevent going back while measurement
        // is running.
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              // ==================================================
              // MONITORING PROFILE
              // ==================================================

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
                height: 30,
              ),

              // ==================================================
              // STATUS ICON
              // ==================================================

              _buildStatusIcon(esp),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // STATUS TITLE
              // ==================================================

              Text(
                _statusTitle(esp),

                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // STATUS MESSAGE
              // ==================================================

              Text(
                esp.message,

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 17,
                  color:
                      Colors.grey.shade700,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // MEASUREMENT PROGRESS
              // ==================================================

              if (esp.isMeasuring) ...[
                if (esp.progress != null) ...[
                  LinearProgressIndicator(
                    value:
                        (esp.progress! / 100)
                            .clamp(0.0, 1.0),

                    minHeight: 10,

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    '${esp.progress}%',

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  const LinearProgressIndicator(
                    minHeight: 10,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'Measuring...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ],

              // ==================================================
              // WAITING FOR FINGER
              // ==================================================

              if (esp.isWaitingFinger) ...[
                const SizedBox(
                  height: 15,
                ),

                _buildFingerInstructions(),
              ],

              // ==================================================
              // AI PROCESSING
              // ==================================================

              if (esp.isProcessingAI) ...[
                const SizedBox(
                  height: 10,
                ),

                const LinearProgressIndicator(
                  minHeight: 8,
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  'Please wait while the AI analyzes the measurements...',
                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 15,
                    color:
                        Colors.grey.shade700,
                  ),
                ),
              ],

              // ==================================================
              // IDLE / CONNECTING
              // ==================================================

              if (esp.isIdle) ...[
                const SizedBox(
                  height: 15,
                ),

                const CircularProgressIndicator(),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  esp.message,
                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 15,
                    color:
                        Colors.grey.shade700,
                  ),
                ),
              ],

              const Spacer(),

              // ==================================================
              // COMPLETED
              // ==================================================

              if (esp.isCompleted &&
                  health.healthData != null)
                SizedBox(
                  width:
                      double.infinity,

                  height: 55,

                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DashboardScreen(),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.check_circle,
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

              // ==================================================
              // ERROR
              // ==================================================

              if (esp.isError)
                Column(
                  children: [

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(
                        15,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.red
                            .withOpacity(0.08),

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),

                        border: Border.all(
                          color:
                              Colors.red
                                  .withOpacity(
                            0.3,
                          ),
                        ),
                      ),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Text(
                              esp.message,

                              style:
                                  const TextStyle(
                                color:
                                    Colors.red,
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    SizedBox(
                      width:
                          double.infinity,

                      height: 55,

                      child:
                          ElevatedButton(
                        onPressed: () {
                          Provider.of<
                              HealthProvider>(
                            context,
                            listen: false,
                          ).reset();

                          Navigator.pop(
                            context,
                          );
                        },

                        child: const Text(
                          'BACK',

                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
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
              value.isEmpty
                  ? 'Not specified'
                  : value,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FINGER INSTRUCTIONS
  // ============================================================

  Widget _buildFingerInstructions() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
            Colors.orange.withOpacity(
          0.08,
        ),

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color:
              Colors.orange.withOpacity(
            0.3,
          ),
        ),
      ),

      child: Column(
        children: [

          const Icon(
            Icons.touch_app,
            size: 45,
            color: Colors.orange,
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'Place your finger on both sensors',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            'Keep your finger still until the measurement is complete.',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 14,
              color:
                  Colors.grey.shade700,
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

    // ----------------------------------------------------------
    // WAITING FOR FINGER
    // ----------------------------------------------------------

    if (esp.isWaitingFinger) {
      icon = Icons.touch_app;
      color = Colors.orange;
    }

    // ----------------------------------------------------------
    // MEASURING
    // ----------------------------------------------------------

    else if (esp.isMeasuring) {
      icon = Icons.monitor_heart;
      color = Colors.red;
    }

    // ----------------------------------------------------------
    // AI PROCESSING
    // ----------------------------------------------------------

    else if (esp.isProcessingAI) {
      icon = Icons.psychology;
      color = Colors.blue;
    }

    // ----------------------------------------------------------
    // COMPLETED
    // ----------------------------------------------------------

    else if (esp.isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green;
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    else if (esp.isError) {
      icon = Icons.error;
      color = Colors.red;
    }

    // ----------------------------------------------------------
    // IDLE / CONNECTING
    // ----------------------------------------------------------

    else {
      icon = Icons.health_and_safety;
      color = Colors.blue;
    }

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 300),

      width: 100,
      height: 100,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: color.withOpacity(
          0.12,
        ),

        border: Border.all(
          color: color.withOpacity(
            0.25,
          ),

          width: 2,
        ),
      ),

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

    return 'Connecting to ESP32';
  }
}
