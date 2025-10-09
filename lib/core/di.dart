import 'package:flutter/foundation.dart';

typedef InstanceFactoryCallback<T, C extends DependencyContainer> = T Function(DependencyContainer container);

typedef FactoryCallback<T> = T Function();

abstract class DependencyContainer {
  const DependencyContainer();

  static T platform<T>({required FactoryCallback<T> android, required FactoryCallback<T> ios}) =>
      switch (defaultTargetPlatform) {
        TargetPlatform.android => android(),
        TargetPlatform.iOS => ios(),
        final value => throw UnsupportedError('Platform ${value.name} is not supported'),
      };

  void dispose() {}
}
