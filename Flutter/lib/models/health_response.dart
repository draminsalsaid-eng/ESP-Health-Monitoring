import 'user_input.dart';
import 'sensor_data.dart';
import 'ai_result.dart';
  
class HealthResponse {
  final UserInput userInput;
  final SensorData sensorData;
  final AIResult aiResult;

  const HealthResponse({
    required this.userInput,
    required this.sensorData,
    required this.aiResult,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      userInput: UserInput.fromJson(json),
      sensorData: SensorData.fromJson(json),
      aiResult: AIResult.fromJson(json),
    );
  }
}
