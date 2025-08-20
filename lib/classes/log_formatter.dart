import 'package:flutter/material.dart';

class LogFormatter {
  static String formatLine(String raw) {
    final timeRegex = RegExp(r'^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z)');
    final levelRegex = RegExp(r'^(INFO|WARN|ERROR)\b');
    String timePart = '', levelPart = '';
    var rest = raw;
    final tMatch = timeRegex.firstMatch(raw);
    if (tMatch != null) {
      timePart = DateTime.parse(
        tMatch.group(1)!,
      ).toLocal().toIso8601String().replaceFirst('T', ' ').split('.').first;
      rest = raw.substring(tMatch.group(0)!.length).trimLeft();
    }
    final lMatch = levelRegex.firstMatch(rest);
    if (lMatch != null) {
      levelPart = lMatch.group(1)!;
      rest = rest.substring(levelPart.length).trimLeft();
    }
    return '$timePart|$levelPart|$rest';
  }

  static Color formatLevel(String level) {
    switch (level) {
      case 'WARN':
        return Colors.red;
      case 'ERROR':
        return Colors.red;
      case 'INFO':
      default:
        return Colors.green;
    }
  }
}
