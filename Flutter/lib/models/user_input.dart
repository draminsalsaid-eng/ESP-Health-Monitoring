 class UserInput {

  final String workerType;
  final String activity;
  final String environment;


  UserInput({

    required this.workerType,

    required this.activity,

    required this.environment,

  });



  Map<String,dynamic> toJson(){

    return {

      "worker_type": workerType,

      "activity": activity,

      "environment": environment,

    };

  }


}
