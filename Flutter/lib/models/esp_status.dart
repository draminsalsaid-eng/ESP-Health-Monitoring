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

  factory ESPState.fromJson(Map<String, dynamic> json) {
    final String value =
        (json['status'] ?? 'idle').toString().toLowerCase();

    switch (value) {
      case 'waiting_finger':
        return const ESPState(
          status: ESPStatus.waitingFinger,
          message: 'Place your finger on MAX30105',
        );

      case 'measuring':
        return const ESPState(
          status: ESPStatus.measuring,
          message: 'Reading sensor data...',
        );

      case 'processing_ai':
        return const ESPState(
          status: ESPStatus.processingAI,
          message: 'Analyzing health data...',
        );

      case 'completed':
        return const ESPState(
          status: ESPStatus.completed,
          message: 'Health analysis completed',
        );

      case 'error':
        return ESPState(
          status: ESPStatus.error,
          message:
              json['message']?.toString() ?? 'ESP32 error',
        );

      default:
        return const ESPState(
          status: ESPStatus.idle,
          message: 'Ready',
        );
    }
  }

  bool get isIdle =>
      status == ESPStatus.idle;

  bool get isWaitingFinger =>
      status == ESPStatus.waitingFinger;

  bool get isMeasuring =>
      status == ESPStatus.measuring;

  bool get isProcessingAI =>
      status == ESPStatus.processingAI;

  bool get isCompleted =>
      status == ESPStatus.completed;

  bool get isError =>
      status == ESPStatus.error;
}
