import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/main.dart';

Future<void> initAccentColor() async {
  final prefs = await SharedPreferences.getInstance();

  final int stored =
      prefs.getInt('accent_color_value') ?? Colors.blue.toARGB32();
  accentColorNotifier = ValueNotifier(Color(stored));
}

Future<void> saveAccentColor(Color color) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('accent_color_value', color.toARGB32());
}
