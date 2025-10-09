import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:starter_template/core/logger.dart';

final class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  static void push(BuildContext context) {
    final page = MaterialPageRoute(builder: (context) => const LogsScreen());
    Navigator.of(context).push(page);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: ListenableBuilder(
        listenable: AppLogger.collector,
        builder: (context, child) {
          final list = AppLogger.collector.value;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              if (item.error != null) {
                return ListTile(
                  isThreeLine: true,
                  leading: Icon(Icons.error_outline_outlined, color: colorScheme.error),
                  title: Text(_errorStringify(item.error!)),
                  subtitle: Text(item.message),
                );
              }

              return ListTile(
                isThreeLine: true,
                leading: Text(
                  item.level.name,
                  style: TextStyle(
                    color: switch (item.level) {
                      Level.WARNING => Colors.orange,
                      Level.INFO => Colors.lightBlue,
                      _ => null,
                    },
                  ),
                ),
                title: Text(switch (item.loggerName) {
                  final name when name.isEmpty => 'AppLogger',
                  final name => name,
                }),
                subtitle: Text(item.message),
              );
            },
          );
        },
      ),
    );
  }
}

String _errorStringify(Object error) {
  if (error case final Exception exception) {
    return exception.toString();
  }
  if (error case final Error err) {
    return err.toString();
  }

  return describeIdentity(error);
}
