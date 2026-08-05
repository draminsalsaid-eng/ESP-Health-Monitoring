class UserInput {

  final String userId;

  final String workerType;

  final String activity;

  final String environment;


  const UserInput({

    required this.userId,

    required this.workerType,

    required this.activity,

    required this.environment,

  });


  factory UserInput.fromJson(
      Map<String,dynamic> json) {

    return UserInput(

      userId:
          json['user_id'] ?? '',

      workerType:
          json['worker_type'] ?? '',

      activity:
          json['activity'] ?? '',

      environment:
          json['environment'] ?? '',

    );

  }



  Map<String,dynamic> toJson(){

    return {

      "user_id": userId,

      "worker_type": workerType,

      "activity": activity,

      "environment": environment,

    };

  }

}
