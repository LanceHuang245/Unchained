import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/main.dart';
import 'package:unchained/pages/Settings/widgets/about.dart';
import 'package:unchained/pages/Settings/widgets/auto_update.dart';
import 'package:unchained/pages/Settings/widgets/check_update.dart';
import 'package:unchained/pages/Settings/widgets/proxy_settings.dart';
import 'package:unchained/pages/Settings/widgets/theme_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool autoUpdateChecked = true;
  ThemeMode _currentMode = themeModeNotifier.value;
  final TextEditingController proxyAddrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      autoUpdateChecked = prefs.getBool('auto_update_checked') ?? true;
    });
    final savedProxy = prefs.getString('proxy_addr') ?? '';
    proxyAddrController.text = savedProxy;
  }

  Future<void> _saveProxyAddress(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('proxy_addr', value);
  }

  Future<void> _saveAutoUpdateSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_update_checked', value);
  }

  Future<void> _changeMode(ThemeMode newMode) async {
    if (newMode == _currentMode) return;
    setState(() => _currentMode = newMode);
    themeModeNotifier.value = newMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', newMode.name);
  }

  void _onAutoUpdateChanged(bool value) {
    setState(() => autoUpdateChecked = value);
    _saveAutoUpdateSetting(value);
  }

  void _onProxyAddressChanged(String value) {
    _saveProxyAddress(value);
  }

  @override
  void dispose() {
    proxyAddrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: Padding(
        padding: const EdgeInsets.only(left: 31.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "设置",
            style: FluentTheme.of(context).typography.title,
          ),
        ),
      ),
      children: [
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            ThemeSettingsWidget(
              currentMode: _currentMode,
              onModeChanged: _changeMode,
            ),
            const SizedBox(height: 3),
            AutoUpdateWidget(
              checked: autoUpdateChecked,
              onChanged: _onAutoUpdateChanged,
            ),
            const SizedBox(height: 3),
            const CheckUpdateWidget(),
            const SizedBox(height: 3),
            ProxySettingsWidget(
              controller: proxyAddrController,
              onChanged: _onProxyAddressChanged,
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.only(left: 11),
              child: const Text(
                '关于',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            const AboutWidget(),
          ],
        ),
      ],
    );
  }
}
