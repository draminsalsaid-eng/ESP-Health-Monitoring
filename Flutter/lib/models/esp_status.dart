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
  final int? progress;

  const ESPState({
    required this.status,
    required this.message,
    this.progress,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory ESPState.fromJson(
    Map<String, dynamic> json,
  ) {
    final String value =
        (json['status'] ?? 'idle')
            .toString()
            .trim()
            .toLowerCase();

    final String message =
        json['message']?.toString() ??
            'Ready';

    final int? progress =
        (json['progress'] as num?)?.toInt();

    switch (value) {
      // ----------------------------------------------------------
      // READY
      // ----------------------------------------------------------

      case 'ready':
        return ESPState(
          status: ESPStatus.idle,
          message: message,
          progress: progress,
        );

      // ----------------------------------------------------------
      // WAITING FOR FINGER
      // ----------------------------------------------------------

      case 'waiting_finger':
        return ESPState(
          status: ESPStatus.waitingFinger,
          message: message,
          progress: progress,
        );

      // ----------------------------------------------------------
      // MEASURING
      // ----------------------------------------------------------

      case 'measuring':
        return ESPState(
          status: ESPStatus.measuring,
          message: message,
          progress: progress,
        );

      // ----------------------------------------------------------
      // AI PROCESSING
      // ----------------------------------------------------------

      case 'processing':
      case 'processing_ai':
        return ESPState(
          status: ESPStatus.processingAI,
          message: message,
          progress: progress,
        );

      // ----------------------------------------------------------
      // COMPLETED
      // ----------------------------------------------------------

      case 'completed':
        return ESPState(
          status: ESPStatus.completed,
          message: message,
          progress: 100,
        );

      // ----------------------------------------------------------
      // ERRORS
      // ----------------------------------------------------------

      case 'error':
      case 'wifi_error':
      case 'finger_removed':
        return ESPState(
          status: ESPStatus.error,
          message: message,
          progress: progress,
        );

      // ----------------------------------------------------------
      // UNKNOWN
      // ----------------------------------------------------------

      default:
        return ESPState(
          status: ESPStatus.idle,
          message: message,
          progress: progress,
        );
    }
  }

  // ============================================================
  // STATE HELPERS
  // ============================================================

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
