class HealthResponse {


  final String userId;

  final String workerType;

  final String activity;

  final String environment;


  final int heartRate;

  final int spo2;

  final double temperature;


  final String aiStatus;

  final String riskLevel;

  final String aiMessage;




  HealthResponse({


    required this.userId,


    required this.workerType,


    required this.activity,


    required this.environment,



    required this.heartRate,


    required this.spo2,


    required this.temperature,



    required this.aiStatus,


    required this.riskLevel,


    required this.aiMessage,


  });








  factory HealthResponse.fromJson(
      Map<String,dynamic> json,
  ){



    return HealthResponse(



      userId:

      json['user_id'] ??

      '',




      workerType:

      json['worker_type'] ??

      '',





      activity:

      json['activity'] ??

      '',






      environment:

      json['environment'] ??

      '',







      heartRate:

      json['heart_rate'] ??

      0,







      spo2:

      json['spo2'] ??

      0,







      temperature:


      (json['temperature'] ?? 0)

      .toDouble(),







      aiStatus:


      json['ai_status'] ??

      'Waiting',







      riskLevel:


      json['risk_level'] ??

      'Unknown',







      aiMessage:


      json['ai_message'] ??

      '',




    );



  }








  Map<String,dynamic> toJson(){



    return {



      "user_id":
      userId,



      "worker_type":
      workerType,



      "activity":
      activity,



      "environment":
      environment,



      "heart_rate":
      heartRate,



      "spo2":
      spo2,



      "temperature":
      temperature,



      "ai_status":
      aiStatus,



      "risk_level":
      riskLevel,



      "ai_message":
      aiMessage,



    };



  }



}
