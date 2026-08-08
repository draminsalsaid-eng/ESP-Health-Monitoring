import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/api_state.dart';
import '../models/esp_status.dart';
import '../models/health_response.dart';
import '../models/user_input.dart';

import '../services/esp_service.dart';
import '../services/network_exception.dart';

class HealthProvider extends ChangeNotifier {
final ESPService _espService = ESPService();

Timer? _monitorTimer;

// =========================================
// API / MONITORING STATE
// =========================================

ApiState _state = ApiState.idle();

ApiState get state => _state;

// =========================================
// ESP32 STATE
// =========================================

ESPState _espState = const ESPState(
status: ESPStatus.idle,
message: 'Ready',
);

ESPState get espState => _espState;

// =========================================
// FINAL HEALTH DATA
// =========================================

HealthResponse? _healthData;

HealthResponse? get healthData => _healthData;

// =========================================
// CURRENT USER INPUT
//
// User ID remains inside Flutter.
// =========================================

UserInput? _currentInput;

UserInput? get currentInput => _currentInput;

// =========================================
// START MONITORING
// =========================================

Future<void> startMonitoring(
UserInput userInput,
) async {
try {
stopMonitoring();

```
  _healthData = null;
  _currentInput = userInput;

  // ---------------------------------------
  // STEP 1 - CONNECTING
  // ---------------------------------------

  _setApiState(
    ApiState.connecting(),
  );

  _setESPState(
    const ESPState(
      status: ESPStatus.idle,
      message: 'Connecting to ESP32...',
    ),
  );

  final connected =
      await _espService.checkConnection();

  if (!connected) {
    _setError(
      'ESP32 disconnected',
    );
    return;
  }

  // ---------------------------------------
  // STEP 2 - SEND WORKER INFORMATION
  // ---------------------------------------

  _setApiState(
    ApiState.waitingSensor(),
  );

  await _espService.sendUserInput(
    userInput,
  );

  // ---------------------------------------
  // STEP 3 - WAIT FOR MEASUREMENT
  // ---------------------------------------

  _setESPState(
    const ESPState(
      status: ESPStatus.waitingFinger,
      message: 'Place your finger on MAX30105',
    ),
  );

  _setApiState(
    ApiState.waitingSensor(),
  );

  // ---------------------------------------
  // STEP 4 - START POLLING
  // ---------------------------------------

  _startMonitoringLoop();
} on NetworkException catch (e) {
  _setError(e.message);
} catch (_) {
  _setError(
    'Unexpected monitoring error',
  );
}
```

}

// =========================================
// MONITORING LOOP
// =========================================

void _startMonitoringLoop() {
_monitorTimer?.cancel();

```
// Read immediately instead of waiting
// for the first one-second interval.
_readESPStatus();

_monitorTimer = Timer.periodic(
  const Duration(seconds: 1),
  (_) {
    _readESPStatus();
  },
);
```

}

// =========================================
// READ ESP32 STATUS / HEALTH
// =========================================

Future<void> _readESPStatus() async {
try {
// ---------------------------------------
// First try to read ESP32 state.
// ---------------------------------------

```
  final espState =
      await _espService.readESPState();

  if (espState != null) {
    _setESPState(espState);

    switch (espState.status) {
      case ESPStatus.idle:
        _setApiState(
          ApiState.idle(),
        );
        break;

      case ESPStatus.waitingFinger:
        _setApiState(
          ApiState.waitingSensor(),
        );
        break;

      case ESPStatus.measuring:
        _setApiState(
          ApiState.readingData(),
        );
        break;

      case ESPStatus.processingAI:
        _setApiState(
          ApiState.processingAI(),
        );
        break;

      case ESPStatus.completed:
        await _readFinalHealthData();
        break;

      case ESPStatus.error:
        _setError(
          espState.message,
        );
        break;
    }

    return;
  }

  // ---------------------------------------
  // No status field:
  // try to detect final health JSON.
  // ---------------------------------------

  await _readFinalHealthData();
} on NetworkException catch (e) {
  // During measurement the ESP32 may temporarily
  // not have the final data ready.
  //
  // We do not immediately destroy the workflow
  // for a temporary "not ready" response.

  if (e.message == 'Health data is not ready') {
    return;
  }

  _setError(e.message);
} catch (_) {
  _setError(
    'Cannot read ESP32 status',
  );
}
```

}

// =========================================
// READ FINAL HEALTH DATA
// =========================================

Future<void> _readFinalHealthData() async {
try {
_setApiState(
ApiState.processingAI(),
);

```
  final result =
      await _espService.readHealthStatus();

  _healthData = result;

  _setESPState(
    const ESPState(
      status: ESPStatus.completed,
      message: 'Health analysis completed',
    ),
  );

  _setApiState(
    ApiState.success(
      'Health analysis completed',
    ),
  );

  stopMonitoring();
} on NetworkException catch (e) {
  if (e.message == 'Health data is not ready') {
    return;
  }

  _setError(e.message);
}
```

}

// =========================================
// GET LATEST HEALTH DATA
//
// Used by Dashboard / Refresh.
// =========================================

Future<void> getLatestHealthData() async {
try {
_setApiState(
ApiState.readingData(),
);

```
  final result =
      await _espService.readHealthStatus();

  _healthData = result;

  _setApiState(
    ApiState.success(
      'Data updated',
    ),
  );
} on NetworkException catch (e) {
  _setError(e.message);
}
```

}

// =========================================
// INTERNAL STATE HELPERS
// =========================================

void _setApiState(ApiState state) {
_state = state;
notifyListeners();
}

void _setESPState(ESPState state) {
_espState = state;
notifyListeners();
}

void _setError(String message) {
_state = ApiState.error(message);

```
_espState = ESPState(
  status: ESPStatus.error,
  message: message,
);

stopMonitoring();

notifyListeners();
```

}

// =========================================
// STOP MONITORING
// =========================================

void stopMonitoring() {
_monitorTimer?.cancel();
_monitorTimer = null;
}

// =========================================
// DISPOSE
// =========================================

@override
void dispose() {
stopMonitoring();
super.dispose();
}
}
