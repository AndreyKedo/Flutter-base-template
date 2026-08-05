import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Ресурс приложения
extension type AssetValue(String path) implements String {
  Future<ByteData> loadFromRoot() {
    return rootBundle.load(path);
  }
}

/// Растровый ресурс
extension type ImageAssetValue(String path) implements AssetValue {
  static final _assetMemoizer = <String, AssetImage>{};

  AssetImage get provider => _assetMemoizer[path] ??= AssetImage(path);
}

extension type AppResource._(AssetValue _value) implements AssetValue {}

/// Растровые иконки
extension type AppIcons._(ImageAssetValue _value) implements ImageAssetValue {}

/// Растровые изображения
extension type AppImages._(ImageAssetValue _value) implements ImageAssetValue {
  static final logotype = AppImages._(ImageAssetValue('assets/logo/logo.png'));

  static final imagePlaceholder = AppImages._(ImageAssetValue('assets/img/image_placeholder.png'));
}
