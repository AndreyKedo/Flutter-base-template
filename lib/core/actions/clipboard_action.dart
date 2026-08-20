import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class const ClipboardIntent(final String data) extends Intent;

class ClipBoardAction extends Action<ClipboardIntent> {
  @override
  Future<void> invoke(ClipboardIntent intent) async {
    await Clipboard.setData(.new(text: intent.data));
  }
}
