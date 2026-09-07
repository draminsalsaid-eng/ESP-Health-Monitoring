import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'ai_health_analysis_screen.dart';
import '../models/health_response.dart';

Future<void> fetchHealthData(BuildContext context) async {
  // Show a non-blocking loading indicator or state
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    // Set a timeout so the UI never freezes indefinitely
    final response = await http.get(
      Uri.parse('http://<ESP32_IP_ADDRESS>/health-data'),
    ).timeout(const Duration(seconds: 5));

    // Pop the loading dialog
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      // Parse data and navigate to your screen
      final healthData = HealthResponse.fromJson(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AIHealthAnalysisScreen(healthData: healthData),
        ),
      );
    } else {
      _showErrorSnackBar(context, 'Failed connection to API (Server Error)');
    }
  } on TimeoutException {
    Navigator.of(context).pop(); // Pop loader
    _showErrorSnackBar(context, 'Failed connection to API (Timeout)');
  } on SocketException {
    Navigator.of(context).pop(); // Pop loader
    _showErrorSnackBar(context, 'Failed connection to API (Network Unreachable)');
  } catch (e) {
    Navigator.of(context).pop(); // Pop loader
    _showErrorSnackBar(context, 'Failed connection to API: $e');
  }
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    ),
  );
}
