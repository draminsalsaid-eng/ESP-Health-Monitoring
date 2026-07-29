import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/health_response.dart';
import '../models/user_input.dart';

import 'api_constants.dart';
import 'network_exception.dart';


class ESPService {
  //================================
  // Check ESP32 Connection
  //================================

  Future<bool> checkConnection() async {

    try {

      final response = await http
          .get(
            Uri.parse(
              ApiConstants.baseUrl +
              ApiConstants.health,
            ),
          )
          .timeout(
            ApiConstants.connectionTimeout,
          );


      return response.statusCode == 200;


    } catch (_) {

      return false;

    }

  }
  //================================
  // Ping ESP32
  //================================
  Future<bool> pingESP() async {

    try {

      final response = await http
          .get(
            Uri.parse(
              ApiConstants.baseUrl +
              ApiConstants.health,
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
  //================================
  // Get Health Data
  //================================
  Future<HealthResponse> getHealthData() async {
    try {

      final response = await http
          .get(
            Uri.parse(
              ApiConstants.baseUrl +
              ApiConstants.health,
            ),
          )
          .timeout(
            ApiConstants.receiveTimeout,
          );



      // ESP32 Response OK

      if (response.statusCode == 200) {


        final jsonData =
            json.decode(response.body);



        // No finger detected

        if (jsonData is Map &&
            jsonData.isEmpty) {


          throw const NetworkException(
            'Waiting for finger on MAX30105',
          );

        }



        return HealthResponse.fromJson(
          jsonData,
        );


      }



      // ESP32 returned HTTP error

      else {


        throw NetworkException(
          'ESP32 returned error: ${response.statusCode}',
        );


      }




    }


    // Connection lost / Power OFF / WiFi problem

    on http.ClientException {


      throw const NetworkException(
        'ESP32 disconnected. Check power and WiFi',
      );


    }


    on NetworkException {

      rethrow;


    }


    catch (_) {


      throw const NetworkException(
        'ESP32 disconnected. Check power and WiFi',
      );


    }


  }
  //================================
  // Send User Input
  //================================
  Future<void> sendUserInput(
      UserInput input,
  ) async {
    try {

      final response = await http
          .post(
            Uri.parse(
              ApiConstants.baseUrl +
              '/start',
            ),
            headers: {
              'Content-Type':
                  'application/json',

            },


            body: json.encode(
              input.toJson(),
            ),

          )
          .timeout(
            ApiConstants.connectionTimeout,
          );




      if (response.statusCode != 200) {


        throw const NetworkException(
          'Failed to send user input',
        );


      }



    }


    on http.ClientException {


      throw const NetworkException(
        'ESP32 disconnected. Check power and WiFi',
      );
    }
    on NetworkException {

      rethrow;
    }
    catch (_) {
      throw const NetworkException(
        'Cannot send data to ESP32',
      );
    }
  }

}
