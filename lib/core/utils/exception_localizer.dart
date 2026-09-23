import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:starter_template/core/build_context_ext.dart';
import 'package:starter_template/core/entity/localizable_exception.dart';
import 'package:starter_template/core/environment.dart';
import 'package:starter_template/core/network/rest_api.dart';

typedef ExceptionFallbackLocalizer = String? Function(Object exception);

abstract interface class ExceptionVisitor {
  String visit(Object exception);
}

class ExceptionLocalizer(final BuildContext _c, {final ExceptionFallbackLocalizer? fallbackLocalizer})
    implements ExceptionVisitor {
  String localize(Object exception) {
    if (exception is LocalizableException) {
      return exception.localize(this);
    }

    if (exception is GeneralExceptionWrapper) {
      return exception.localize(this);
    }

    return GeneralExceptionWrapper(exception).localize(this);
  }

  @override
  String visit(Object exception) {
    final localizations = _c.lcl;

    switch (exception) {
      case ServerException():
        return localizations.serverError;
      case ApiException(:final statusCode):
        if (statusCode == HttpStatus.unauthorized) {
          return localizations.authenticationError;
        }
        return localizations.apiError(statusCode);
      case SocketConnectionException():
        return localizations.socketConnectionError;
      case SocketTlsException():
        return localizations.unknownError;
      case ConnectionTimeoutException():
        return localizations.timeoutError;
      case TimeoutException():
        return localizations.timeoutError;
      case FormatException() || ArgumentError() || TypeError():
        return localizations.validationError;
      case IOException():
        if (Flavor.current == .staging) {
          return '${localizations.socketError}(${exception.toString()})';
        }
        return localizations.socketError;
      case StateError(:final message):
        if (Flavor.current == .staging) {
          return message;
        }
        return localizations.stateError;
      default:
        return fallbackLocalizer?.call(exception) ?? localizations.unknownError;
    }
  }
}

mixin LocalizableExceptionMixin {
  Object get exception;

  String localize(BuildContext context, {ExceptionFallbackLocalizer? fallbackLocalizer}) =>
      ExceptionLocalizer(context, fallbackLocalizer: fallbackLocalizer).localize(exception);
}
