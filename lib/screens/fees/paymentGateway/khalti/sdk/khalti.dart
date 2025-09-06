// Dart imports:

// Flutter imports:

// Project imports:
import 'package:infixedu/screens/fees/paymentGateway/khalti/core/src/config/khalti_config.dart';
import 'package:infixedu/screens/fees/paymentGateway/khalti/core/src/data/khalti_service.dart';
import 'package:infixedu/screens/fees/paymentGateway/khalti/sdk/src/khalti_http_client.dart';

class Khalti {
  static Future<void> init({
    required String publicKey,
    KhaltiConfig? config,
    bool enabledDebugging = false,
  }) async {
    KhaltiService.enableDebugging = enabledDebugging;
    KhaltiService.publicKey = publicKey;

    KhaltiService.config = config ?? KhaltiConfig.sourceOnly();
  }

  static KhaltiService get service => _service;
}

final KhaltiService _service = KhaltiService(client: KhaltiHttpClient());
