import 'user_input.dart';
import 'sensor_data.dart';
import 'ai_result.dart';



class HealthResponse {


  final String status;

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
          json['status'] ?? 'unknown',



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





  bool get isMeasuring =>
      status == 'measuring';



  bool get isProcessingAI =>
      status == 'processing_ai';



  bool get isCompleted =>
      status == 'completed';



}
