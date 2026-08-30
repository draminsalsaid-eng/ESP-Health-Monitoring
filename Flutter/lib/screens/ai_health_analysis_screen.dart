import 'package:flutter/material.dart';
import '../models/health_response.dart';

class AIHealthAnalysisScreen extends StatelessWidget {
  final HealthResponse healthData;

  const AIHealthAnalysisScreen({
    super.key,
    required this.healthData,
  });

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatLabel(String value) {
    if (value.trim().isEmpty) {
      return 'Not available';
    }

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  String _riskTitle() {
    final risk = healthData.riskLevel.toLowerCase();

    switch (risk) {
      case 'low':
        return 'Low Risk';

      case 'medium':
        return 'Moderate Risk';

      case 'high':
        return 'High Risk';

      default:
        return 'Risk Assessment';
    }
  }

  IconData _riskIcon() {
    final risk = healthData.riskLevel.toLowerCase();

    switch (risk) {
      case 'low':
        return Icons.check_circle_rounded;

      case 'medium':
        return Icons.warning_rounded;

      case 'high':
        return Icons.error_rounded;

      default:
        return Icons.health_and_safety_rounded;
    }
  }

  Color _riskColor(BuildContext context) {
    final risk = healthData.riskLevel.toLowerCase();

    switch (risk) {
      case 'low':
        return Colors.green;

      case 'medium':
        return Colors.orange;

      case 'high':
        return Colors.red;

      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _riskDescription() {
    final risk = healthData.riskLevel.toLowerCase();

    switch (risk) {
      case 'low':
        return 'The current measurements indicate a low overall health risk. '
            'Continue normal work practices and stay hydrated.';

      case 'medium':
        return 'The current measurements indicate a moderate level of concern. '
            'Consider taking a short break, hydrating, and monitoring your condition.';

      case 'high':
        return 'The current measurements indicate a high level of concern. '
            'Stop or reduce strenuous activity and seek appropriate assistance if symptoms occur.';

      default:
        return 'The AI health assessment is not currently available.';
    }
  }

  String _alertTitle() {
    final alert = healthData.alertLevel.toLowerCase();

    switch (alert) {
      case 'green':
        return 'Safe';

      case 'yellow':
        return 'Warning';

      case 'red':
        return 'Danger';

      default:
        return 'No Alert';
    }
  }

  Color _alertColor(BuildContext context) {
    final alert = healthData.alertLevel.toLowerCase();

    switch (alert) {
      case 'green':
        return Colors.green;

      case 'yellow':
        return Colors.orange;

      case 'red':
        return Colors.red;

      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  // ============================================================
  // SCORE HELPERS
  // ============================================================

  double _normalizeStress(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0;
    }

    if (value < 0) {
      return 0;
    }

    if (value > 1) {
      return 1;
    }

    return value;
  }

  String _stressDescription(double value) {
    final normalized = _normalizeStress(value);

    if (normalized < 0.35) {
      return 'Low';
    }

    if (normalized < 0.70) {
      return 'Moderate';
    }

    return 'High';
  }

  Color _stressColor(
    BuildContext context,
    double value,
  ) {
    final normalized = _normalizeStress(value);

    if (normalized < 0.35) {
      return Colors.green;
    }

    if (normalized < 0.70) {
      return Colors.orange;
    }

    return Colors.red;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(context);
    final alertColor = _alertColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Health Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ==================================================
              // AI HEADER
              // ==================================================

              _buildHeaderCard(
                context,
                riskColor,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // OVERALL RESULT
              // ==================================================

              _buildOverallResultCard(
                context,
                riskColor,
                alertColor,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // USER PROFILE
              // ==================================================

              _buildProfileCard(
                context,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // HEALTH SUMMARY
              // ==================================================

              _buildHealthSummary(
                context,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // AI INSIGHTS
              // ==================================================

              _buildAIInsights(
                context,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // IMPORTANT INFORMATION
              // ==================================================

              _buildInformationCard(
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeaderCard(
    BuildContext context,
    Color riskColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Row(
          children: [

            Container(
              width: 58,
              height: 58,

              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.auto_awesome_rounded,
                color: riskColor,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: const [

                  Text(
                    'AI Health Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Personalized analysis based on your measurements',
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OVERALL RESULT
  // ============================================================

  Widget _buildOverallResultCard(
    BuildContext context,
    Color riskColor,
    Color alertColor,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Row(
              children: [

                Icon(
                  _riskIcon(),
                  color: riskColor,
                  size: 34,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    _riskTitle(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    _alertTitle(),
                    style: TextStyle(
                      color: alertColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                _riskDescription(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Risk score
            Row(
              children: [

                const Text(
                  'AI Risk Score',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  '${healthData.riskScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: (healthData.riskScore / 100)
                  .clamp(0.0, 1.0),

              minHeight: 8,

              borderRadius:
                  BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfileCard(
    BuildContext context,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Work Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _infoRow(
              Icons.badge_outlined,
              'Worker Type',
              _formatLabel(
                healthData.workerType,
              ),
            ),

            _infoRow(
              Icons.work_outline,
              'Activity',
              _formatLabel(
                healthData.activity,
              ),
            ),

            _infoRow(
              Icons.location_on_outlined,
              'Environment',
              _formatLabel(
                healthData.environment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEALTH SUMMARY
  // ============================================================

  Widget _buildHealthSummary(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Padding(
          padding: EdgeInsets.only(
            left: 4,
            bottom: 12,
          ),

          child: Text(
            'Health Summary',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        GridView.count(
          crossAxisCount: 2,

          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          crossAxisSpacing: 12,
          mainAxisSpacing: 12,

          childAspectRatio: 1.35,

          children: [

            _metricCard(
              context,
              Icons.favorite_rounded,
              'Heart Rate',
              '${healthData.heartRate}',
              'BPM',
            ),

            _metricCard(
              context,
              Icons.monitor_heart_outlined,
              'HRV',
              '${healthData.hrv}',
              'ms',
            ),

            _metricCard(
              context,
              Icons.air_rounded,
              'Oxygen',
              '${healthData.spo2}',
              '%',
            ),

            _metricCard(
              context,
              Icons.thermostat_rounded,
              'Body Temperature',
              healthData.bodyTemperature
                  .toStringAsFixed(1),
              '°C',
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // AI INSIGHTS
  // ============================================================

  Widget _buildAIInsights(
    BuildContext context,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _stressRow(
              context,
              Icons.thermostat,
              'Heat Stress',
              healthData.heatStress,
            ),

            const Divider(height: 24),

            _stressRow(
              context,
              Icons.eco_outlined,
              'Environmental Stress',
              healthData.environmentStress,
            ),

            const Divider(height: 24),

            _stressRow(
              context,
              Icons.directions_run,
              'Activity Stress',
              healthData.activityStress,
            ),

            const Divider(height: 24),

            _stressRow(
              context,
              Icons.accessibility_new,
              'Fatigue',
              healthData.fatigueIndex,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION
  // ============================================================

  Widget _buildInformationCard(
    BuildContext context,
  ) {
    return Card(
      elevation: 0,

      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Icon(
              Icons.info_outline,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Text(
                'This AI analysis is based on the measurements '
                'collected during the current session. It is intended '
                'to support workplace health monitoring and does not '
                'replace professional medical advice.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // METRIC CARD
  // ============================================================

  Widget _metricCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    String unit,
  ) {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 25,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 7),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 3),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.baseline,

              textBaseline:
                  TextBaseline.alphabetic,

              children: [

                Flexible(
                  child: Text(
                    value,
                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STRESS ROW
  // ============================================================

  Widget _stressRow(
    BuildContext context,
    IconData icon,
    String title,
    double value,
  ) {
    final normalized =
        _normalizeStress(value);

    final percentage =
        normalized * 100;

    final color =
        _stressColor(
          context,
          value,
        );

    return Column(
      children: [

        Row(
          children: [

            Icon(
              icon,
              size: 25,
              color: color,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              _stressDescription(value),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Row(
          children: [

            Expanded(
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 7,
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              width: 45,

              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                textAlign: TextAlign.right,

                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),

      child: Row(
        children: [

          Icon(
            icon,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,

              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
