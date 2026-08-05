import 'package:flutter/services.dart';

const kChannelName = 'ru.example.application';

class AppPlatformMethodChannel extends MethodChannel {
  const AppPlatformMethodChannel(String name) : super('$kChannelName/$name/method');
}

class AppPlatformEventChannel extends EventChannel {
  const AppPlatformEventChannel(String name) : super('$kChannelName/$name');
}
