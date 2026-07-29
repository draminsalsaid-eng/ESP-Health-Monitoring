class UserInput {
  final String workerType;
  final String activity;
  final String environment;

  const UserInput({
    required this.workerType,
    required this.activity,
    required this.environment,
  });
 
  factory UserInput.fromJson(Map<String, dynamic> json) {
    return UserInput(
      workerType: json['worker_type'] ?? '',
      activity: json['activity'] ?? '',
      environment: json['environment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'worker_type': workerType,
      'activity': activity,
      'environment': environment,
    };
  }
}
