import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/app_constant.dart';
import 'package:unchained/pages/home/rathole_home/view.dart';
import 'package:unchained/utils/rathole_config_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static const String _prefsKey = 'tabsInfo';

  int currentIndex = 0;

  List<Map<String, dynamic>> tabsInfo = [];

  @override
  void initState() {
    super.initState();
    _loadTabsFromPrefs();
  }

  Future<void> _loadTabsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw != null) {
      try {
        final List<dynamic> decoded = json.decode(raw);
        final List<Map<String, dynamic>> loaded = decoded.map((e) {
          return <String, dynamic>{
            'title': e['title'] as String,
            'config': e['config'] as String,
            'key': GlobalKey<RatholeHomePageState>(),
            'processing': false,
          };
        }).toList();

        for (var item in loaded) {
          final configName = item['config'] as String;
          await _ensureConfigFileExists(configName);
        }

        setState(() {
          tabsInfo = loaded;
        });
      } catch (_) {
        await prefs.remove(_prefsKey);
        _createDefaultSingleTab();
      }
    } else {
      _createDefaultSingleTab();
    }
  }

  Future<void> _createDefaultSingleTab() async {
    final Map<String, dynamic> defaultTab = <String, dynamic>{
      'title': 'Rathole 客户端 1',
      'config': 'client_1.toml',
      'key': GlobalKey<RatholeHomePageState>(),
      'processing': false,
    };

    final configName = defaultTab['config'] as String;
    await _ensureConfigFileExists(configName);

    setState(() {
      tabsInfo = [defaultTab];
    });
    await _saveTabsToPrefs();
  }

  Future<void> _saveTabsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, String>> toStore = tabsInfo.map((e) {
      return <String, String>{
        'title': e['title'] as String,
        'config': e['config'] as String,
      };
    }).toList();
    await prefs.setString(_prefsKey, json.encode(toStore));
  }

  Future<void> _ensureConfigFileExists(String configFileName) async {
    try {
      final dirPath = '${AppConstant.assetsPath}rathole/';
      final filePath = '$dirPath$configFileName';
      final file = File(filePath);

      if (!await file.exists()) {
        final dir = Directory(dirPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        RatholeConfigManager.createEmptyTemplate(file);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _deleteConfigFile(String configFileName) async {
    try {
      final filePath = '${AppConstant.assetsPath}rathole/$configFileName';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Tab _buildTab(int index) {
    final info = tabsInfo[index];
    final String title = info['title'] as String;
    final String configName = info['config'] as String;
    final GlobalKey<RatholeHomePageState> pageKey =
        info['key'] as GlobalKey<RatholeHomePageState>;

    final bool isProcessing = pageKey.currentState?.processing ?? false;
    final bool canClose = index != 0 && !isProcessing;

    return Tab(
      text: Text(title),
      icon: const Icon(FluentIcons.cloud),
      body: RatholeHomePage(
        key: pageKey,
        configFileName: configName,
        onProcessingChanged: (bool p) {
          if (!mounted) return;
          setState(() {
            tabsInfo[index]['processing'] = p;
          });
        },
      ),
      onClosed: canClose
          ? () async {
              await _deleteConfigFile(configName);

              setState(() {
                tabsInfo.removeAt(index);
                if (currentIndex >= tabsInfo.length) {
                  currentIndex = tabsInfo.length - 1;
                }
              });

              await _saveTabsToPrefs();
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabView(
      currentIndex: currentIndex,
      onChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      closeButtonVisibility: CloseButtonVisibilityMode.onHover,
      onNewPressed: () async {
        final newIndex = tabsInfo.length + 1;
        final newTitle = 'Rathole 客户端 $newIndex';
        final newConfig = 'client_$newIndex.toml';

        await _ensureConfigFileExists(newConfig);

        setState(() {
          tabsInfo.add(<String, dynamic>{
            'title': newTitle,
            'config': newConfig,
            'key': GlobalKey<RatholeHomePageState>(),
            'processing': false,
          });
          currentIndex = tabsInfo.length - 1;
        });

        await _saveTabsToPrefs();
      },
      tabs: List.generate(tabsInfo.length, (i) => _buildTab(i)),
    );
  }
}
