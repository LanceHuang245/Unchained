// widgets/navigation.dart

import 'package:flutter/material.dart';
import 'package:unchained/pages/home/view.dart';
import 'package:unchained/pages/settings/view.dart';
import 'package:window_manager/window_manager.dart'; // 【新增】导入 window_manager
import 'package:unchained/classes/rathole_config_manager.dart';

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({super.key});

  @override
  NavigationWidgetState createState() => NavigationWidgetState();
}

// 监听窗口事件
class NavigationWidgetState extends State<NavigationWidget> {
  int _selectedIndex = 0;
  bool _isMaximized = false; // 用于追踪最大化状态

  final List<Widget> _pages = [const HomePage(), const SettingsPage()];

  final Window _window = WindowManager.instance.getCurrent()!;
  late final ListenerId _listenerId;

  @override
  void initState() {
    super.initState();
    _listenerId = _window.addListener(_onWindowEvent); // 添加监听器
    // 检查初始的最大化状态
    _isMaximized = _window.isMaximized;
  }

  @override
  void dispose() {
    _window.removeListener(_listenerId); // 移除监听器
    super.dispose();
  }

  // 在窗口最大化/还原时更新UI
  void _onWindowEvent(WindowEvent event) {
    if (!mounted) return;
    if (event is WindowMaximizedEvent) {
      setState(() => _isMaximized = true);
    } else if (event is WindowRestoredEvent) {
      setState(() => _isMaximized = _window.isMaximized);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                Expanded(
                  child: DragToMoveArea(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/app_icon.ico",
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Unchained",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _WindowControlButton(
                  icon: Icons.minimize,
                  tooltip: '最小化',
                  onPressed: () => _window.minimize(),
                ),
                _WindowControlButton(
                  icon: _isMaximized ? Icons.fullscreen_exit : Icons.fullscreen,
                  tooltip: _isMaximized ? '还原' : '最大化',
                  onPressed: () {
                    if (_window.isMaximized) {
                      _window.unmaximize();
                    } else {
                      _window.maximize();
                    }
                  },
                ),
                _WindowControlButton(
                  icon: Icons.close,
                  tooltip: '关闭',
                  hoverColor: Colors.red,
                  onPressed: () async {
                    await RatholeConfigManager.stopRathole();
                    _window.close();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('主页'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('设置'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: _pages),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? hoverColor;

  const _WindowControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 20,
      hoverColor: hoverColor,
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        minimumSize: WidgetStateProperty.all(const Size(48, 48)),
      ),
    );
  }
}
