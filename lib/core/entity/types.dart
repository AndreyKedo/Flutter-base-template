import 'package:flutter/foundation.dart';

typedef ControllerCreateCallback<T extends Listenable> = T Function();

typedef OnHandleErrorCallback = void Function(Object exception, StackTrace stackTrace);
