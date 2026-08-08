import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/worker_constants.dart';
import '../models/user_input.dart';
import '../providers/health_provider.dart';
import '../services/esp_service.dart';

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
  // SELECTED USER INFORMATION
  // ============================================================

  String worker =
      workerTypes.first;

  String activity =
      activities.first;

  String environment =
      environments.first;

  // ============================================================
  // UI STATE
  // ============================================================

  bool loading = false;

  String? errorMessage;

  // ============================================================
  // ESP SERVICE
  // ============================================================

  late final EspService espService;

  @override
  void initState() {
    super.initState();

    espService = EspService(
      baseUrl: 'http://192.168.1.12',
    );
  }

  // ============================================================
  // START MONITORING
  // ============================================================

  Future<void> _startMonitoring() async {

    if (loading) {
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {

      // ========================================================
      // BUILD USER INPUT
      // ========================================================

      final userInput = UserInput(

        userId:
            widget.userId,

        workerType:
            worker,

        activity:
            activity,

        environment:
            environment,
      );

      print('==========================================');
      print('STARTING MONITORING');
      print('USER ID: ${userInput.userId}');
      print('WORKER: ${userInput.workerType}');
      print('ACTIVITY: ${userInput.activity}');
      print('ENVIRONMENT: ${userInput.environment}');
      print('==========================================');

      // ========================================================
      // CONNECT TO ESP32
      // ========================================================

      final connected =
          await espService.testConnection();

      if (!connected) {

        if (!mounted) {
          return;
        }

        setState(() {
          loading = false;
          errorMessage =
              'Unable to connect to ESP32.\n'
              'Please check Wi-Fi connection.';
        });

        return;
      }

      // ========================================================
      // SEND USER DATA TO ESP32
      // ========================================================

      final started =
          await espService.startMonitoring(
        userInput,
      );

      if (!started) {

        if (!mounted) {
          return;
        }

        setState(() {
          loading = false;
          errorMessage =
              'ESP32 rejected the monitoring request.';
        });

        return;
      }

      // ========================================================
      // ALSO UPDATE HEALTH PROVIDER
      // ========================================================

      if (!mounted) {
        return;
      }

      final healthProvider =
          Provider.of<HealthProvider>(
        context,
        listen: false,
      );

      /*
       * Keep the selected worker information
       * inside HealthProvider as well.
       *
       * This assumes your HealthProvider already
       * contains startMonitoring(UserInput).
       */

      await healthProvider.startMonitoring(
        userInput,
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      // ========================================================
      // GO TO MAIN APPLICATION
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeNavigation(),
        ),
      );

    } catch (e) {

      print(
        'START MONITORING ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        errorMessage =
            'An error occurred while starting monitoring.';
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    espService.dispose();

    super.dispose();
  }

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

        prefixIcon: Icon(
          icon,
          color: Colors.blue,
        ),

        border:
            const OutlineInputBorder(),

        enabledBorder:
            const OutlineInputBorder(),

        focusedBorder:
            const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
      ),

      items: items.map(
        (item) {

          return DropdownMenuItem<String>(
            value: item,

            child: Text(
              item,
            ),
          );
        },
      ).toList(),

      onChanged:
          loading ? null : onChanged,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
          'Worker Setup',
        ),

        centerTitle:
            true,
      ),

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(20),

          child: Column(

            children: [

              // ==================================================
              // USER INFORMATION
              // ==================================================

              Card(

                elevation: 3,

                child: Padding(

                  padding:
                      const EdgeInsets.all(16),

                  child: Row(

                    children: [

                      const CircleAvatar(

                        radius: 28,

                        backgroundColor:
                            Colors.blue,

                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(
                        width: 15,
                      ),

                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(
                              'User ID',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              widget.userId,

                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // WORKER TYPE
              // ==================================================

              _buildDropdown(

                label:
                    'Worker Type',

                value:
                    worker,

                items:
                    workerTypes,

                icon:
                    Icons.person_outline,

                onChanged:
                    (value) {

                  if (value == null) {
                    return;
                  }

                  setState(() {
                    worker = value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // ACTIVITY
              // ==================================================

              _buildDropdown(

                label:
                    'Activity',

                value:
                    activity,

                items:
                    activities,

                icon:
                    Icons.directions_run,

                onChanged:
                    (value) {

                  if (value == null) {
                    return;
                  }

                  setState(() {
                    activity = value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // WORKPLACE / ENVIRONMENT
              // ==================================================

              _buildDropdown(

                label:
                    'Workplace / Environment',

                value:
                    environment,

                items:
                    environments,

                icon:
                    Icons.factory,

                onChanged:
                    (value) {

                  if (value == null) {
                    return;
                  }

                  setState(() {
                    environment = value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // ERROR MESSAGE
              // ==================================================

              if (errorMessage != null)

                Container(

                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(12),

                  decoration:
                      BoxDecoration(

                    color:
                        Colors.red.shade50,

                    borderRadius:
                        BorderRadius.circular(8),

                    border:
                        Border.all(
                      color:
                          Colors.red.shade200,
                    ),
                  ),

                  child: Row(

                    children: [

                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(

                        child: Text(
                          errorMessage!,

                          style:
                              const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // ==================================================
              // START BUTTON
              // ==================================================

              SizedBox(

                width:
                    double.infinity,

                height:
                    58,

                child:
                    ElevatedButton.icon(

                  onPressed:
                      loading
                          ? null
                          : _startMonitoring,

                  icon:

                      loading
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

                  label:

                      Text(
                    loading
                        ? 'CONNECTING TO ESP32...'
                        : 'START MONITORING',

                    style:
                        const TextStyle(
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

              // ==================================================
              // EXPLANATION
              // ==================================================

              const Text(

                'After starting monitoring, the ESP32 will '
                'wait for you to place your finger on the sensor.',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  color:
                      Colors.grey,

                  fontSize:
                      13,
                ),
              ),

              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
