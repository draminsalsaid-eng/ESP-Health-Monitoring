 class UserInput {
  final String userId;
  final String workerType;
  final String activity;
  final String environment;
  UserInput({
    required this.userId,
    required this.workerType,
    required this.activity,
    required this.environment,
  });
  Map<String,dynamic> toJson(){
    return {
      "user_id": userId,
      "worker_type": workerType,
      "activity": activity,
      "environment": environment,
    };
  }
}
