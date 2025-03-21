import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_template/src/common/localization/localization.dart';

final class ErrorApplicationWidget extends StatelessWidget {
  const ErrorApplicationWidget({required this.error, required this.stackTrace, super.key});

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Fatal initialization exception'),
          ),
          body: Column(
            children: [
              MaterialBanner(
                content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'A fatal error occurred while initializing the application, '
                    'which prevents further operation. '
                    'Please copy the error data and pass it on to the developers.',
                  ),
                ),
                actions: [
                  Builder(
                    builder: (context) {
                      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
                      return OutlinedButton(
                        child: const Text('Copy data'),
                        onPressed: () {
                          final buffer = StringBuffer();
                          buffer
                            ..writeln(error)
                            ..writeln()
                            ..writeln(stackTrace);

                          Clipboard.setData(ClipboardData(text: buffer.toString())).whenComplete(() {
                            scaffoldMessenger?.clearSnackBars();
                            scaffoldMessenger?.showSnackBar(
                              SnackBar(
                                content: const Text('Copied to clipboard. Thanks!'),
                                showCloseIcon: false,
                              ),
                            );
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 16),
                              child: Text(
                                'Exception',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Flexible(child: SelectableText(error.toString())),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: SelectableText(stackTrace.toString()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
