```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/esp_status.dart';
import '../models/user_input.dart';


// ============================================================
// HEALTH PROVIDER
// ============================================================
//
// Flutter
//    |
//    | POST /start
//    v
// ESP32
//    |
//    | GET /health
//    v
// Flutter
//
// States:
//
// idle
// connecting
// waiting_finger
// measuring
// processing
// completed
// finger_removed
// error
// wifi_error
//
// ============================================================

class HealthProvider extends ChangeNotifier {

  // ==========================================================
  // ESP32 IP ADDRESS
  // ==========================================================
  //
  // IMPORTANT:
  //
  // Look at ESP32 Serial Monitor.
  //
  // Example:
  //
  // IP Address: 192.168.1.105
  //
  // Then change this to:
  //
  // http://192.168.1.105
  //
  // ==========================================================

  static const String esp32BaseUrl =
      'http://192.168.1.12';


  // ==========================================================
  // HTTP TIMEOUTS
  // ==========================================================

  static const Duration startTimeout =
      Duration(seconds: 5);

  static const Duration healthTimeout =
      Duration(seconds: 5);


  // ==========================================================
  // ESP STATE
  // ==========================================================

  ESPState _espState = ESPState(
    status: 'idle',
    message: 'Ready',
    progress: null,
  );


  ESPState get espState => _espState;


  // ==========================================================
  // FINAL HEALTH DATA
  // ==========================================================

  Map<String, dynamic>? _healthData;


  Map<String, dynamic>? get healthData =>
      _healthData;


  // ==========================================================
  // CONNECTION
  // ==========================================================

  bool _connected = false;


  bool get connected =>
      _connected;


  // ==========================================================
  // MONITORING
  // ==========================================================

  bool _monitoring = false;


  bool get isMonitoring =>
      _monitoring;


  // ==========================================================
  // POLLING TIMER
  // ==========================================================

  Timer? _healthTimer;


  // ==========================================================
  // START MONITORING
  // ==========================================================
  //
  // Called by WorkerSetupScreen.
  //
  // This function:
  //
  // 1. Sends worker information to ESP32.
  // 2. Waits for {"status":"ok"}.
  // 3. Starts health polling.
  //
  // ==========================================================

  Future<bool> startMonitoring(
    UserInput userInput,
  ) async {

    // --------------------------------------------------------
    // Prevent duplicate monitoring sessions
    // --------------------------------------------------------

    if (_monitoring) {

      debugPrint(
        'Monitoring is already active.',
      );

      return true;
    }


    // --------------------------------------------------------
    // Stop previous polling
    // --------------------------------------------------------

    _stopHealthPolling();


    // --------------------------------------------------------
    // Reset old result
    // --------------------------------------------------------

    _healthData = null;

    _connected = false;

    _monitoring = false;


    _setESPState(
      status: 'connecting',
      message: 'Connecting to ESP32...',
      progress: null,
    );


    try {

      // ======================================================
      // START URL
      // ======================================================

      final Uri uri = Uri.parse(
        '$esp32BaseUrl/start',
      );


      // ======================================================
      // JSON BODY
      // ======================================================

      final Map<String, dynamic> requestData = {

        'worker_type':
            userInput.workerType,

        'activity':
            userInput.activity,

        'environment':
            userInput.environment,
      };


      final String requestBody =
          jsonEncode(
        requestData,
      );


      // ======================================================
      // DEBUG
      // ======================================================

      debugPrint(
        '=========================================',
      );

      debugPrint(
        'ESP32 START REQUEST',
      );

      debugPrint(
        'URL: $uri',
      );

      debugPrint(
        'BODY: $requestBody',
      );

      debugPrint(
        '=========================================',
      );


      // ======================================================
      // POST /start
      // ======================================================

      final http.Response response =
          await http
              .post(
                uri,

                headers: {
                  'Content-Type':
                      'application/json',

                  'Accept':
                      'application/json',
                },

                body: requestBody,
              )
              .timeout(
                startTimeout,
              );


      // ======================================================
      // DEBUG RESPONSE
      // ======================================================

      debugPrint(
        'ESP32 START RESPONSE',
      );

      debugPrint(
        'HTTP STATUS: ${response.statusCode}',
      );

      debugPrint(
        'BODY: ${response.body}',
      );


      // ======================================================
      // CHECK HTTP STATUS
      // ======================================================

      if (response.statusCode != 200) {

        _setESPState(
          status: 'error',
          message:
              'ESP32 returned HTTP ${response.statusCode}',
          progress: null,
        );

        return false;
      }


      // ======================================================
      // PARSE RESPONSE
      // ======================================================

      Map<String, dynamic> responseData;


      try {

        responseData =
            jsonDecode(
              response.body,
            ) as Map<String, dynamic>;

      } catch (e) {

        debugPrint(
          'START JSON ERROR: $e',
        );


        _setESPState(
          status: 'error',
          message:
              'Invalid JSON response from ESP32',
          progress: null,
        );


        return false;
      }


      // ======================================================
      // READ STATUS
      // ======================================================

      final String status =
          responseData['status']
              ?.toString()
              .trim()
              .toLowerCase() ??
          '';


      // ======================================================
      // ESP32 SHOULD RETURN:
      //
      // {
      //   "status":"ok"
      // }
      //
      // ======================================================

      if (status != 'ok') {

        final String message =
            responseData['message']
                ?.toString() ??
            'ESP32 rejected the request';


        _setESPState(
          status: 'error',
          message: message,
          progress: null,
        );


        return false;
      }


      // ======================================================
      // ESP32 CONNECTION SUCCESS
      // ======================================================

      _connected = true;

      _monitoring = true;


      // ======================================================
      // IMPORTANT
      //
      // ESP32 handleStart() immediately changes its state to:
      //
      // waiting_finger
      //
      // Therefore Flutter displays:
      //
      // Place Your Finger
      //
      // ======================================================

      _setESPState(
        status: 'waiting_finger',
        message:
            'Place finger on both sensors',
        progress: null,
      );


      // ======================================================
      // START POLLING /health
      // ======================================================

      _startHealthPolling();


      return true;


    } on TimeoutException {

      debugPrint(
        'ESP32 /start timeout',
      );


      _setESPState(
        status: 'error',
        message:
            'Connection to ESP32 timed out',
        progress: null,
      );


      return false;


    } catch (e) {

      debugPrint(
        'ESP32 /start ERROR: $e',
      );


      _setESPState(
        status: 'error',
        message:
            'Could not connect to ESP32',
        progress: null,
      );


      return false;
    }
  }


  // ==========================================================
  // GET HEALTH STATUS
  // ==========================================================
  //
  // GET:
  //
  // /health
  //
  // Examples:
  //
  // {
  //   "status":"waiting_finger",
  //   "message":"Place finger on both sensors"
  // }
  //
  // {
  //   "status":"measuring",
  //   "progress":45,
  //   "message":"Reading sensors"
  // }
  //
  // {
  //   "status":"processing",
  //   "message":"AI is analyzing health data"
  // }
  //
  // Final:
  //
  // {
  //   "HR":75,
  //   "HRV":40,
  //   "SpO2":98,
  //   "body_temp":36.8,
  //   "env_temp":25.0,
  //   "humidity":50,
  //   "MQ2":100,
  //   "MQ5":120,
  //   "MQ135":140,
  //   "acc_mag":9.8,
  //   "gyro_mag":0.5,
  //   "alert_level":"green",
  //   "risk_level":"low",
  //   "status":"completed",
  //   "message":"Measurement completed"
  // }
  //
  // ==========================================================

  Future<void> checkHealth() async {

    try {

      final Uri uri = Uri.parse(
        '$esp32BaseUrl/health',
      );


      final http.Response response =
          await http
              .get(
                uri,

                headers: {
                  'Accept':
                      'application/json',
                },
              )
              .timeout(
                healthTimeout,
              );


      debugPrint(
        'ESP32 /health HTTP: '
        '${response.statusCode}',
      );

      debugPrint(
        'ESP32 /health BODY: '
        '${response.body}',
      );


      // ======================================================
      // HTTP ERROR
      // ======================================================

      if (response.statusCode != 200) {

        debugPrint(
          'ESP32 /health returned '
          '${response.statusCode}',
        );

        return;
      }


      // ======================================================
      // PARSE JSON
      // ======================================================

      Map<String, dynamic> data;


      try {

        data =
            jsonDecode(
              response.body,
            ) as Map<String, dynamic>;

      } catch (e) {

        debugPrint(
          'HEALTH JSON ERROR: $e',
        );

        return;
      }


      // ======================================================
      // STATUS
      // ======================================================

      final String status =
          data['status']
              ?.toString()
              .trim()
              .toLowerCase() ??
          '';


      // ======================================================
      // MESSAGE
      // ======================================================

      final String message =
          data['message']
              ?.toString() ??
          '';


      // ======================================================
      // PROGRESS
      // ======================================================

      final int? progress =
          _parseProgress(
            data['progress'],
          );


      // ======================================================
      // SAVE STATE
      // ======================================================

      _espState = ESPState(
        status: status,
        message: message,
        progress: progress,
      );


      notifyListeners();


      // ======================================================
      // COMPLETED
      // ======================================================

      if (status == 'completed') {

        // ----------------------------------------------------
        // Save complete final JSON.
        //
        // We intentionally save the WHOLE JSON,
        // not only physiological values.
        //
        // ----------------------------------------------------

        _healthData =
            Map<String, dynamic>.from(
              data,
            );


        _monitoring = false;


        _stopHealthPolling();


        notifyListeners();


        debugPrint(
          '=========================================',
        );

        debugPrint(
          'MEASUREMENT COMPLETED',
        );

        debugPrint(
          'FINAL HEALTH DATA:',
        );

        debugPrint(
          jsonEncode(
            _healthData,
          ),
        );

        debugPrint(
          '=========================================',
        );


        return;
      }


      // ======================================================
      // ERROR
      // ======================================================

      if (
        status == 'error' ||
        status == 'wifi_error'
      ) {

        _monitoring = false;

        _stopHealthPolling();

        notifyListeners();

        return;
      }


      // ======================================================
      // FINGER REMOVED
      // ======================================================
      //
      // This is not a connection failure.
      //
      // ESP32 can return to waiting_finger.
      //
      // ======================================================

      if (status == 'finger_removed') {

        debugPrint(
          'Finger removed before completion.',
        );

        return;
      }


    } on TimeoutException {

      // ------------------------------------------------------
      // Do not immediately kill the session.
      //
      // A temporary /health timeout should not destroy
      // the monitoring session.
      // ------------------------------------------------------

      debugPrint(
        'ESP32 /health timeout',
      );


    } catch (e) {

      debugPrint(
        'ESP32 /health ERROR: $e',
      );
    }
  }


  // ==========================================================
  // START HEALTH POLLING
  // ==========================================================

  void _startHealthPolling() {

    _stopHealthPolling();


    // --------------------------------------------------------
    // Request immediately
    // --------------------------------------------------------

    checkHealth();


    // --------------------------------------------------------
    // Then every 500 milliseconds
    // --------------------------------------------------------

    _healthTimer =
        Timer.periodic(
      const Duration(
        milliseconds: 500,
      ),
      (_) {

        if (!_monitoring) {
          return;
        }


        checkHealth();
      },
    );
  }


  // ==========================================================
  // STOP HEALTH POLLING
  // ==========================================================

  void _stopHealthPolling() {

    _healthTimer?.cancel();

    _healthTimer = null;
  }


  // ==========================================================
  // PARSE PROGRESS
  // ==========================================================

  int? _parseProgress(
    dynamic value,
  ) {

    if (value == null) {
      return null;
    }


    if (value is int) {

      return value.clamp(
        0,
        100,
      );
    }


    if (value is double) {

      return value
          .round()
          .clamp(
            0,
            100,
          );
    }


    if (value is num) {

      return value
          .round()
          .clamp(
            0,
            100,
          );
    }


    if (value is String) {

      final int? parsed =
          int.tryParse(
            value,
          );


      if (parsed != null) {

        return parsed.clamp(
          0,
          100,
        );
      }
    }


    return null;
  }


  // ==========================================================
  // SET ESP STATE
  // ==========================================================

  void _setESPState({
    required String status,
    required String message,
    required int? progress,
  }) {

    _espState = ESPState(
      status: status,
      message: message,
      progress: progress,
    );


    notifyListeners();
  }


  // ==========================================================
  // RESET
  // ==========================================================

  void reset() {

    _stopHealthPolling();


    _healthData = null;


    _connected = false;


    _monitoring = false;


    _espState = ESPState(
      status: 'idle',
      message: 'Ready',
      progress: null,
    );


    notifyListeners();
  }


  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {

    _stopHealthPolling();

    super.dispose();
  }
}
```
