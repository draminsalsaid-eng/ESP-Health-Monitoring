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


}
