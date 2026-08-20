import 'package:flutter/services.dart';

const kChannelName = 'ru.example.application';

class const AppPlatformMethodChannel(String name) extends MethodChannel {
  this : super('$kChannelName/$name/method');
}

class const AppPlatformEventChannel(String name) extends EventChannel {
  this : super('$kChannelName/$name');
}
