import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/api_state.dart';
import '../models/health_response.dart';
import '../models/user_input.dart';

import '../services/esp_service.dart';
import '../services/network_exception.dart';




class HealthProvider extends ChangeNotifier {



  final ESPService _espService =
      ESPService();



  Timer? _monitorTimer;





  //================================
  // API STATE
  //================================


  ApiState _state =
      ApiState.idle();



  ApiState get state =>
      _state;






  //================================
  // HEALTH DATA
  //================================


  HealthResponse? _healthData;



  HealthResponse? get healthData =>
      _healthData;






  //================================
  // START MONITORING
  //================================


  Future<void> startMonitoring(

      UserInput userInput,

  ) async {



    try {



      _healthData = null;



      _state =
          ApiState.connecting();



      notifyListeners();







      final connected =
          await _espService
              .checkConnection();





      if(!connected){



        _state =
            ApiState.error(

              'ESP32 disconnected',

            );


        notifyListeners();


        return;


      }








      // Send worker information

      await _espService
          .sendUserInput(

            userInput,

          );









      _state =
          ApiState.waitingSensor();



      notifyListeners();







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









  //================================
  // PERIODIC READING
  //================================


  void _startMonitoringLoop(){



    _monitorTimer?.cancel();





    _monitorTimer =
        Timer.periodic(


          const Duration(seconds:1),



          (_) async {



            await _readESPStatus();



          },


        );



  }









  //================================
  // READ ESP32 STATUS
  //================================


  Future<void> _readESPStatus() async {



    try {



      final result =
          await _espService
              .readHealthStatus();





      _healthData =
          result;






      _state =
          ApiState.success(

            'Health analysis completed',

          );





      notifyListeners();






      stopMonitoring();





    }




    on NetworkException catch(e){






      if(e.message.contains(
          'Waiting'
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









  //================================
  // GET LAST DATA
  // Used by Dashboard
  //================================


  Future<void> getLatestHealthData() async {



    try {



      final result =
          await _espService
              .readHealthStatus();





      _healthData =
          result;






      _state =
          ApiState.success(

            'Data updated',

          );





      notifyListeners();




    }




    on NetworkException catch(e){



      _state =
          ApiState.error(

            e.message,

          );



      notifyListeners();



    }




  }









  //================================
  // STOP MONITORING
  //================================


  void stopMonitoring(){



    _monitorTimer?.cancel();



    _monitorTimer =
        null;



  }









  @override
  void dispose(){



    stopMonitoring();



    super.dispose();



  }





}
