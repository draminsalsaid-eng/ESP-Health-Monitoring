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
// Check Connection  //
  
}
