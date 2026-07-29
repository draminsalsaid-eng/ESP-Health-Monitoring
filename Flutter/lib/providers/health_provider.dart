import 'package:flutter/foundation.dart';

import '../models/api_state.dart';
import '../models/health_response.dart';

import '../services/esp_service.dart';


class HealthProvider extends ChangeNotifier {

  final ESPService _espService = ESPService();

  ApiState _state = ApiState.idle();

  ApiState get state => _state;


  HealthResponse? _healthData;

  HealthResponse? get healthData => _healthData;
  //===========================
  // Load Health Data
  //===========================
  Future<void> loadHealthData() async {

  _state = ApiState.loading(
    'Reading health data...',
  );

  notifyListeners();


  try {

    final data = await _espService.getHealthData();

    _healthData = data;


    _state = ApiState.success(
      'Health data received',
    );


  } catch (e) {

    _state = ApiState.error(
      e.toString(),
    );

  }


  notifyListeners();
}

}
