import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/main.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ThemeMode _currentMode = themeModeNotifier.value;

  Future<void> _changeMode(ThemeMode newMode) async {
    if (newMode == _currentMode) return;
    setState(() => _currentMode = newMode);
    themeModeNotifier.value = newMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', newMode.name);
  }

  Future loadURL(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "设置",
            style: FluentTheme.of(context).typography.title,
          ),
        ),
      ),
      children: [
        const SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.only(left: 20),
                child: const Text(
                  '主题模式',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                children: [
                  RadioButton(
                    content: const Text('跟随系统'),
                    checked: _currentMode == ThemeMode.system,
                    onChanged: (_) => _changeMode(ThemeMode.system),
                  ),
                  const SizedBox(height: 10),
                  RadioButton(
                    content: const Text('浅色模式'),
                    checked: _currentMode == ThemeMode.light,
                    onChanged: (_) => _changeMode(ThemeMode.light),
                  ),
                  const SizedBox(height: 10),
                  RadioButton(
                    content: const Text('深色模式'),
                    checked: _currentMode == ThemeMode.dark,
                    onChanged: (_) => _changeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.only(left: 20),
              child: const Text("关于此应用",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.only(left: 20),
              child:
                  const Text("Unchained 1.2.1", style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 25),
            Row(children: [
              Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: HyperlinkButton(
                      onPressed: () {
                        loadURL('https://github.com/rapiz1/rathole');
                      },
                      child: const Text("Rathole"))),
              Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: HyperlinkButton(
                      onPressed: () {
                        loadURL('https://github.com/ClaretWheel1481/Unchained');
                      },
                      child: const Text("Unchained"))),
            ]),
          ],
        ),
      ],
    );
  }
}
