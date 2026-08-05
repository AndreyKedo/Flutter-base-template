import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ClipboardIntent extends Intent {
  const ClipboardIntent(this.data);

  final String data;
}

class ClipBoardAction extends Action<ClipboardIntent> {
  @override
  Future<void> invoke(ClipboardIntent intent) async {
    await Clipboard.setData(.new(text: intent.data));
  }
}
