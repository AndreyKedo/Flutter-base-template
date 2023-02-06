import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FlutterLogo(),
            Padding(padding: EdgeInsets.only(top: 16)),
            CircularProgressIndicator.adaptive()
          ],
        ),
      ),
    );
  }
}
