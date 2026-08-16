class HealthResponse {
  // ============================================================
  // USER / ENVIRONMENT INFORMATION
  // ============================================================

  final String workerType;
  final String activity;
  final String environment;

  // ============================================================
  // PHYSIOLOGICAL DATA
  // ============================================================

  final int heartRate;
  final int hrv;
  final int spo2;

  // IMPORTANT:
  // Body temperature measured by MAX30205
  final double bodyTemperature;

  // ============================================================
  // ENVIRONMENT DATA
  // ============================================================

  final double environmentTemperature;
  final double humidity;

  // ============================================================
  // GAS SENSORS
  // ============================================================

  final int mq2;
  final int mq5;
  final int mq135;

  // ============================================================
  // MOTION DATA
  // ============================================================

  final double accMag;
  final double gyroMag;

  // ============================================================
  // AI RESULTS
  // ============================================================

  final String prediction;
  final double riskScore;
  final double environmentStress;
  final double activityStress;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const HealthResponse({
    required this.workerType,
    required this.activity,
    required this.environment,

    required this.heartRate,
    required this.hrv,
    required this.spo2,
    required this.bodyTemperature,

    required this.environmentTemperature,
    required this.humidity,

    required this.mq2,
    required this.mq5,
    required this.mq135,

    required this.accMag,
    required this.gyroMag,

    required this.prediction,
    required this.riskScore,
    required this.environmentStress,
    required this.activityStress,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory HealthResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return HealthResponse(

      // ----------------------------------------------------------
      // USER / ENVIRONMENT
      // ----------------------------------------------------------

      workerType:
          json['worker_type']?.toString() ?? '',

      activity:
          json['activity']?.toString() ?? '',

      environment:
          json['environment']?.toString() ??
          json['workplace']?.toString() ??
          '',

      // ----------------------------------------------------------
      // PHYSIOLOGICAL DATA
      // ----------------------------------------------------------

      heartRate:
          (json['HR'] as num?)?.toInt() ?? 0,

      hrv:
          (json['HRV'] as num?)?.toInt() ?? 0,

      spo2:
          (json['SpO2'] as num?)?.toInt() ?? 0,

      // ----------------------------------------------------------
      // BODY TEMPERATURE
      //
      // MAX30205 -> ESP32 -> API -> Flutter
      //
      // JSON key:
      // "body_temp"
      // ----------------------------------------------------------

      bodyTemperature:
          (json['body_temp'] as num?)?.toDouble() ?? 0.0,

      // ----------------------------------------------------------
      // ENVIRONMENT
      // ----------------------------------------------------------

      environmentTemperature:
          (json['env_temp'] as num?)?.toDouble() ?? 0.0,

      humidity:
          (json['humidity'] as num?)?.toDouble() ?? 0.0,

      // ----------------------------------------------------------
      // GAS SENSORS
      // ----------------------------------------------------------

      mq2:
          (json['MQ2'] as num?)?.toInt() ?? 0,

      mq5:
          (json['MQ5'] as num?)?.toInt() ?? 0,

      mq135:
          (json['MQ135'] as num?)?.toInt() ?? 0,

      // ----------------------------------------------------------
      // MOTION
      // ----------------------------------------------------------

      accMag:
          (json['acc_mag'] as num?)?.toDouble() ?? 0.0,

      gyroMag:
          (json['gyro_mag'] as num?)?.toDouble() ?? 0.0,

      // ----------------------------------------------------------
      // AI RESULTS
      // ----------------------------------------------------------

      prediction:
          json['prediction']?.toString() ?? '',

      riskScore:
          (json['risk_score'] as num?)?.toDouble() ?? 0.0,

      environmentStress:
          (json['environment_stress'] as num?)?.toDouble() ??
          (json['env_stress'] as num?)?.toDouble() ??
          0.0,

      activityStress:
          (json['activity_stress'] as num?)?.toDouble() ??
          0.0,
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      // User / environment
      "worker_type": workerType,
      "activity": activity,
      "environment": environment,

      // Physiological
      "HR": heartRate,
      "HRV": hrv,
      "SpO2": spo2,

      // IMPORTANT
      "body_temp": bodyTemperature,

      // Environment
      "env_temp": environmentTemperature,
      "humidity": humidity,

      // Gas sensors
      "MQ2": mq2,
      "MQ5": mq5,
      "MQ135": mq135,

      // Motion
      "acc_mag": accMag,
      "gyro_mag": gyroMag,

      // AI
      "prediction": prediction,
      "risk_score": riskScore,
      "environment_stress": environmentStress,
      "activity_stress": activityStress,
    };
  }
}
