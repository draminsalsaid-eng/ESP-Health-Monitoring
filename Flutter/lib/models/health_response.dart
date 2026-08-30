class HealthResponse {
  // ============================================================
  // WORKER PROFILE
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
  // GAS SENSOR RAW VALUES
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
  // AI ANALYSIS
  // ============================================================

  final String alertLevel;
  final String riskLevel;

  final double riskScore;

  final double cardiacStress;
  final double oxygenRisk;
  final double fatigueIndex;
  final double heatStress;
  final double bodyTemperatureEffect;
  final double environmentalStress;
  final double activityStress;
  final double motionIndex;
  final double motionStress;

  // ============================================================
  // STATUS
  // ============================================================

  final String status;
  final String message;

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

    required this.alertLevel,
    required this.riskLevel,
    required this.riskScore,

    required this.cardiacStress,
    required this.oxygenRisk,
    required this.fatigueIndex,
    required this.heatStress,
    required this.bodyTemperatureEffect,
    required this.environmentalStress,
    required this.activityStress,
    required this.motionIndex,
    required this.motionStress,

    required this.status,
    required this.message,
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
      value.toString(),
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

    final parsed = double.tryParse(
      value.toString(),
    );

    return parsed?.toInt() ?? 0;
  }

  // ============================================================
  // SAFE STRING PARSER
  // ============================================================

  static String _toString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // NORMALIZE TEXT
  // ============================================================

  static String _normalizeText(dynamic value) {
    return _toString(value)
        .trim()
        .toLowerCase();
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory HealthResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return HealthResponse(

      // ========================================================
      // WORKER PROFILE
      // ========================================================

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

      // ========================================================
      // PHYSIOLOGICAL
      // ========================================================

      heartRate: _toInt(
        json['HR'],
      ),

      hrv: _toInt(
        json['HRV'],
      ),

      spo2: _toInt(
        json['SpO2'],
      ),

      bodyTemperature: _toDouble(
        json['body_temp'],
      ),

      // ========================================================
      // ENVIRONMENT
      // ========================================================

      environmentTemperature: _toDouble(
        json['env_temp'],
      ),

      humidity: _toDouble(
        json['humidity'],
      ),

      // ========================================================
      // GAS SENSORS
      // ========================================================

      mq2: _toInt(
        json['MQ2'],
      ),

      mq5: _toInt(
        json['MQ5'],
      ),

      mq135: _toInt(
        json['MQ135'],
      ),

      // ========================================================
      // MOTION
      // ========================================================

      accMag: _toDouble(
        json['acc_mag'],
      ),

      gyroMag: _toDouble(
        json['gyro_mag'],
      ),

      // ========================================================
      // AI RESULT
      //
      // IMPORTANT:
      // ESP32 now sends:
      //
      // alert_level
      // risk_level
      //
      // NOT prediction.
      // ========================================================

      alertLevel: _normalizeText(
        json['alert_level'],
      ),

      riskLevel: _normalizeText(
        json['risk_level'],
      ),

      riskScore: _toDouble(
        json['risk_score'],
      ),

      // ========================================================
      // AI COMPONENTS
      // ========================================================

      cardiacStress: _toDouble(
        json['cardiac_stress'],
      ),

      oxygenRisk: _toDouble(
        json['oxygen_risk'],
      ),

      fatigueIndex: _toDouble(
        json['fatigue_index'],
      ),

      heatStress: _toDouble(
        json['heat_stress'],
      ),

      bodyTemperatureEffect: _toDouble(
        json['body_temp_effect'],
      ),

      environmentalStress: _toDouble(
        json['environmental_stress'] ??
            json['environment_stress'] ??
            json['env_stress'],
      ),

      activityStress: _toDouble(
        json['activity_stress'],
      ),

      motionIndex: _toDouble(
        json['motion_index'],
      ),

      motionStress: _toDouble(
        json['motion_stress'],
      ),

      // ========================================================
      // STATUS
      // ========================================================

      status: _toString(
        json['status'],
      ),

      message: _toString(
        json['message'],
      ),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      // Worker profile
      'worker_type': workerType,
      'activity': activity,
      'environment': environment,

      // Physiological
      'HR': heartRate,
      'HRV': hrv,
      'SpO2': spo2,
      'body_temp': bodyTemperature,

      // Environment
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
      'alert_level': alertLevel,
      'risk_level': riskLevel,
      'risk_score': riskScore,

      'cardiac_stress': cardiacStress,
      'oxygen_risk': oxygenRisk,
      'fatigue_index': fatigueIndex,
      'heat_stress': heatStress,
      'body_temp_effect': bodyTemperatureEffect,
      'environmental_stress': environmentalStress,
      'activity_stress': activityStress,
      'motion_index': motionIndex,
      'motion_stress': motionStress,

      // Status
      'status': status,
      'message': message,
    };
  }

  // ============================================================
  // HELPER: HAS AI DATA
  // ============================================================

  bool get hasAIAnalysis {
    return alertLevel.isNotEmpty ||
        riskLevel.isNotEmpty ||
        riskScore > 0 ||
        cardiacStress > 0 ||
        oxygenRisk > 0 ||
        fatigueIndex > 0 ||
        heatStress > 0 ||
        bodyTemperatureEffect > 0 ||
        environmentalStress > 0 ||
        activityStress > 0 ||
        motionIndex > 0 ||
        motionStress > 0;
  }

  // ============================================================
  // HELPER: ALERT LEVEL
  // ============================================================

  String get displayAlertLevel {
    if (alertLevel.isEmpty) {
      return 'Unknown';
    }

    switch (alertLevel) {
      case 'green':
        return 'Safe';

      case 'yellow':
        return 'Warning';

      case 'red':
        return 'Danger';

      default:
        return alertLevel;
    }
  }

  // ============================================================
  // HELPER: RISK LEVEL
  // ============================================================

  String get displayRiskLevel {
    if (riskLevel.isEmpty) {
      return 'Unknown';
    }

    switch (riskLevel) {
      case 'low':
        return 'Low Risk';

      case 'medium':
        return 'Medium Risk';

      case 'high':
        return 'High Risk';

      default:
        return riskLevel;
    }
  }
}
