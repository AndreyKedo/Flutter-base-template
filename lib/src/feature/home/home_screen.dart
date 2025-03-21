import 'package:flutter/material.dart';
import 'package:starter_template/src/common/localization/localization.dart';

final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(context.localized.appTitle),
        ),
        body: Center(
          child: Text('Hello'),
        ),
      );
}
