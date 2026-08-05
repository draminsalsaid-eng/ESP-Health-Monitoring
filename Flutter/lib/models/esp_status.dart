enum ESPStatus {

  idle,

  waitingFinger,

  measuring,

  processingAI,

  completed,

  error,

}



class ESPState {


  final ESPStatus status;

  final String message;



  const ESPState({

    required this.status,

    required this.message,

  });





  factory ESPState.fromJson(
      Map<String,dynamic> json,
  ){

    final String value =
        json['status'] ?? 'idle';




    switch(value){


      case 'waiting_finger':

        return const ESPState(

          status: ESPStatus.waitingFinger,

          message:
          'Place finger on MAX30105',

        );




      case 'measuring':

        return const ESPState(

          status: ESPStatus.measuring,

          message:
          'Reading sensors',

        );





      case 'processing_ai':

        return const ESPState(

          status: ESPStatus.processingAI,

          message:
          'Analyzing health data',

        );





      case 'completed':

        return const ESPState(

          status: ESPStatus.completed,

          message:
          'Health analysis completed',

        );





      case 'error':

        return const ESPState(

          status: ESPStatus.error,

          message:
          'ESP32 error',

        );





      default:

        return const ESPState(

          status: ESPStatus.idle,

          message:
          'Ready',

        );

    }

  }



}
