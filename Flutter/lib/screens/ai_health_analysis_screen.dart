import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';

class AIHealthAnalysisScreen extends StatelessWidget {
  const AIHealthAnalysisScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final health =
        Provider.of<HealthProvider>(context);

    final data = health.healthData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Health Analysis',
        ),
        centerTitle: true,
      ),

      body: data == null
          ? const Center(
              child: Text(
                'No health analysis available',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await health.getLatestHealthData();
              },

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(16),

                children: [
                  // =====================================================
                  // HEADER
                  // =====================================================

                  _buildHeader(),

                  const SizedBox(height: 20),

                  // =====================================================
                  // OVERALL AI RESULT
                  // =====================================================

                  _buildOverallResult(
                    context,
                    data,
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // RISK SCORE
                  // =====================================================

                  _buildSectionTitle(
                    'Overall Risk Assessment',
                    Icons.analytics,
                    Colors.deepPurple,
                  ),

                  _buildRiskScoreCard(
                    data,
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // PHYSIOLOGICAL STRESS
                  // =====================================================

                  _buildSectionTitle(
                    'Physiological Stress',
                    Icons.monitor_heart,
                    Colors.red,
                  ),

                  _buildAnalysisCard(
                    title: 'Cardiac Stress',
                    value:
                        data.cardiacStress,
                    icon:
                        Icons.favorite,
                    color:
                        Colors.red,
                    description:
                        'Indicates the level of cardiovascular '
                        'stress detected from the available '
                        'physiological measurements.',
                  ),

                  _buildAnalysisCard(
                    title: 'Oxygen Risk',
                    value:
                        data.oxygenRisk,
                    icon:
                        Icons.air,
                    color:
                        Colors.blue,
                    description:
                        'Represents the contribution of blood '
                        'oxygen measurements to the overall '
                        'health risk assessment.',
                  ),

                  _buildAnalysisCard(
                    title: 'Fatigue Index',
                    value:
                        data.fatigueIndex,
                    icon:
                        Icons.battery_alert,
                    color:
                        Colors.orange,
                    description:
                        'AI-derived indicator associated with '
                        'possible fatigue based on the collected '
                        'physiological and activity data.',
                  ),

                  const SizedBox(height: 10),

                  // =====================================================
                  // HEAT / TEMPERATURE
                  // =====================================================

                  _buildSectionTitle(
                    'Heat & Temperature Analysis',
                    Icons.thermostat,
                    Colors.deepOrange,
                  ),

                  _buildAnalysisCard(
                    title: 'Heat Stress',
                    value:
                        data.heatStress,
                    icon:
                        Icons.wb_sunny,
                    color:
                        Colors.deepOrange,
                    description:
                        'Represents the contribution of ambient '
                        'temperature, humidity and body temperature '
                        'to the overall heat-related risk.',
                  ),

                  _buildAnalysisCard(
                    title: 'Body Temperature Effect',
                    value:
                        data.bodyTempEffect,
                    icon:
                        Icons.device_thermostat,
                    color:
                        Colors.orange,
                    description:
                        'Shows how the measured body temperature '
                        'contributes to the AI health assessment.',
                  ),

                  const SizedBox(height: 10),

                  // =====================================================
                  // ENVIRONMENT
                  // =====================================================

                  _buildSectionTitle(
                    'Environmental Analysis',
                    Icons.public,
                    Colors.teal,
                  ),

                  _buildAnalysisCard(
                    title: 'Environmental Stress',
                    value:
                        data.environmentalStress,
                    icon:
                        Icons.cloud,
                    color:
                        Colors.teal,
                    description:
                        'Represents the contribution of the '
                        'surrounding environmental conditions '
                        'to the overall health risk.',
                  ),

                  _buildAnalysisCard(
                    title: 'Activity Stress',
                    value:
                        data.activityStress,
                    icon:
                        Icons.directions_run,
                    color:
                        Colors.indigo,
                    description:
                        'Represents the contribution of the '
                        'reported worker activity to the AI '
                        'assessment.',
                  ),

                  const SizedBox(height: 10),

                  // =====================================================
                  // MOTION ANALYSIS
                  // =====================================================

                  _buildSectionTitle(
                    'Motion Analysis',
                    Icons.accessibility_new,
                    Colors.green,
                  ),

                  _buildAnalysisCard(
                    title: 'Motion Index',
                    value:
                        data.motionIndex,
                    icon:
                        Icons.speed,
                    color:
                        Colors.green,
                    description:
                        'Represents the level of movement detected '
                        'from the accelerometer and gyroscope data.',
                  ),

                  _buildAnalysisCard(
                    title: 'Motion Stress',
                    value:
                        data.motionStress,
                    icon:
                        Icons.directions_walk,
                    color:
                        Colors.lightGreen.shade700,
                    description:
                        'Shows how detected movement contributes '
                        'to the AI health assessment.',
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // HOW TO READ THE ANALYSIS
                  // =====================================================

                  _buildSectionTitle(
                    'How to Read This Analysis',
                    Icons.info_outline,
                    Colors.blueGrey,
                  ),

                  _buildInformationCard(),

                  const SizedBox(height: 20),

                  // =====================================================
                  // DISCLAIMER
                  // =====================================================

                  _buildDisclaimer(),

                  const SizedBox(height: 25),
                ],
              ),
            ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),

        gradient: LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,

          colors: [
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade700,
          ],
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.psychology,
            size: 52,
            color: Colors.white,
          ),

          const SizedBox(height: 10),

          const Text(
            'AI Health Analysis',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Detailed analysis of the latest health '
            'and environmental measurements',
            textAlign: TextAlign.center,

            style: TextStyle(
              color:
                  Colors.white.withOpacity(
                0.9,
              ),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // OVERALL RESULT
  // ================================================================

  Widget _buildOverallResult(
    BuildContext context,
    dynamic data,
  ) {
    final alert =
        data.alertLevel.toString();

    final risk =
        data.riskLevel.toString();

    final alertColor =
        _alertColor(alert);

    final riskColor =
        _riskColor(risk);

    return Card(
      elevation: 4,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          children: [
            const Text(
              'Overall AI Assessment',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child:
                      _resultBox(
                    title:
                        'Safety Status',
                    value:
                        _formatAlert(
                          alert,
                        ),
                    icon:
                        _alertIcon(
                          alert,
                        ),
                    color:
                        alertColor,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                      _resultBox(
                    title:
                        'Risk Level',
                    value:
                        _formatRisk(
                          risk,
                        ),
                    icon:
                        Icons.warning_amber_rounded,
                    color:
                        riskColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // RESULT BOX
  // ================================================================

  Widget _resultBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color:
            color.withOpacity(0.08),

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color:
              color.withOpacity(0.30),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 34,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,

            maxLines: 2,

            style: const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            textAlign: TextAlign.center,

            maxLines: 2,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // RISK SCORE
  // ================================================================

  Widget _buildRiskScoreCard(
    dynamic data,
  ) {
    final score =
        _toDouble(
      data.riskScore,
    );

    final normalized =
        (score / 100)
            .clamp(0.0, 1.0);

    return Card(
      elevation: 3,

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Icon(
                  Icons.speed,
                  color:
                      Colors.deepPurple,
                ),

                const SizedBox(
                  width: 10,
                ),

                const Expanded(
                  child: Text(
                    'AI Risk Score',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  score
                      .toStringAsFixed(1),

                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.deepPurple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              child:
                  LinearProgressIndicator(
                minHeight: 10,
                value: normalized,
                backgroundColor:
                    Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<
                        Color>(
                  _scoreColor(score),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'The AI risk score is used as part of the '
              'overall health risk assessment.',
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // ANALYSIS CARD
  // ================================================================

  Widget _buildAnalysisCard({
    required String title,
    required dynamic value,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    final number =
        _toDouble(value);

    return Card(
      elevation: 2,

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,

              children: [
                CircleAvatar(
                  radius: 22,

                  backgroundColor:
                      color.withOpacity(
                    0.12,
                  ),

                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    title,

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(
                  number
                      .toStringAsFixed(3),

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // INDICATOR
            // ==================================================

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                8,
              ),

              child:
                  LinearProgressIndicator(
                minHeight: 7,

                value:
                    number.clamp(
                  0.0,
                  1.0,
                ),

                backgroundColor:
                    Colors.grey.shade200,

                valueColor:
                    AlwaysStoppedAnimation<
                        Color>(
                  color,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              description,

              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 8,
        bottom: 10,
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 27,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              title,

              maxLines: 2,

              overflow:
                  TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // INFORMATION CARD
  // ================================================================

  Widget _buildInformationCard() {
    return Card(
      elevation: 2,

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _infoRow(
              Icons.circle,
              'Low',
              'Lower contribution to the overall risk.',
              Colors.green,
            ),

            const SizedBox(
              height: 12,
            ),

            _infoRow(
              Icons.circle,
              'Medium',
              'Moderate contribution that may require attention.',
              Colors.orange,
            ),

            const SizedBox(
              height: 12,
            ),

            _infoRow(
              Icons.circle,
              'High',
              'Higher contribution to the overall risk assessment.',
              Colors.red,
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              'These indicators are supporting AI analysis '
              'metrics. They should be interpreted together '
              'with the overall Safety Status and Risk Level.',
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // INFO ROW
  // ================================================================

  Widget _infoRow(
    IconData icon,
    String title,
    String text,
    Color color,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade700,
                height: 1.4,
              ),

              children: [
                TextSpan(
                  text: '$title: ',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                TextSpan(
                  text: text,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DISCLAIMER
  // ================================================================

  Widget _buildDisclaimer() {
    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color:
            Colors.amber.shade50,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color:
              Colors.amber.shade200,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            Icons.info_outline,
            color:
                Colors.amber.shade800,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              'AI analysis is intended to support worker '
              'health and safety monitoring. It should not '
              'be considered a medical diagnosis.',
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.amber.shade900,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DOUBLE CONVERSION
  // ================================================================

  double _toDouble(
    dynamic value,
  ) {
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

  // ================================================================
  // ALERT FORMAT
  // ================================================================

  String _formatAlert(
    String value,
  ) {
    switch (
        value.toLowerCase()) {
      case 'green':
        return 'SAFE';

      case 'yellow':
        return 'WARNING';

      case 'red':
        return 'DANGER';

      default:
        return value.isEmpty
            ? 'UNKNOWN'
            : value.toUpperCase();
    }
  }

  // ================================================================
  // RISK FORMAT
  // ================================================================

  String _formatRisk(
    String value,
  ) {
    switch (
        value.toLowerCase()) {
      case 'low':
        return 'LOW';

      case 'medium':
        return 'MEDIUM';

      case 'high':
        return 'HIGH';

      default:
        return value.isEmpty
            ? 'UNKNOWN'
            : value.toUpperCase();
    }
  }

  // ================================================================
  // ALERT COLOR
  // ================================================================

  Color _alertColor(
    String value,
  ) {
    switch (
        value.toLowerCase()) {
      case 'green':
        return Colors.green;

      case 'yellow':
        return Colors.orange;

      case 'red':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ================================================================
  // RISK COLOR
  // ================================================================

  Color _riskColor(
    String value,
  ) {
    switch (
        value.toLowerCase()) {
      case 'low':
        return Colors.green;

      case 'medium':
        return Colors.orange;

      case 'high':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ================================================================
  // ALERT ICON
  // ================================================================

  IconData _alertIcon(
    String value,
  ) {
    switch (
        value.toLowerCase()) {
      case 'green':
        return Icons.check_circle;

      case 'yellow':
        return Icons.warning_amber_rounded;

      case 'red':
        return Icons.dangerous;

      default:
        return Icons.help_outline;
    }
  }

  // ================================================================
  // SCORE COLOR
  // ================================================================

  Color _scoreColor(
    double score,
  ) {
    if (score < 35) {
      return Colors.green;
    }

    if (score < 65) {
      return Colors.orange;
    }

    return Colors.red;
  }
}
