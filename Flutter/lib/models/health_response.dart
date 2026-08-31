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
  // ENVIRONMENT
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
  // MOTION
  // ============================================================

  final double accMag;
  final double gyroMag;

  // ============================================================
  // AI
  // ============================================================

  final String prediction;

  final double riskScore;
  final String riskLevel;
  final String alertLevel;

  final double cardiacStress;
  final double oxygenRisk;

  final double fatigueIndex;
  final double heatStress;
  final double bodyTemperatureEffect;
  final double environmentStress;
  final double activityStress;

  final double motionIndex;
  final double motionStress;

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

    required this.cardiacStress,
    required this.oxygenRisk,

    required this.fatigueIndex,
    required this.heatStress,
    required this.bodyTemperatureEffect,
    required this.environmentStress,
    required this.activityStress,

    required this.motionIndex,
    required this.motionStress,
  });

  // ============================================================
  // NUMBER PARSERS
  // ============================================================

  static double _double(
    Map<String, dynamic> json,
    String key, {
    String? alternative,
  }) {
    dynamic value = json[key];

    if (value == null && alternative != null) {
      value = json[alternative];
    }

    if (value == null) {
      throw FormatException(
        'Missing required health field: $key'
        '${alternative != null ? ' / $alternative' : ''}',
      );
    }

    if (value is num) {
      return value.toDouble();
    }

    final parsed = double.tryParse(
      value.toString().trim(),
    );

    if (parsed == null) {
      throw FormatException(
        'Invalid numeric value for $key: $value',
      );
    }

    return parsed;
  }

  static int _int(
    Map<String, dynamic> json,
    String key, {
    String? alternative,
  }) {
    dynamic value = json[key];

    if (value == null && alternative != null) {
      value = json[alternative];
    }

    if (value == null) {
      throw FormatException(
        'Missing required health field: $key'
        '${alternative != null ? ' / $alternative' : ''}',
      );
    }

    if (value is num) {
      return value.toInt();
    }

    final text = value.toString().trim();

    final integer = int.tryParse(text);

    if (integer != null) {
      return integer;
    }

    final decimal = double.tryParse(text);

    if (decimal != null) {
      return decimal.toInt();
    }

    throw FormatException(
      'Invalid integer value for $key: $value',
    );
  }

  // ============================================================
  // STRING PARSER
  // ============================================================

  static String _string(
    Map<String, dynamic> json,
    String key, {
    String? alternative,
    String defaultValue = '',
  }) {
    dynamic value = json[key];

    if (value == null && alternative != null) {
      value = json[alternative];
    }

    if (value == null) {
      return defaultValue;
    }

    return value.toString().trim();
  }

  // ============================================================
  // STRESS
  // ============================================================

  static double _stress(
    Map<String, dynamic> json,
    String key, {
    String? alternative,
  }) {
    dynamic value = json[key];

    if (value == null && alternative != null) {
      value = json[alternative];
    }

    if (value == null) {
      return 0.0;
    }

    final number = value is num
        ? value.toDouble()
        : double.tryParse(
              value.toString().trim(),
            );

    if (number == null ||
        number.isNaN ||
        number.isInfinite) {
      return 0.0;
    }

    // API returns 0.0 - 1.0
    if (number <= 1.0) {
      return number.clamp(0.0, 1.0);
    }

    // API may return 0 - 100
    return (number / 100.0).clamp(0.0, 1.0);
  }

  // ============================================================
  // RISK SCORE
  // ============================================================

  static double _risk(
    Map<String, dynamic> json,
  ) {
    final value = json['risk_score'];

    if (value == null) {
      return 0.0;
    }

    final number = value is num
        ? value.toDouble()
        : double.tryParse(
              value.toString().trim(),
            );

    if (number == null ||
        number.isNaN ||
        number.isInfinite) {
      return 0.0;
    }

    // API returns 0 - 1
    if (number <= 1.0) {
      return (number * 100.0).clamp(0.0, 100.0);
    }

    // API returns 0 - 100
    return number.clamp(0.0, 100.0);
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory HealthResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    // ----------------------------------------------------------
    // DEBUG
    // ----------------------------------------------------------

    print('');
    print('==========================================');
    print('HealthResponse.fromJson');
    print('Received keys:');
    print(json.keys.toList());
    print('==========================================');

    final result = HealthResponse(
      // ========================================================
      // PROFILE
      // ========================================================

      workerType: _string(
        json,
        'worker_type',
      ),

      activity: _string(
        json,
        'activity',
      ),

      environment: _string(
        json,
        'environment',
        alternative: 'workplace',
      ),

      // ========================================================
      // PHYSIOLOGICAL
      // ========================================================

      heartRate: _int(
        json,
        'HR',
        alternative: 'heart_rate',
      ),

      hrv: _int(
        json,
        'HRV',
        alternative: 'hrv',
      ),

      spo2: _int(
        json,
        'SpO2',
        alternative: 'spo2',
      ),

      bodyTemperature: _double(
        json,
        'body_temp',
        alternative: 'body_temperature',
      ),

      // ========================================================
      // ENVIRONMENT
      // ========================================================

      environmentTemperature: _double(
        json,
        'env_temp',
        alternative: 'environment_temperature',
      ),

      humidity: _double(
        json,
        'humidity',
      ),

      // ========================================================
      // GAS
      // ========================================================

      mq2: _int(
        json,
        'MQ2',
        alternative: 'mq2',
      ),

      mq5: _int(
        json,
        'MQ5',
        alternative: 'mq5',
      ),

      mq135: _int(
        json,
        'MQ135',
        alternative: 'mq135',
      ),

      // ========================================================
      // MOTION
      // ========================================================

      accMag: _double(
        json,
        'acc_mag',
        alternative: 'acceleration',
      ),

      gyroMag: _double(
        json,
        'gyro_mag',
        alternative: 'rotation',
      ),

      // ========================================================
      // AI
      // ========================================================

      prediction: _string(
        json,
        'prediction',
      ),

      riskScore: _risk(
        json,
      ),

      riskLevel: _string(
        json,
        'risk_level',
      ),

      alertLevel: _string(
        json,
        'alert_level',
      ),

      cardiacStress: _stress(
        json,
        'cardiac_stress',
      ),

      oxygenRisk: _stress(
        json,
        'oxygen_risk',
      ),

      fatigueIndex: _stress(
        json,
        'fatigue_index',
      ),

      heatStress: _stress(
        json,
        'heat_stress',
      ),

      bodyTemperatureEffect: _stress(
        json,
        'body_temp_effect',
      ),

      environmentStress: _stress(
        json,
        'environmental_stress',
        alternative: 'environment_stress',
      ),

      activityStress: _stress(
        json,
        'activity_stress',
      ),

      motionIndex: _double(
        json,
        'motion_index',
      ),

      motionStress: _stress(
        json,
        'motion_stress',
      ),
    );

    // ==========================================================
    // DEBUG VALUES
    // ==========================================================

    print('');
    print('========== PARSED HEALTH DATA ==========');
    print('Worker Type: ${result.workerType}');
    print('Activity: ${result.activity}');
    print('Environment: ${result.environment}');
    print('HR: ${result.heartRate}');
    print('HRV: ${result.hrv}');
    print('SpO2: ${result.spo2}');
    print('Body Temp: ${result.bodyTemperature}');
    print('Environment Temp: ${result.environmentTemperature}');
    print('Humidity: ${result.humidity}');
    print('MQ2: ${result.mq2}');
    print('MQ5: ${result.mq5}');
    print('MQ135: ${result.mq135}');
    print('ACC: ${result.accMag}');
    print('GYRO: ${result.gyroMag}');
    print('Risk Score: ${result.riskScore}');
    print('Risk Level: ${result.riskLevel}');
    print('Alert Level: ${result.alertLevel}');
    print('Cardiac Stress: ${result.cardiacStress}');
    print('Oxygen Risk: ${result.oxygenRisk}');
    print('Fatigue: ${result.fatigueIndex}');
    print('Heat Stress: ${result.heatStress}');
    print('Body Temp Effect: ${result.bodyTemperatureEffect}');
    print('Environmental Stress: ${result.environmentStress}');
    print('Activity Stress: ${result.activityStress}');
    print('Motion Index: ${result.motionIndex}');
    print('Motion Stress: ${result.motionStress}');
    print('========================================');
    print('');

    return result;
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
      'risk_level': riskLevel,
      'alert_level': alertLevel,

      'cardiac_stress': cardiacStress,
      'oxygen_risk': oxygenRisk,

      'fatigue_index': fatigueIndex,
      'heat_stress': heatStress,
      'body_temp_effect': bodyTemperatureEffect,
      'environmental_stress': environmentStress,
      'activity_stress': activityStress,

      'motion_index': motionIndex,
      'motion_stress': motionStress,
    };
  }
}
