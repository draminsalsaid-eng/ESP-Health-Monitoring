import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/health_response.dart';
import '../models/user_input.dart';

import 'api_constants.dart';
import 'network_exception.dart';



class ESPService {



  //=========================================
  // Check ESP32 Connection
  //=========================================

  Future<bool> checkConnection() async {

    try {


      final response =
          await http.get(

            Uri.parse(

              ApiConstants.baseUrl +
              ApiConstants.health,

            ),

          ).timeout(

            ApiConstants.connectionTimeout,

          );


      return response.statusCode == 200;


    }

    catch(_){

      return false;

    }

  }





  //=========================================
  // Send Worker Information To ESP32
  //
  // Data:
  // user_id
  // worker_type
  // activity
  // workplace
  //
  // ESP32 stores this data
  // and combines it with sensors
  //=========================================


  Future<void> sendUserInput(
      UserInput input,
  ) async {


    try {


      final response =
          await http.post(


            Uri.parse(

              ApiConstants.baseUrl +
              '/start',

            ),


            headers: {


              'Content-Type':
                  'application/json',


            },


            body:

              jsonEncode(

                input.toJson(),

              ),



          ).timeout(


            ApiConstants.connectionTimeout,


          );






      if(response.statusCode != 200){


        throw const NetworkException(

          'ESP32 rejected worker data',

        );


      }




    }



    on http.ClientException{


      throw const NetworkException(

        'ESP32 WiFi connection failed',

      );


    }



    on NetworkException{


      rethrow;


    }



    catch(e){


      throw const NetworkException(

        'Cannot send worker information',

      );


    }


  }






  //=========================================
  // Read Final Health JSON From ESP32
  //
  // ESP32 Response Example:
  //
  // {
  // worker_type:"senior",
  // activity:"grinding",
  // environment:"steel_factory",
  // heart_rate:90,
  // spo2:97,
  // temperature:37,
  // ai_status:"warning"
  // }
  //
  //=========================================


  Future<HealthResponse> readHealthStatus() async {


    try {



      final response =
          await http.get(

            Uri.parse(

              ApiConstants.baseUrl +
              ApiConstants.health,

            ),


          ).timeout(


            ApiConstants.receiveTimeout,


          );







      if(response.statusCode != 200){


        throw NetworkException(

          'ESP32 Error ${response.statusCode}',

        );


      }






      final data =
          jsonDecode(

            response.body,

          );







      if(data is Map){



        return HealthResponse.fromJson(

          Map<String,dynamic>.from(

            data,

          ),


        );


      }







      throw const NetworkException(

        'Invalid JSON from ESP32',

      );




    }



    on http.ClientException{


      throw const NetworkException(

        'ESP32 disconnected',

      );


    }




    on NetworkException{


      rethrow;


    }




    catch(_){


      throw const NetworkException(

        'Cannot read health data',

      );


    }


  }






  //=========================================
  // Optional Ping
  //=========================================


  Future<bool> pingESP() async{


    try{


      final response =
          await http.get(

            Uri.parse(

              ApiConstants.baseUrl +
              ApiConstants.health,

            ),

          ).timeout(

            const Duration(seconds:5),

          );



      return response.statusCode == 200;


    }

    catch(_){

      return false;

    }


  }



}
