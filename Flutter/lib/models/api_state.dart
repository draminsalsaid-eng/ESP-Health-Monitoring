enum ApiStatus {
  idle,
  connecting,
  waitingSensor,
  readingData,
  processingAI,
  success,
  error,
}

class ApiState {
  final ApiStatus status;
  final String message;

  const ApiState._({
    required this.status,
    required this.message,
  });

  factory ApiState.idle() {
    return const ApiState._(
      status: ApiStatus.idle,
      message: 'Press Start Monitoring',
    );
  }

  factory ApiState.connecting() {
    return const ApiState._(
      status: ApiStatus.connecting,
      message: 'Connecting to ESP32...',
    );
  }

  factory ApiState.waitingSensor() {
    return const ApiState._(
      status: ApiStatus.waitingSensor,
      message: 'Place your finger on the MAX30105 sensor',
    );
  }

  factory ApiState.readingData() {
    return const ApiState._(
      status: ApiStatus.readingData,
      message: 'Reading sensor data...',
    );
  }

  factory ApiState.processingAI() {
    return const ApiState._(
      status: ApiStatus.processingAI,
      message: 'Analyzing health data...',
    );
  }

  factory ApiState.success(String message) {
    return ApiState._(
      status: ApiStatus.success,
      message: message,
    );
  }

  factory ApiState.error(String message) {
    return ApiState._(
      status: ApiStatus.error,
      message: message,
    );
  }

  bool get isIdle => status == ApiStatus.idle;

  bool get isConnecting => status == ApiStatus.connecting;

  bool get isWaitingSensor => status == ApiStatus.waitingSensor;

  bool get isReadingData => status == ApiStatus.readingData;

  bool get isProcessingAI => status == ApiStatus.processingAI;

  bool get isSuccess => status == ApiStatus.success;

  bool get isError => status == ApiStatus.error;
}
