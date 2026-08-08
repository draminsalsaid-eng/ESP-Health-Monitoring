class HealthResponse {
  final String workerType;
  final String activity;
  final String environment;

  final int heartRate;
  final int hrv;
  final int spo2;

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

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      workerType: json['worker_type'] ?? '',
      activity: json['activity'] ?? '',
      environment: json['environment'] ?? '',

      heartRate: (json['HR'] as num?)?.toInt() ?? 0,
      hrv: (json['HRV'] as num?)?.toInt() ?? 0,
      spo2: (json['SpO2'] as num?)?.toInt() ?? 0,

      environmentTemperature:
          (json['env_temp'] as num?)?.toDouble() ?? 0,

      humidity:
          (json['humidity'] as num?)?.toDouble() ?? 0,

      mq2: (json['MQ2'] as num?)?.toInt() ?? 0,
      mq5: (json['MQ5'] as num?)?.toInt() ?? 0,
      mq135: (json['MQ135'] as num?)?.toInt() ?? 0,

      accMag:
          (json['acc_mag'] as num?)?.toDouble() ?? 0,

      gyroMag:
          (json['gyro_mag'] as num?)?.toDouble() ?? 0,

      prediction:
          json['prediction'] ?? '',

      riskScore:
          (json['risk_score'] as num?)?.toDouble() ?? 0,

      environmentStress:
          (json['environment_stress'] ??
                  json['env_stress'] ??
                  0)
              .toDouble(),

      activityStress:
          (json['activity_stress'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'worker_type': workerType,
      'activity': activity,
      'environment': environment,

      'HR': heartRate,
      'HRV': hrv,
      'SpO2': spo2,

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
