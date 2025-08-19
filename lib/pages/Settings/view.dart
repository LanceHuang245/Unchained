import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/main.dart';
import 'package:unchained/pages/settings/widgets/about.dart';
import 'package:unchained/pages/settings/widgets/auto_update.dart';
import 'package:unchained/pages/settings/widgets/check_update.dart';
import 'package:unchained/pages/settings/widgets/proxy_settings.dart';
import 'package:unchained/pages/settings/widgets/theme_settings.dart';
import 'package:unchained/utils/theme_color.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  bool autoUpdateChecked = true;
  ThemeMode _currentMode = themeModeNotifier.value;
  final TextEditingController proxyAddrController = TextEditingController();

  // ... 所有 initState 和其他逻辑方法保持不变 ...
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedAutoUpdate = prefs.getBool('auto_update_checked') ?? true;
    final savedProxy = prefs.getString('proxy_addr') ?? '';
    if (mounted) {
      setState(() {
        autoUpdateChecked = loadedAutoUpdate;
        proxyAddrController.text = savedProxy;
        _isLoading = false;
      });
    }
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 使用 ListView 来实现可滚动内容
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text("设置", style: Theme.of(context).textTheme.headlineMedium),
        ),
        ThemeSettingsWidget(
          currentMode: _currentMode,
          onModeChanged: _changeMode,
          currentAccentColor: accentColorNotifier.value,
          onAccentColorChanged: (color) async {
            accentColorNotifier.value = color;
            await saveAccentColor(color);
          },
        ),
        const SizedBox(height: 16),
        AutoUpdateWidget(
          checked: autoUpdateChecked,
          onChanged: _onAutoUpdateChanged,
        ),
        const SizedBox(height: 16),
        CheckUpdateWidget(),
        const SizedBox(height: 16),
        ProxySettingsWidget(
          controller: proxyAddrController,
          onChanged: _onProxyAddressChanged,
        ),
        const SizedBox(height: 24),
        Text('关于', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const AboutWidget(),
      ],
    );
  }
}
