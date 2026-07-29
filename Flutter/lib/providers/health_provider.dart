import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/api_state.dart';
import '../models/health_response.dart';

import '../services/esp_service.dart';
import '../services/network_exception.dart';

class HealthProvider extends ChangeNotifier {

  final ESPService _espService = ESPService();

  ApiState _state = ApiState.idle();

  ApiState get state => _state;

  HealthResponse? _healthData;

  HealthResponse? get healthData => _healthData;

  //===========================
  // Start Monitoring
  //===========================

  Future<void> startMonitoring() async {

    // Step 1 : Connect ESP32

    _state = ApiState.connecting();

    notifyListeners();

    final connected = await _espService.checkConnection();

    if (!connected) {

      _state = ApiState.error(
        'Cannot connect to ESP32',
      );

      notifyListeners();

      return;
    }

    // Step 2 : Waiting Finger

    _state = ApiState.waitingSensor();

    notifyListeners();

    while (true) {

      try {

        // Step 3 : Reading Sensors

        _state = ApiState.readingData();

        notifyListeners();

        final result =
            await _espService.getHealthData();

        // Step 4 : Save Data

        _healthData = result;

        // Step 5 : AI Finished

        _state = ApiState.success(
          'Health analysis completed',
        );

        notifyListeners();

        break;

      }

      on NetworkException catch (e) {

        if (e.message.contains(
          'Waiting for finger',
        )) {

          _state =
              ApiState.waitingSensor();

          notifyListeners();

          await Future.delayed(
            const Duration(seconds: 1),
          );

          continue;
        }

        _state = ApiState.error(
          e.message,
        );

        notifyListeners();

        break;

      }

      catch (_) {

        _state = ApiState.error(
          'Unexpected error',
        );

        notifyListeners();

        break;

      }

    }

  }

}
