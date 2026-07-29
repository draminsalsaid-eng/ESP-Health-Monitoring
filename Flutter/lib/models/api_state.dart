enum ApiStatus {
  idle,
  loading,
  success,
  error,
}

class ApiState {
  final ApiStatus status;
  final String? message;

  const ApiState({
    required this.status,
    this.message,
  });

  factory ApiState.idle() {
    return const ApiState(status: ApiStatus.idle);
  }

  factory ApiState.loading([String? message]) {
    return ApiState(
      status: ApiStatus.loading,
      message: message,
    );
  }

  factory ApiState.success([String? message]) {
    return ApiState(
      status: ApiStatus.success,
      message: message,
    );
  }

  factory ApiState.error(String message) {
    return ApiState(
      status: ApiStatus.error,
      message: message,
    );
  }
}
