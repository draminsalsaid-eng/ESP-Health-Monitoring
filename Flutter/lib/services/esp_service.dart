import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/health_response.dart';
import '../models/user_input.dart';

import 'api_constants.dart';
import 'network_exception.dart';

class ESPService {
  // Check Connection  //
Future<bool> checkConnection() async {
  try {
    final response = await http
        .get(
          Uri.parse(
            ApiConstants.baseUrl + ApiConstants.health,
          ),
        )
        .timeout(ApiConstants.connectionTimeout);

    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
  // PING ESP32   //
  Future<bool> pingESP() async {
  try {
    final response = await http
        .get(
          Uri.parse(
            ApiConstants.baseUrl + ApiConstants.health,
          ),
        )
        .timeout(
          const Duration(seconds: 5),
        );

    return response.statusCode == 200;

  } catch (_) {
    return false;
  }
}
  // Get health Data  //
  Future<HealthResponse> getHealthData() async {
  try {
    final response = await http
        .get(
          Uri.parse(
            ApiConstants.baseUrl + ApiConstants.health,
          ),
        )
        .timeout(ApiConstants.receiveTimeout);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      return HealthResponse.fromJson(jsonData);
    } else {
      throw NetworkException(
        'ESP32 returned error: ${response.statusCode}',
      );
    }
  } catch (e) {
    if (e is NetworkException) {
      rethrow;
    }

    throw NetworkException(
      'Failed to get health data from ESP32',
    );
  }
}
// Send user Input  //
  Future<void> sendUserInput(UserInput input) async {
  try {
    final response = await http
        .post(
          Uri.parse(
            ApiConstants.baseUrl + '/start',
          ),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            input.toJson(),
          ),
        )
        .timeout(ApiConstants.connectionTimeout);

    if (response.statusCode != 200) {
      throw NetworkException(
        'Failed to send user input',
      );
    }

  } catch (e) {
    if (e is NetworkException) {
      rethrow;
    }

    throw NetworkException(
      'Cannot send data to ESP32',
    );
  }
}
}
