import 'package:flutter/material.dart';
import 'package:starter_template/core/logger.dart';
import 'package:starter_template/feature/application/widget/application.dart';

void main() {
  AppLogger.enableLogger();
  runApp(const Application());
}
