import 'package:flutter/foundation.dart';

class HealthResponse {
// =========================================
// WORKER / MEASUREMENT CONTEXT
// =========================================

final String workerType;
final String activity;
final String environment;

// =========================================
// HEALTH SENSOR DATA
// =========================================

final int heartRate;
final int hrv;
final int spo2;

// =========================================
// ENVIRONMENT SENSOR DATA
// =========================================

final double envTemp;
final double humidity;

final int mq2;
final int mq5;
final int mq135;

// =========================================
// MOTION DATA
// =========================================

final double accMag;
final double gyroMag;

// =========================================
// AI RESULTS
// =========================================

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
required this.envTemp,
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

// =========================================
// FROM JSON
// =========================================

factory HealthResponse.fromJson(
Map<String, dynamic> json,
) {
return HealthResponse(
workerType:
json['worker_type']?.toString() ?? '',

```
  activity:
      json['activity']?.toString() ?? '',

  environment:
      json['environment']?.toString() ?? '',

  heartRate:
      (json['HR'] as num?)?.toInt() ?? 0,

  hrv:
      (json['HRV'] as num?)?.toInt() ?? 0,

  spo2:
      (json['SpO2'] as num?)?.toInt() ?? 0,

  envTemp:
      (json['env_temp'] as num?)?.toDouble() ?? 0.0,

  humidity:
      (json['humidity'] as num?)?.toDouble() ?? 0.0,

  mq2:
      (json['MQ2'] as num?)?.toInt() ?? 0,

  mq5:
      (json['MQ5'] as num?)?.toInt() ?? 0,

  mq135:
      (json['MQ135'] as num?)?.toInt() ?? 0,

  accMag:
      (json['acc_mag'] as num?)?.toDouble() ?? 0.0,

  gyroMag:
      (json['gyro_mag'] as num?)?.toDouble() ?? 0.0,

  prediction:
      json['prediction']?.toString() ?? '',

  riskScore:
      (json['risk_score'] as num?)?.toDouble() ?? 0.0,

  environmentStress:
      (json['environment_stress'] as num?)?.toDouble() ??
          0.0,

  activityStress:
      (json['activity_stress'] as num?)?.toDouble() ??
          0.0,
);
```

}

// =========================================
// TO JSON
// =========================================

Map<String, dynamic> toJson() {
return {
'worker_type': workerType,
'activity': activity,
'environment': environment,

```
  'HR': heartRate,
  'HRV': hrv,
  'SpO2': spo2,

  'env_temp': envTemp,
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
```

}

// =========================================
// HELPER
// =========================================

bool get isSafe =>
prediction.toLowerCase() == 'green';

bool get isWarning =>
prediction.toLowerCase() == 'yellow';

bool get isDanger =>
prediction.toLowerCase() == 'red';
}
