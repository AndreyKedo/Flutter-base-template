import 'package:flutter/foundation.dart' show immutable;

@immutable
class MobileOptions {
  const MobileOptions();
}

@immutable
class WebOptions {
  const WebOptions();
}

@immutable
class RunnerConfig {
  final MobileOptions mobile;
  final WebOptions web;

  const RunnerConfig({this.mobile = const MobileOptions(), this.web = const WebOptions()});
}
