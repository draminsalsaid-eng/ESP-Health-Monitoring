import 'user_input.dart';
import 'sensor_data.dart';
import 'ai_result.dart';
import 'esp_status.dart';



class HealthResponse {


  final ESPStatus status;

  final String message;


  final UserInput userInput;

  final SensorData sensorData;

  final AIResult aiResult;




  const HealthResponse({

    required this.status,

    required this.message,

    required this.userInput,

    required this.sensorData,

    required this.aiResult,

  });





  factory HealthResponse.fromJson(
      Map<String, dynamic> json) {


    return HealthResponse(


      status:
          parseESPStatus(
            json['status'] ?? '',
          ),



      message:
          json['message'] ?? '',



      userInput:
          UserInput.fromJson(json),



      sensorData:
          SensorData.fromJson(json),



      aiResult:
          AIResult.fromJson(json),


    );


  }





  bool get waitingFinger =>

      status == ESPStatus.waitingFinger;



  bool get measuring =>

      status == ESPStatus.measuring;



  bool get processingAI =>

      status == ESPStatus.processingAI;



  bool get completed =>

      status == ESPStatus.completed;



}
