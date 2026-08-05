class UserInput {
  final String userId;
  final String workerType;
  final String activity;
  final String workplace;

  UserInput({
    required this.userId,
    required this.workerType,
    required this.activity,
    required this.workplace,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "worker_type": workerType,
      "activity": activity,
      "workplace": workplace,
    };
  }
}
