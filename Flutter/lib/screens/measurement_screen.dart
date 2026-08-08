```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';

class MeasurementScreen extends StatelessWidget {
  const MeasurementScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Health Measurement",
          ),
          centerTitle: true,
        ),

        body: Consumer<HealthProvider>(
          builder: (
            context,
            health,
            child,
          ) {
            final data = health.healthData;

            final stateText =
                health.state.toString();

            final isWaiting =
                stateText.contains(
              "waitingSensor",
            );

            final isConnecting =
                stateText.contains(
              "connecting",
            );

            final isError =
                stateText.contains(
              "error",
            );

            final isCompleted =
                data != null &&
                stateText.contains(
                  "success",
                );

            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    _StatusIcon(
                      isWaiting: isWaiting,
                      isError: isError,
                      isCompleted: isCompleted,
                    ),

                    const SizedBox(height: 25),

                    Text(
                      _getTitle(
                        isWaiting:
                            isWaiting,
                        isError:
                            isError,
                        isCompleted:
                            isCompleted,
                        isConnecting:
                            isConnecting,
                      ),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _getMessage(
                        isWaiting:
                            isWaiting,
                        isError:
                            isError,
                        isCompleted:
                            isCompleted,
                        isConnecting:
                            isConnecting,
                        state:
                            stateText,
                      ),

                      textAlign:
                          TextAlign.center,

                      style:
                          TextStyle(
                        fontSize: 16,
                        color:
                            Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 35),

                    if (isWaiting)
                      _FingerInstruction(),

                    if (!isWaiting &&
                        !isError &&
                        !isCompleted)
                      const _ProgressSection(),

                    if (isError)
                      _ErrorSection(
                        message:
                            stateText,
                      ),

                    if (isCompleted &&
                        data != null)
                      _ResultPreview(
                        data: data,
                      ),

                    const Spacer(),

                    if (isCompleted)
                      SizedBox(
                        width:
                            double.infinity,
                        height: 55,

                        child:
                            ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },

                          child:
                              const Text(
                            "VIEW DASHBOARD",
                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTitle({
    required bool isWaiting,
    required bool isError,
    required bool isCompleted,
    required bool isConnecting,
  }) {
    if (isError) {
      return "Measurement Error";
    }

    if (isCompleted) {
      return "Measurement Completed";
    }

    if (isWaiting) {
      return "Place Your Finger";
    }

    if (isConnecting) {
      return "Connecting to ESP32";
    }

    return "Measurement in Progress";
  }

  String _getMessage({
    required bool isWaiting,
    required bool isError,
    required bool isCompleted,
    required bool isConnecting,
    required String state,
  }) {
    if (isError) {
      return "The ESP32 or network connection "
          "reported an error.";
    }

    if (isCompleted) {
      return "Your health measurement and AI "
          "analysis are ready.";
    }

    if (isWaiting) {
      return "Place your finger on MAX30105 "
          "and keep it steady.";
    }

    if (isConnecting) {
      return "Connecting to the ESP32 and "
          "preparing the sensors...";
    }

    return "Please keep your finger steady. "
        "The sensors are collecting data.";
  }
}


//======================================================
// STATUS ICON
//======================================================

class _StatusIcon extends StatelessWidget {
  final bool isWaiting;
  final bool isError;
  final bool isCompleted;

  const _StatusIcon({
    required this.isWaiting,
    required this.isError,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (isError) {
      icon = Icons.error;
      color = Colors.red;
    } else if (isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (isWaiting) {
      icon = Icons.touch_app;
      color = Colors.orange;
    } else {
      icon = Icons.monitor_heart;
      color = Colors.blue;
    }

    return Container(
      width: 130,
      height: 130,

      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        shape: BoxShape.circle,
      ),

      child: Icon(
        icon,
        size: 75,
        color: color,
      ),
    );
  }
}


//======================================================
// FINGER INSTRUCTION
//======================================================

class _FingerInstruction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      elevation: 3,

      child: Padding(
        padding:
            const EdgeInsets.all(22),

        child: Column(
          children: [
            const Icon(
              Icons.fingerprint,
              size: 70,
              color: Colors.orange,
            ),

            const SizedBox(height: 15),

            const Text(
              "PLACE YOUR FINGER",
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Place your finger on the "
              "MAX30105 sensor and keep "
              "your hand still.",
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 15,
                color:
                    Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//======================================================
// PROGRESS
//======================================================

class _ProgressSection
    extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(
          strokeWidth: 5,
        ),

        const SizedBox(height: 20),

        Text(
          "Reading sensors...",
          style: TextStyle(
            fontSize: 16,
            color:
                Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "MAX30105 • MAX30205 • MPU6050",
          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}


//======================================================
// ERROR
//======================================================

class _ErrorSection
    extends StatelessWidget {
  final String message;

  const _ErrorSection({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          children: [
            const Icon(
              Icons.wifi_off,
              size: 50,
              color: Colors.red,
            ),

            const SizedBox(height: 10),

            const Text(
              "Connection / Measurement Error",
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//======================================================
// RESULT PREVIEW
//======================================================

class _ResultPreview
    extends StatelessWidget {
  final dynamic data;

  const _ResultPreview({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.green,
                ),

                SizedBox(width: 10),

                Text(
                  "Final Health Data",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(
              height: 25,
            ),

            _ResultRow(
              title: "Heart Rate",
              value:
                  "${data.heartRate} BPM",
            ),

            _ResultRow(
              title: "SpO₂",
              value:
                  "${data.spo2} %",
            ),

            _ResultRow(
              title: "Temperature",
              value:
                  "${data.temperature} °C",
            ),

            _ResultRow(
              title: "AI Status",
              value:
                  "${data.aiStatus}",
            ),
          ],
        ),
      ),
    );
  }
}


class _ResultRow
    extends StatelessWidget {
  final String title;
  final String value;

  const _ResultRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```
