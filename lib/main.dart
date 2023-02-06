import 'src/feature/mobile/runner.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'src/feature/web/runner.dart';

void main() => Runner().run();
