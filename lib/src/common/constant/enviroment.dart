import 'package:flutter/foundation.dart' show kDebugMode;

const String kFlavor = String.fromEnvironment('FLAVOR', defaultValue: kDebugMode ? 'develop' : 'production');

const kDebug = kDebugMode;
