import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/esp_status.dart';
import '../models/health_response.dart';
import '../models/user_input.dart';

import 'api_constants.dart';
import 'network_exception.dart';

class ESPService {
// =========================================
// CHECK ESP32 CONNECTION
// =========================================

Future<bool> checkConnection() async {
try {
final response = await http
.get(
Uri.parse(
ApiConstants.baseUrl + ApiConstants.health,
),
)
.timeout(
ApiConstants.connectionTimeout,
);

```
  return response.statusCode == 200;
} catch (_) {
  return false;
}
```

}

// =========================================
// SEND USER / WORKER INPUT TO ESP32
//
// NOTE:
// user_id is intentionally NOT sent to ESP32.
// It remains inside Flutter.
// =========================================

Future<void> sendUserInput(
UserInput input,
) async {
try {
final response = await http
.post(
Uri.parse(
ApiConstants.baseUrl + '/start',
),
headers: {
'Content-Type': 'application/json',
},
body: jsonEncode(
{
'worker_type': input.workerType,
'activity': input.activity,
'environment': input.environment,
},
),
)
.timeout(
ApiConstants.connectionTimeout,
);

```
  if (response.statusCode != 200) {
    throw NetworkException(
      'ESP32 rejected worker information '
      '(${response.statusCode})',
    );
  }
} on http.ClientException {
  throw const NetworkException(
    'ESP32 WiFi connection failed',
  );
} on NetworkException {
  rethrow;
} catch (_) {
  throw const NetworkException(
    'Cannot send worker information',
  );
}
```

}

// =========================================
// READ RAW JSON FROM ESP32
// =========================================

Future<Map<String, dynamic>> _readJson() async {
try {
final response = await http
.get(
Uri.parse(
ApiConstants.baseUrl + ApiConstants.health,
),
)
.timeout(
ApiConstants.receiveTimeout,
);

```
  if (response.statusCode != 200) {
    throw NetworkException(
      'ESP32 Error ${response.statusCode}',
    );
  }

  dynamic decoded;

  try {
    decoded = jsonDecode(response.body);
  } catch (_) {
    throw const NetworkException(
      'Invalid JSON from ESP32',
    );
  }

  if (decoded is! Map) {
    throw const NetworkException(
      'ESP32 returned invalid data',
    );
  }

  return Map<String, dynamic>.from(decoded);
} on http.ClientException {
  throw const NetworkException(
    'ESP32 disconnected',
  );
} on NetworkException {
  rethrow;
} catch (_) {
  throw const NetworkException(
    'Cannot read ESP32 data',
  );
}
```

}

// =========================================
// READ ESP32 STATE
//
// Returns null when the JSON does not contain
// a "status" field.
//
// This is important because the final health
// JSON does not necessarily need a status field.
// =========================================

Future<ESPState?> readESPState() async {
final data = await _readJson();

```
if (!data.containsKey('status')) {
  return null;
}

return ESPState.fromJson(data);
```

}

// =========================================
// READ FINAL HEALTH RESULT
// =========================================

Future<HealthResponse> readHealthStatus() async {
final data = await _readJson();

```
// If ESP32 explicitly reports an error,
// do not try to parse it as health data.
final status = data['status']?.toString();

if (status == 'error') {
  throw NetworkException(
    data['message']?.toString() ??
        'ESP32 error',
  );
}

// A health result must contain at least
// one of the main measurement / AI fields.
final hasHealthData =
    data.containsKey('HR') ||
    data.containsKey('SpO2') ||
    data.containsKey('prediction') ||
    data.containsKey('risk_score');

if (!hasHealthData) {
  throw const NetworkException(
    'Health data is not ready',
  );
}

return HealthResponse.fromJson(data);
```

}

// =========================================
// READ COMPLETE JSON
//
// Useful later for debugging, logging,
// history, and testing.
// =========================================

Future<Map<String, dynamic>> readRawHealthJson() async {
return _readJson();
}

// =========================================
// OPTIONAL PING
// =========================================

Future<bool> pingESP() async {
try {
final response = await http
.get(
Uri.parse(
ApiConstants.baseUrl + ApiConstants.health,
),
)
.timeout(
const Duration(seconds: 5),
);

```
  return response.statusCode == 200;
} catch (_) {
  return false;
}
```

}
}
