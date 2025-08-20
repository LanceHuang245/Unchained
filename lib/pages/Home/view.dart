import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/app_constant.dart';
import 'package:unchained/pages/home/rathole_home/view.dart';
import 'package:unchained/classes/rathole_config_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const String _prefsKey = 'tabsInfo';

  TabController? _tabController;
  List<Map<String, dynamic>> tabsInfo = [];

  @override
  void initState() {
    super.initState();
    _loadTabsFromPrefs();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _updateTabController() {
    _tabController?.dispose();
    _tabController = TabController(
      length: tabsInfo.length,
      vsync: this,
      initialIndex: (tabsInfo.length - 1).clamp(0, tabsInfo.length - 1),
    );
  }

  Future<void> _loadTabsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw != null) {
      try {
        final List<dynamic> decoded = json.decode(raw);
        tabsInfo = decoded.map((e) {
          return <String, dynamic>{
            'title': e['title'] as String,
            'config': e['config'] as String,
            'key': GlobalKey<RatholeHomePageState>(),
          };
        }).toList();

        for (var item in tabsInfo) {
          await _ensureConfigFileExists(item['config'] as String);
        }
      } catch (_) {
        await prefs.remove(_prefsKey);
        await _createDefaultSingleTab();
      }
    } else {
      await _createDefaultSingleTab();
    }

    setState(() {
      _updateTabController();
    });
  }

  Future<void> _createDefaultSingleTab() async {
    final Map<String, dynamic> defaultTab = <String, dynamic>{
      'title': 'Rathole 客户端 1',
      'config': 'client_1.toml',
      'key': GlobalKey<RatholeHomePageState>(),
    };
    await _ensureConfigFileExists(defaultTab['config'] as String);
    tabsInfo = [defaultTab];
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
        await RatholeConfigManager.createEmptyTemplate(file);
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

  void _addNewTab() async {
    final newIndex = tabsInfo.length + 1;
    final newTitle = 'Rathole 客户端 $newIndex';
    final newConfig = 'client_$newIndex.toml';

    await _ensureConfigFileExists(newConfig);

    setState(() {
      tabsInfo.add(<String, dynamic>{
        'title': newTitle,
        'config': newConfig,
        'key': GlobalKey<RatholeHomePageState>(),
      });
      _updateTabController();
    });

    await _saveTabsToPrefs();
  }

  void _closeTab(int index) async {
    final configName = tabsInfo[index]['config'] as String;
    await _deleteConfigFile(configName);

    setState(() {
      tabsInfo.removeAt(index);
      _updateTabController();
    });

    await _saveTabsToPrefs();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rathole 客户端'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: List.generate(tabsInfo.length, (index) {
            final info = tabsInfo[index];
            final bool canClose = index != 0;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_outlined),
                  const SizedBox(width: 8),
                  Text(info['title'] as String),
                  if (canClose) const SizedBox(width: 8),
                  if (canClose)
                    InkWell(
                      onTap: () => _closeTab(index),
                      borderRadius: BorderRadius.circular(12),
                      child: const Icon(Icons.close, size: 16),
                    ),
                ],
              ),
            );
          }),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "新增客户端配置",
            onPressed: _addNewTab,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabsInfo.map((info) {
          return RatholeHomePage(
            key: info['key'] as GlobalKey<RatholeHomePageState>,
            configFileName: info['config'] as String,
          );
        }).toList(),
      ),
    );
  }
}
