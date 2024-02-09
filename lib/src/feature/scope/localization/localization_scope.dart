import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:starter_template/src/common/localization/localization.dart';
import 'package:starter_template/src/common/logic/settings/settings_controller.dart';
import 'package:starter_template/src/common/widget/scope.dart';
import 'package:starter_template/src/feature/app/runner/runner.dart';

abstract class ILocalizationController {
  Locale? get locale;
  void changeLocale(Locale value);
}

/// {@template localization_scope}
/// LocalizationScope widget
/// {@endtemplate}
final class LocalizationScope extends Scope {
  static const DelegateAccess<_LocalizationScopeDelegate> _delegateOf =
      Scope.delegateOf<LocalizationScope, _LocalizationScopeDelegate>;

  /// {@macro localization_scope}
  const LocalizationScope({
    required super.child,
    required this.settings,
    super.key,
  });

  final SettingsController settings;

  static ILocalizationController of(BuildContext context, {bool listen = true}) => _delegateOf(context, listen: listen);

  @override
  ScopeDelegate<LocalizationScope> createDelegate() => _LocalizationScopeDelegate();
}

final class _LocalizationScopeDelegate = ScopeDelegate<LocalizationScope>
    with _LocalizationScopeInit, _LocalizationController;

base mixin _LocalizationController on _LocalizationScopeInit implements ILocalizationController {
  @override
  List<Object?> get keys => [_settings.locale];

  @override
  Locale? get locale => _settings.locale;

  @override
  void changeLocale(Locale value) {
    if (AppLocalizations.supportedLocales.contains(value)) {
      _settings.changeLocale(value);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) => super.debugFillProperties(
        properties
          ..add(
            StringProperty(
              'Current locale',
              _settings.locale.toString(),
            ),
          ),
      );
}

base mixin _LocalizationScopeInit on ScopeDelegate<LocalizationScope> {
  late SettingsController _settings;

  /* #region Lifecycle */
  @override
  void initState() {
    _settings = widget.settings;
    _settings.addListener(_changeScopeData);
    super.initState();
  }

  @override
  void dispose() {
    _settings.removeListener(_changeScopeData);
    super.dispose();
  }
  /* #endregion */

  void _changeScopeData() {
    setState(() {
      Runner().log.info('Change locale ${_settings.locale}');
    });
  }
}
