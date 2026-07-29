class AIResult {
  final String prediction;

  final double riskScore;
  final double environmentStress;
  final double activityStress;

  const AIResult({
    required this.prediction,
    required this.riskScore,
    required this.environmentStress,
    required this.activityStress,
  });

  factory AIResult.fromJson(Map<String, dynamic> json) {
    return AIResult(
      prediction: json['prediction'] ?? '',
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0,
      environmentStress:
          (json['environment_stress'] as num?)?.toDouble() ?? 0,
      activityStress:
          (json['activity_stress'] as num?)?.toDouble() ?? 0,
    );
  }
}
