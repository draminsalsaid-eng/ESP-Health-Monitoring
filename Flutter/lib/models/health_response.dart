class HealthResponse {
  // ============================================================
  // WORKER / PROFILE
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

  final double bodyTemperature;

  // ============================================================
  // ENVIRONMENT DATA
  // ============================================================

  final double environmentTemperature;
  final double humidity;

  // ============================================================
  // GAS / AIR QUALITY SENSORS
  //
  // These are raw ADC sensor values.
  // They are NOT ppm.
  // ============================================================

  final int mq2;
  final int mq5;
  final int mq135;

  // ============================================================
  // MOTION
  // ============================================================

  final double accMag;
  final double gyroMag;

  // ============================================================
  // AI HEALTH ANALYSIS
  // ============================================================

  final String prediction;

  final double riskScore;

  final String riskLevel;

  final String alertLevel;

  final double heatStress;

  final double environmentStress;

  final double activityStress;

  final double fatigueIndex;

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
    required this.riskLevel,
    required this.alertLevel,
    required this.heatStress,
    required this.environmentStress,
    required this.activityStress,
    required this.fatigueIndex,
  });

  // ============================================================
  // SAFE DOUBLE PARSER
  // ============================================================

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    final parsed = double.tryParse(
      value.toString().trim(),
    );

    return parsed ?? 0.0;
  }

  // ============================================================
  // SAFE INT PARSER
  // ============================================================

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    final parsed = int.tryParse(
      value.toString().trim(),
    );

    if (parsed != null) {
      return parsed;
    }

    // Handles values such as "1234.0"
    final doubleValue = double.tryParse(
      value.toString().trim(),
    );

    return doubleValue?.toInt() ?? 0;
  }

  // ============================================================
  // SAFE STRING PARSER
  // ============================================================

  static String _toString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  // ============================================================
  // NORMALIZE STRESS VALUE
  //
  // AI values are expected to be either:
  //
  // 0.0 → 1.0
  //
  // or:
  //
  // 0 → 100
  //
  // This function converts everything to 0.0 → 1.0.
  // ============================================================

  static double _normalizeStressValue(
    dynamic value,
  ) {
    final number = _toDouble(value);

    if (number.isNaN || number.isInfinite) {
      return 0.0;
    }

    if (number <= 0) {
      return 0.0;
    }

    // If AI sends percentage 0–100
    if (number > 1.0) {
      return (number / 100.0).clamp(
        0.0,
        1.0,
      );
    }

    return number.clamp(
      0.0,
      1.0,
    );
  }

  // ============================================================
  // NORMALIZE RISK SCORE
  //
  // Dashboard expects risk score as 0–100.
  //
  // If ESP32/API sends 0–1, convert it to 0–100.
  // ============================================================

  static double _normalizeRiskScore(
    dynamic value,
  ) {
    final number = _toDouble(value);

    if (number.isNaN || number.isInfinite) {
      return 0.0;
    }

    if (number <= 0) {
      return 0.0;
    }

    if (number <= 1.0) {
      return (number * 100.0).clamp(
        0.0,
        100.0,
      );
    }

    return number.clamp(
      0.0,
      100.0,
    );
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory HealthResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return HealthResponse(

      // ==========================================================
      // WORKER / PROFILE
      // ==========================================================

      workerType: _toString(
        json['worker_type'],
      ),

      activity: _toString(
        json['activity'],
      ),

      environment: _toString(
        json['environment'] ??
            json['workplace'],
      ),

      // ==========================================================
      // PHYSIOLOGICAL
      // ==========================================================

      heartRate: _toInt(
        json['HR'] ??
            json['heart_rate'],
      ),

      hrv: _toInt(
        json['HRV'] ??
            json['hrv'],
      ),

      spo2: _toInt(
        json['SpO2'] ??
            json['spo2'],
      ),

      // ==========================================================
      // BODY TEMPERATURE
      // ==========================================================

      bodyTemperature: _toDouble(
        json['body_temp'] ??
            json['body_temperature'],
      ),

      // ==========================================================
      // ENVIRONMENT
      // ==========================================================

      environmentTemperature: _toDouble(
        json['env_temp'] ??
            json['environment_temperature'],
      ),

      humidity: _toDouble(
        json['humidity'],
      ),

      // ==========================================================
      // GAS SENSORS
      // ==========================================================

      mq2: _toInt(
        json['MQ2'] ??
            json['mq2'],
      ),

      mq5: _toInt(
        json['MQ5'] ??
            json['mq5'],
      ),

      mq135: _toInt(
        json['MQ135'] ??
            json['mq135'],
      ),

      // ==========================================================
      // MOTION
      // ==========================================================

      accMag: _toDouble(
        json['acc_mag'] ??
            json['acceleration'],
      ),

      gyroMag: _toDouble(
        json['gyro_mag'] ??
            json['rotation'],
      ),

      // ==========================================================
      // AI
      // ==========================================================

      prediction: _toString(
        json['prediction'],
      ),

      riskScore: _normalizeRiskScore(
        json['risk_score'],
      ),

      riskLevel: _toString(
        json['risk_level'],
      ),

      alertLevel: _toString(
        json['alert_level'],
      ),

      heatStress: _normalizeStressValue(
        json['heat_stress'],
      ),

      environmentStress: _normalizeStressValue(
        json['environmental_stress'] ??
            json['environment_stress'] ??
            json['env_stress'],
      ),

      activityStress: _normalizeStressValue(
        json['activity_stress'],
      ),

      fatigueIndex: _normalizeStressValue(
        json['fatigue_index'],
      ),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      // Worker
      'worker_type': workerType,
      'activity': activity,
      'environment': environment,

      // Physiological
      'HR': heartRate,
      'HRV': hrv,
      'SpO2': spo2,

      // Temperature
      'body_temp': bodyTemperature,
      'env_temp': environmentTemperature,
      'humidity': humidity,

      // Gas sensors
      'MQ2': mq2,
      'MQ5': mq5,
      'MQ135': mq135,

      // Motion
      'acc_mag': accMag,
      'gyro_mag': gyroMag,

      // AI
      'prediction': prediction,
      'risk_score': riskScore,
      'risk_level': riskLevel,
      'alert_level': alertLevel,
      'heat_stress': heatStress,
      'environmental_stress': environmentStress,
      'activity_stress': activityStress,
      'fatigue_index': fatigueIndex,
    };
  }
}
