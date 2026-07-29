class SensorData {
  final int hr;
  final int hrv;
  final int spo2;

  final double envTemp;
  final int humidity;

  final int mq2;
  final int mq5;
  final int mq135;

  final double accMag;
  final double gyroMag;

  const SensorData({
    required this.hr,
    required this.hrv,
    required this.spo2,
    required this.envTemp,
    required this.humidity,
    required this.mq2,
    required this.mq5,
    required this.mq135,
    required this.accMag,
    required this.gyroMag,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      hr: json['HR'] ?? 0,
      hrv: json['HRV'] ?? 0,
      spo2: json['SpO2'] ?? 0,
      envTemp: (json['env_temp'] as num?)?.toDouble() ?? 0,
      humidity: json['humidity'] ?? 0,
      mq2: json['MQ2'] ?? 0,
      mq5: json['MQ5'] ?? 0,
      mq135: json['MQ135'] ?? 0,
      accMag: (json['acc_mag'] as num?)?.toDouble() ?? 0,
      gyroMag: (json['gyro_mag'] as num?)?.toDouble() ?? 0,
    );
  }
}
