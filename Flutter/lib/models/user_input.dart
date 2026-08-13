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

  // البيانات التي يمكن إرسالها إلى ESP32 / API
  // User ID لا يتم إرسالها.
  Map<String, dynamic> toJson() {
    return {
      "worker_type": workerType,
      "activity": activity,
      "environment": environment,
    };
  }

  factory UserInput.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserInput(
      userId: json["user_id"] ?? "",
      workerType: json["worker_type"] ?? "",
      activity: json["activity"] ?? "",
      environment: json["environment"] ?? "",
    );
  }
}
