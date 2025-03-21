import 'platform/vm.dart' if (dart.library.js_interop) 'platform/js.dart';

/// Runner Singleton class
void run() => RunnerImpl().initializeAndRun();
