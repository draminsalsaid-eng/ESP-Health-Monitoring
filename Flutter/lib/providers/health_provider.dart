
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user_input.dart';


// ============================================================
// HEALTH PROVIDER
// ============================================================
//
// Responsible for communication:
//
// Flutter
//    ↓
// ESP32 /start
//    ↓
// ESP32 waits for finger
//    ↓
// ESP32 /health
//    ↓
// measurement
//    ↓
// AI processing
//    ↓
// completed JSON
//
// ============================================================

class HealthProvider extends ChangeNotifier {

  // ==========================================================
  // ESP32 CONFIGURATION
  // ==========================================================

  //
  // IMPORTANT:
  // Replace this IP with the IP printed by ESP32:
  //
  // IP Address: 192.168.x.x
  //
  static const String esp32BaseUrl =
      'http://192.168.1.100';


  // ==========================================================
  // HTTP CONFIGURATION
  // ==========================================================

  static const Duration requestTimeout =
      Duration(seconds: 5);

  static const Duration healthTimeout =
      Duration(seconds: 5);


  // ==========================================================
  // HEALTH STATE
  // ==========================================================

  HealthState _state = const HealthState(
    status: 'idle',
    message: 'Ready',
    progress: 0,
  );


  HealthState get state => _state;


  // ==========================================================
  // FINAL RESULT
  // ==========================================================

  Map<String, dynamic>? _result;


  Map<String, dynamic>? get result => _result;


  // ==========================================================
  // CONNECTION STATE
  // ==========================================================

  bool _isConnected = false;


  bool get isConnected => _isConnected;


  // ==========================================================
  // MONITORING STATE
  // ==========================================================

  bool _isMonitoring = false;


  bool get isMonitoring => _isMonitoring;


  // ==========================================================
  // POLLING TIMER
  // ==========================================================

  Timer? _healthTimer;


  // ==========================================================
  // START MONITORING
  // ==========================================================
  //
  // Called from WorkerSetupScreen:
  //
  // final success =
  //     await health.startMonitoring(userInput);
  //
  // ==========================================================

  Future<bool> startMonitoring(
    UserInput userInput,
  ) async {

    // --------------------------------------------------------
    // Stop any previous polling
    // --------------------------------------------------------

    _stopHealthPolling();


    // --------------------------------------------------------
    // Reset previous result
    // --------------------------------------------------------

    _result = null;

    _isMonitoring = false;

    _isConnected = false;


    _setState(
      status: 'connecting',
      message: 'Connecting to ESP32...',
      progress: 0,
    );


    try {

      // ======================================================
      // CREATE /start URL
      // ======================================================

      final uri = Uri.parse(
        '$esp32BaseUrl/start',
      );


      // ======================================================
      // CREATE JSON
      // ======================================================

      final body = jsonEncode({

        'worker_type':
            userInput.workerType,

        'activity':
            userInput.activity,

        'environment':
            userInput.environment,

      });


      debugPrint(
        '==========================================',
      );

      debugPrint(
        'ESP32 START REQUEST',
      );

      debugPrint(
        'URL: $uri',
      );

      debugPrint(
        'BODY: $body',
      );

      debugPrint(
        '==========================================',
      );


      // ======================================================
      // SEND POST /start
      // ======================================================

      final response =
          await http
              .post(
                uri,

                headers: {
                  'Content-Type':
                      'application/json',

                  'Accept':
                      'application/json',
                },

                body: body,
              )
              .timeout(
                requestTimeout,
              );


      // ======================================================
      // PRINT RESPONSE
      // ======================================================

      debugPrint(
        'ESP32 START RESPONSE',
      );

      debugPrint(
        'HTTP: ${response.statusCode}',
      );

      debugPrint(
        'BODY: ${response.body}',
      );


      // ======================================================
      // CHECK HTTP STATUS
      // ======================================================

      if (response.statusCode != 200) {

        _setState(
          status: 'error',
          message:
              'ESP32 returned HTTP ${response.statusCode}',
          progress: 0,
        );

        return false;
      }


      // ======================================================
      // PARSE JSON
      // ======================================================

      Map<String, dynamic> data;

      try {

        data = jsonDecode(
          response.body,
        ) as Map<String, dynamic>;

      } catch (e) {

        _setState(
          status: 'error',
          message:
              'Invalid response from ESP32',
          progress: 0,
        );

        debugPrint(
          'JSON ERROR: $e',
        );

        return false;
      }


      // ======================================================
      // CHECK ESP32 RESPONSE
      // ======================================================

      final status =
          data['status']?.toString() ?? '';


      // ======================================================
      // ESP32 /start SHOULD RETURN:
      //
      // {
      //   "status":"ok"
      // }
      //
      // ======================================================

      if (status != 'ok') {

        _setState(
          status: 'error',
          message:
              data['message']?.toString() ??
              'ESP32 rejected the monitoring request',
          progress: 0,
        );

        return false;
      }


      // ======================================================
      // CONNECTION SUCCESS
      // ======================================================

      _isConnected = true;

      _isMonitoring = true;


      _setState(
        status: 'waiting_finger',
        message:
            'Place finger on both sensors',
        progress: 0,
      );


      // ======================================================
      // START /health POLLING
      // ======================================================

      _startHealthPolling();


      return true;

    } on TimeoutException {

      _setState(
        status: 'error',
        message:
            'Connection to ESP32 timed out',
        progress: 0,
      );

      return false;

    } catch (e) {

      debugPrint(
        'ESP32 CONNECTION ERROR: $e',
      );


      _setState(
        status: 'error',
        message:
            'Could not connect to ESP32',
        progress: 0,
      );


      return false;
    }
  }


  // ==========================================================
  // CHECK ESP32 HEALTH
  // ==========================================================
  //
  // GET:
  //
  // http://ESP32_IP/health
  //
  // ESP32 returns for example:
  //
  // {
  //   "status":"waiting_finger",
  //   "message":"Place finger on both sensors"
  // }
  //
  // OR:
  //
  // {
  //   "status":"measuring",
  //   "progress":45,
  //   "message":"Reading sensors"
  // }
  //
  // OR final:
  //
  // {
  //   "HR":75,
  //   // ...
  //   "alert_level":"green",
  //   "risk_level":"low",
  //   "status":"completed",
  //   "message":"Measurement completed"
  // }
  //
  // ==========================================================

  Future<void> checkHealth() async {

    try {

      final uri = Uri.parse(
        '$esp32BaseUrl/health',
      );


      final response =
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
        'ESP32 HEALTH HTTP: ${response.statusCode}',
      );

      debugPrint(
        'ESP32 HEALTH BODY: ${response.body}',
      );


      if (response.statusCode != 200) {

        return;
      }


      Map<String, dynamic> data;

      try {

        data = jsonDecode(
          response.body,
        ) as Map<String, dynamic>;

      } catch (e) {

        debugPrint(
          'Health JSON parsing error: $e',
        );

        return;
      }


      // ======================================================
      // EXTRACT STATUS
      // ======================================================

      final status =
          data['status']?.toString() ?? '';


      final message =
          data['message']?.toString() ??
          '';


      final progress =
          _readProgress(
            data['progress'],
          );


      // ======================================================
      // UPDATE PROVIDER STATE
      // ======================================================

      _state = HealthState(
        status: status,
        message: message,
        progress: progress,
        data: data,
      );


      notifyListeners();


      // ======================================================
      // COMPLETED
      // ======================================================

      if (status == 'completed') {

        _result =
            Map<String, dynamic>.from(
              data,
            );


        _isMonitoring = false;


        _stopHealthPolling();


        notifyListeners();


        debugPrint(
          '==========================================',
        );

        debugPrint(
          'HEALTH MONITORING COMPLETED',
        );

        debugPrint(
          'FINAL RESULT:',
        );

        debugPrint(
          jsonEncode(_result),
        );

        debugPrint(
          '==========================================',
        );


        return;
      }


      // ======================================================
      // ERROR STATES
      // ======================================================

      if (
        status == 'error' ||
        status == 'wifi_error'
      ) {

        _isMonitoring = false;

        _stopHealthPolling();

        notifyListeners();

        return;
      }


      // ======================================================
      // FINGER REMOVED
      // ======================================================
      //
      // This is NOT a permanent connection error.
      //
      // ESP32 returns to waiting_finger.
      //
      // ======================================================

      if (status == 'finger_removed') {

        debugPrint(
          'Finger removed before completion',
        );

        return;
      }

    } on TimeoutException {

      debugPrint(
        'ESP32 /health timeout',
      );

    } catch (e) {

      debugPrint(
        'ESP32 /health error: $e',
      );
    }
  }


  // ==========================================================
  // START HEALTH POLLING
  // ==========================================================

  void _startHealthPolling() {

    _stopHealthPolling();


    // --------------------------------------------------------
    // First request immediately
    // --------------------------------------------------------

    checkHealth();


    // --------------------------------------------------------
    // Then every 500 ms
    // --------------------------------------------------------

    _healthTimer =
        Timer.periodic(
      const Duration(
        milliseconds: 500,
      ),
      (_) {

        if (!_isMonitoring) {
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
  // READ PROGRESS SAFELY
  // ==========================================================

  int _readProgress(
    dynamic value,
  ) {

    if (value == null) {
      return 0;
    }


    if (value is int) {
      return value.clamp(0, 100);
    }


    if (value is double) {
      return value
          .round()
          .clamp(0, 100);
    }


    if (value is String) {

      final parsed =
          int.tryParse(value);

      if (parsed != null) {

        return parsed.clamp(
          0,
          100,
        );
      }
    }


    return 0;
  }


  // ==========================================================
  // INTERNAL STATE UPDATE
  // ==========================================================

  void _setState({
    required String status,
    required String message,
    required int progress,
    Map<String, dynamic>? data,
  }) {

    _state = HealthState(
      status: status,
      message: message,
      progress: progress,
      data: data,
    );


    notifyListeners();
  }


  // ==========================================================
  // CLEAR RESULT
  // ==========================================================

  void clearResult() {

    _result = null;

    notifyListeners();
  }


  // ==========================================================
  // RESET PROVIDER
  // ==========================================================

  void reset() {

    _stopHealthPolling();


    _result = null;

    _isConnected = false;

    _isMonitoring = false;


    _state = const HealthState(
      status: 'idle',
      message: 'Ready',
      progress: 0,
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


// ============================================================
// HEALTH STATE
// ============================================================

class HealthState {

  final String status;

  final String message;

  final int progress;

  final Map<String, dynamic>? data;


  const HealthState({
    required this.status,
    required this.message,
    required this.progress,
    this.data,
  });


  // ==========================================================
  // CONVENIENCE GETTERS
  // ==========================================================

  bool get isIdle =>
      status == 'idle';


  bool get isConnecting =>
      status == 'connecting';


  bool get isWaitingFinger =>
      status == 'waiting_finger';


  bool get isMeasuring =>
      status == 'measuring';


  bool get isProcessing =>
      status == 'processing';


  bool get isCompleted =>
      status == 'completed';


  bool get isFingerRemoved =>
      status == 'finger_removed';


  bool get isError =>
      status == 'error' ||
      status == 'wifi_error';


  // ==========================================================
  // FINAL HEALTH VALUES
  // ==========================================================

  dynamic get heartRate =>
      data?['HR'];


  dynamic get hrv =>
      data?['HRV'];


  dynamic get spo2 =>
      data?['SpO2'];


  dynamic get bodyTemperature =>
      data?['body_temp'];


  dynamic get environmentTemperature =>
      data?['env_temp'];


  dynamic get humidity =>
      data?['humidity'];


  dynamic get mq2 =>
      data?['MQ2'];


  dynamic get mq5 =>
      data?['MQ5'];


  dynamic get mq135 =>
      data?['MQ135'];


  dynamic get acceleration =>
      data?['acc_mag'];


  dynamic get gyroscope =>
      data?['gyro_mag'];


  dynamic get alertLevel =>
      data?['alert_level'];


  dynamic get riskLevel =>
      data?['risk_level'];
}

