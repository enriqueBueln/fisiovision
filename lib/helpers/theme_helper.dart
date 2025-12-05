import 'package:flutter/material.dart';

Color adaptiveBackgroundColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Theme.of(context).colorScheme.surface : Colors.white;
}
