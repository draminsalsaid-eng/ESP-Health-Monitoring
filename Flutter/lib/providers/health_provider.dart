import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/worker_data.dart';
import '../models/api_state.dart';
import '../models/health_response.dart';
import '../models/user_input.dart';

import '../services/esp_service.dart';
import '../services/network_exception.dart';



class HealthProvider extends ChangeNotifier {


  final ESPService _espService = ESPService();



  Timer? _monitorTimer;



  //===========================
  // API State
  //===========================

  ApiState _state = ApiState.idle();


  ApiState get state => _state;



  //===========================
  // Health Result
  //===========================

  HealthResponse? _healthData;


  HealthResponse? get healthData => _healthData;




  //===========================
  // Start Monitoring Session
  //===========================

  Future<void> startMonitoring(
      UserInput userInput,
      WorkerData workerData,
  ) async {



    try {



      _healthData = null;



      //===========================
      // Connecting
      //===========================

      _state =
          ApiState.connecting();


      notifyListeners();





      final connected =
          await _espService
              .checkConnection();




      if(!connected){


        _state =
            ApiState.error(

              'ESP32 disconnected. Check WiFi',

            );


        notifyListeners();


        return;

      }





      //===========================
      // Send User Information
      //===========================

      await _espService
    .sendUserInput(
      userInput,
    );
await _espService
    .sendWorkerConfig(
      workerData,
    );

      //===========================
      // Waiting Finger
      //===========================

      _state =
          ApiState.waitingSensor();


      notifyListeners();






      // Start Reading Loop

      _startMonitoringLoop();




    }




    on NetworkException catch(e){


      _state =
          ApiState.error(
            e.message,
          );


      notifyListeners();


    }





  }









  //===========================
  // Continuous Reading Loop
  //===========================

  void _startMonitoringLoop(){



    _monitorTimer?.cancel();




    _monitorTimer = Timer.periodic(

      const Duration(seconds: 1),


      (_) async {


        await _readESPStatus();


      },

    );



  }










  //===========================
  // Read ESP32 Status
  //===========================

  Future<void> _readESPStatus() async {


    try {



      final result =
          await _espService
              .readHealthStatus();




      _healthData = result;






      //===========================
      // Final Result Received
      //===========================


      _state =
          ApiState.success(

            'Health analysis completed',

          );



      notifyListeners();




      stopMonitoring();



    }



    on NetworkException catch(e){



      if(e.message.contains(
        'Waiting',
      )){


        _state =
            ApiState.waitingSensor();


      }



      else {


        _state =
            ApiState.error(

              e.message,

            );


        stopMonitoring();


      }



      notifyListeners();



    }



  }









  //===========================
  // Stop Monitoring
  //===========================

  void stopMonitoring(){



    _monitorTimer?.cancel();


    _monitorTimer = null;


  }









  @override
  void dispose(){


    stopMonitoring();


    super.dispose();


  }



}
