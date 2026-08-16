class HealthResponse {
  final String workerType;
  final String activity;
  final String environment;

  final int heartRate;
  final int hrv;
  final int spo2;

  final double bodyTemperature;

  final double environmentTemperature;
  final double humidity;

  final int mq2;
  final int mq5;
  final int mq135;

  final double accMag;
  final double gyroMag;

  final String prediction;
  final double riskScore;
  final double environmentStress;
  final double activityStress;

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
  // SAFE NUMBER PARSERS
  // ============================================================

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static String _toString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory HealthResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return HealthResponse(
      // ----------------------------------------------------------
      // USER / WORKER INFORMATION
      // ----------------------------------------------------------

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

      // ----------------------------------------------------------
      // PHYSIOLOGICAL
      // ----------------------------------------------------------

      heartRate: _toInt(
        json['HR'],
      ),

      hrv: _toInt(
        json['HRV'],
      ),

      spo2: _toInt(
        json['SpO2'],
      ),

      // ----------------------------------------------------------
      // BODY TEMPERATURE
      // ----------------------------------------------------------

      bodyTemperature: _toDouble(
        json['body_temp'],
      ),

      // ----------------------------------------------------------
      // ENVIRONMENT
      // ----------------------------------------------------------

      environmentTemperature: _toDouble(
        json['env_temp'],
      ),

      humidity: _toDouble(
        json['humidity'],
      ),

      // ----------------------------------------------------------
      // GAS SENSORS
      // ----------------------------------------------------------

      mq2: _toInt(
        json['MQ2'],
      ),

      mq5: _toInt(
        json['MQ5'],
      ),

      mq135: _toInt(
        json['MQ135'],
      ),

      // ----------------------------------------------------------
      // MOTION
      // ----------------------------------------------------------

      accMag: _toDouble(
        json['acc_mag'],
      ),

      gyroMag: _toDouble(
        json['gyro_mag'],
      ),

      // ----------------------------------------------------------
      // AI
      // ----------------------------------------------------------

      prediction: _toString(
        json['prediction'],
      ),

      riskScore: _toDouble(
        json['risk_score'],
      ),

      environmentStress: _toDouble(
        json['environment_stress'] ??
            json['env_stress'],
      ),

      activityStress: _toDouble(
        json['activity_stress'],
      ),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'worker_type': workerType,
      'activity': activity,
      'environment': environment,

      'HR': heartRate,
      'HRV': hrv,
      'SpO2': spo2,

      // VERY IMPORTANT
      'body_temp': bodyTemperature,

      'env_temp': environmentTemperature,
      'humidity': humidity,

      'MQ2': mq2,
      'MQ5': mq5,
      'MQ135': mq135,

      'acc_mag': accMag,
      'gyro_mag': gyroMag,

      'prediction': prediction,
      'risk_score': riskScore,
      'environment_stress': environmentStress,
      'activity_stress': activityStress,
    };
  }
}
