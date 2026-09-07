import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_response.dart';
import '../providers/health_provider.dart';
// استبدل السطر التالي بمسار ملف شاشة إعدادات العامل لديك (Setup Measurement Screen)
import '../screens/setup_measurement_screen.dart'; 

class AIHealthAnalysisScreen extends StatefulWidget {
  final HealthResponse healthData;

  const AIHealthAnalysisScreen({
    super.key,
    required this.healthData,
  });

  @override
  State<AIHealthAnalysisScreen> createState() => _AIHealthAnalysisScreenState();
}

class _AIHealthAnalysisScreenState extends State<AIHealthAnalysisScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  late HealthResponse _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.healthData;
    // يمكنك استدعاء دالة جلب التحليل من الـ Provider هنا إن وجدت
    // _fetchAIAnalysis();
  }

  Future<void> _fetchAIAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // محاكاة جلب البيانات أو الاتصال بالـ API
      // await Provider.of<HealthProvider>(context, listen: false).getAIAnalysis();
      
      // محاكاة خطأ الاتصال للاختبار عند الحاجة:
      // throw Exception("Connection failed");

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection failed between ESP32 and API";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Health Analysis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : _buildAnalysisContent(context),
    );
  }

  // ============================================================
  // ERROR VIEW (Connection Failed)
  // ============================================================
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.signal_wifi_connected_no_internet_4_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? "Connection failed between ESP32 and API",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAIAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ANALYSIS CONTENT & SETUP MEASUREMENT BUTTON
  // ============================================================
  Widget _buildAnalysisContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقة ملخص حالة الأمان
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System AI Evaluation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 20),
                Text(
                  'Alert Status: ${_currentData.alertLevel.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _currentData.alertLevel.toLowerCase() == 'green'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Risk Level: ${_currentData.riskLevel.toUpperCase()}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // التوصيات
        const Text(
          'Recommendations:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Ensure proper ventilation in the working environment.\n'
          '• Monitor heart rate closely during high activity.\n'
          '• Check gas sensor calibrations if readings fluctuate abnormally.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 40),

        // ============================================================
        // زر العودة إلى صفحة إعدادات العامل / بدء القياس مرة أخرى
        // ============================================================
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // هذا الأمر يمسح كافة الشاشات السابقة وينتقل مباشرة إلى شاشة الإعدادات وبدء القياس
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetupMeasurementScreen(), // تأكد من مطابقة اسم شاشة الإعدادات لديك
                ),
                (route) => false, // حذف جميع التراكمات السابقة في الـ Stack
              );
            },
            icon: const Icon(Icons.restart_alt),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Back to Setup Measurement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
