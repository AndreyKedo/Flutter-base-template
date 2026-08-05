import 'package:starter_template/core/utils/exception_localizer.dart';

mixin class LocalizableException {
  String localize(ExceptionVisitor visitor) => visitor.visit(this);
}

extension type GeneralExceptionWrapper(Object object) implements Object {
  String localize(ExceptionVisitor visitor) => visitor.visit(this);
}
