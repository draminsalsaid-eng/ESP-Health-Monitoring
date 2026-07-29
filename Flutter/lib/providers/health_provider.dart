import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/api_state.dart';
import '../models/health_response.dart';

import '../services/esp_service.dart';
import '../services/network_exception.dart';



class HealthProvider extends ChangeNotifier {


  final ESPService _espService = ESPService();



  //===========================
  // Current API State
  //===========================

  ApiState _state = ApiState.idle();


  ApiState get state => _state;



  //===========================
  // Health Data
  //===========================

  HealthResponse? _healthData;


  HealthResponse? get healthData => _healthData;





  //===========================
  // Start Monitoring
  //===========================

  Future<void> startMonitoring() async {


    // Clear old result

    _healthData = null;



    //===========================
    // Step 1 : Connect ESP32
    //===========================


    _state = ApiState.connecting();

    notifyListeners();



    final connected =
        await _espService.checkConnection();



    if (!connected) {


      _state = ApiState.error(
        'ESP32 disconnected. Check power and WiFi',
      );


      notifyListeners();


      return;

    }





    //===========================
    // Step 2 : Waiting Sensor
    //===========================


    _state = ApiState.waitingSensor();


    notifyListeners();




    const int maxAttempts = 30;


    int attempts = 0;


    bool measurementCompleted = false;





    //===========================
    // Step 3 : Read Data Loop
    //===========================


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





        //===========================
        // Step 4 : Success
        //===========================


        _state = ApiState.success(
          'Health analysis completed',
        );


        notifyListeners();



        break;



      }



      on NetworkException catch (e) {



        //===========================
        // No Finger Detected
        //===========================


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




        //===========================
        // ESP32 Disconnected
        //===========================


        if (e.message.contains(
          'ESP32 disconnected',
        )) {



          _state = ApiState.error(
            e.message,
          );



          notifyListeners();



          break;


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





    //===========================
    // Step 5 : Timeout
    //===========================


    if (!measurementCompleted &&
        _state.status != ApiStatus.error) {



      _state = ApiState.error(
        'Measurement timeout. Please try again.',
      );


      notifyListeners();


    }



  }

}
