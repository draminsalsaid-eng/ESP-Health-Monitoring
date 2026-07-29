import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/api_state.dart';
import '../models/health_response.dart';

import '../services/esp_service.dart';
import '../services/network_exception.dart';


class HealthProvider extends ChangeNotifier {

  final ESPService _espService = ESPService();


  // Current API State
  ApiState _state = ApiState.idle();

  ApiState get state => _state;



  // Health Result
  HealthResponse? _healthData;

  HealthResponse? get healthData => _healthData;



  //===========================
  // Start Monitoring
  //===========================

  Future<void> startMonitoring() async {


    // Clear previous result

    _healthData = null;



    // Step 1 : Connect ESP32

    _state = ApiState.connecting();

    notifyListeners();


    final connected =
        await _espService.checkConnection();



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



    const int maxAttempts = 30;

    int attempts = 0;

    bool measurementCompleted = false;



    // Step 3 : Try Reading

    while (attempts < maxAttempts) {


      attempts++;


      try {


        _state = ApiState.readingData();

        notifyListeners();



        final result =
            await _espService.getHealthData();



        // Save Result

        _healthData = result;


        measurementCompleted = true;



        // Step 4 : Success

        _state = ApiState.success(
          'Health analysis completed',
        );


        notifyListeners();


        break;



      }


      on NetworkException catch (e) {



        // ESP32 returned {}

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



        // Other Network Errors

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



    // Step 5 : Timeout

    if (!measurementCompleted) {


      _state = ApiState.error(
        'Measurement timeout. Please try again.',
      );


      notifyListeners();


    }



  }

}
