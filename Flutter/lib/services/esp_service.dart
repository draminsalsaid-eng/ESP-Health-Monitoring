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


      final response =
          await http
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


      final response =
          await http
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
  // Send User Input
  // Start ESP32 Measurement Session
  //================================

  Future<void> sendUserInput(
      UserInput input,
  ) async {


    try {


      final response =
          await http
              .post(

                Uri.parse(

                  ApiConstants.baseUrl +
                  '/start',

                ),


                headers: {


                  'Content-Type':
                      'application/json',


                },



                body:

                    json.encode(

                      input.toJson(),

                    ),



              )
              .timeout(

                ApiConstants.connectionTimeout,

              );






      if(response.statusCode != 200) {


        throw const NetworkException(

          'Failed to start ESP32 measurement',

        );


      }



    }



    on http.ClientException {


      throw const NetworkException(

        'ESP32 disconnected. Check WiFi',

      );


    }



    on NetworkException {


      rethrow;


    }



    catch (_) {


      throw const NetworkException(

        'Cannot send user data to ESP32',

      );


    }


  }








  //================================
  // Read Current ESP32 Health Status
  //
  // Returns:
  //
  // waiting_finger
  // measuring
  // processing_ai
  // completed
  //
  //================================

  Future<HealthResponse> readHealthStatus() async {


    try {



      final response =
          await http
              .get(

                Uri.parse(

                  ApiConstants.baseUrl +
                  ApiConstants.health,

                ),

              )
              .timeout(

                ApiConstants.receiveTimeout,

              );







      if(response.statusCode != 200) {


        throw NetworkException(

          'ESP32 returned error: '
          '${response.statusCode}',

        );


      }






      final jsonData =
          json.decode(
            response.body,
          );






      if(jsonData is Map) {


        return HealthResponse.fromJson(

          Map<String,dynamic>.from(

            jsonData,

          ),

        );


      }






      throw const NetworkException(

        'Invalid JSON response from ESP32',

      );





    }



    on http.ClientException {


      throw const NetworkException(

        'ESP32 disconnected. Check WiFi',

      );


    }




    on NetworkException {


      rethrow;

    }

    catch (_) {

      throw const NetworkException(

        'Cannot read ESP32 health status',
      );

    }

  }


}
