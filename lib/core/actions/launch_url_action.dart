import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// {@template launch_url_action.intent}
/// Намерение запустить ссылку.
///
/// - [url] - ссылка на ресурс.
/// - [LaunchMode] - тип запуска.
/// {@endtemplate}
class LaunchUrlIntent extends Intent {
  /// {@macro launch_url_action.intent}
  const LaunchUrlIntent(this.url) : mode = LaunchMode.platformDefault;

  /// {@macro launch_url_action.intent}
  ///
  /// Намерение которое уведомляет систему о том, что ссылка должны быть обработана
  /// с помощью внешнего приложения.
  const LaunchUrlIntent.externalMode(this.url) : mode = LaunchMode.externalApplication;

  final Uri url;

  final LaunchMode mode;
}

/// Действие ассоциирующиеся с [LaunchUrlIntent].
class LaunchUrlAction extends Action<LaunchUrlIntent> {
  @override
  Future<bool> invoke(LaunchUrlIntent intent) async {
    final result = await launchUrl(intent.url, mode: intent.mode);
    return result;
  }
}
