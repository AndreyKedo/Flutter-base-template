import 'package:flutter/material.dart';
import 'package:starter_template/feature/development/screen/logs_screen.dart';

final class DevelopmentScreen extends StatelessWidget {
  const DevelopmentScreen({super.key});

  static const routeSettings = RouteSettings(name: 'development_screen');
  static void push(BuildContext context) {
    final page = MaterialPageRoute(settings: routeSettings, builder: (context) => const DevelopmentScreen());
    Navigator.of(context, rootNavigator: true).push(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Development')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.list_sharp),
            title: const Text('Logs'),
            onTap: () {
              LogsScreen.push(context);
            },
          ),
        ],
      ),
    );
  }
}
