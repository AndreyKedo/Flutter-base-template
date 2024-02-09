import 'package:logging/logging.dart';

import 'platform/vm.dart' if (dart.library.html) 'platform/js.dart';

export 'platform/vm.dart' if (dart.library.html) 'platform/js.dart';

Logger get logger => Runner().log;
