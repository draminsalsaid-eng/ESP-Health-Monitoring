import 'user_input.dart';
import 'sensor_data.dart';
import 'ai_result.dart';
import 'esp_status.dart';



class HealthResponse {


  final ESPState espState;


  final UserInput? userInput;


  final SensorData? sensorData;


  final AIResult? aiResult;





  const HealthResponse({

    required this.espState,

    this.userInput,

    this.sensorData,

    this.aiResult,

  });








  factory HealthResponse.fromJson(
      Map<String,dynamic> json,
  ){



    return HealthResponse(


      espState:

          ESPState.fromJson(
            json,
          ),




      userInput:

          json.containsKey('worker_type')

              ? UserInput.fromJson(json)

              : null,





      sensorData:

          json.containsKey('HR')

              ? SensorData.fromJson(json)

              : null,





      aiResult:

          json.containsKey('prediction')

              ? AIResult.fromJson(json)

              : null,



    );


  }


}
