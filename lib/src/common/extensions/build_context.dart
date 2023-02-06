import 'package:flutter/widgets.dart' show BuildContext, Locale, Localizations;
import 'package:starter_template/src/common/localization/localization.dart';

import 'package:starter_template/src/common/model/dependency_storage.dart';
import 'package:starter_template/src/common/widget/dependency_scope.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get localized {
    final delegate = AppLocalizations.of(this);
    assert(delegate != null, 'Do not have AppLocalizations into elements tree');
    return delegate!;
  }

  Locale get locale => Localizations.localeOf(this);

  Storage dependency<Storage extends IDependenciesStorage>() => DependenciesScope.of<Storage>(this);
  Storage dependencyWatch<Storage extends IDependenciesStorage>() => DependenciesScope.of<Storage>(this, listen: true);
}
