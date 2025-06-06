import 'package:fluent_ui/fluent_ui.dart';
import 'package:unchained/app_constant.dart';
import 'dart:io';
import 'dart:convert';
import 'package:unchained/classes/log_formatter.dart';
import 'package:unchained/classes/service_config.dart';
import 'package:unchained/pages/Home/widgets/action_buttons.dart';
import 'package:unchained/pages/Home/widgets/rathole_service_tile.dart';
import 'package:unchained/utils/client.dart';
import 'package:unchained/utils/config_manager.dart';
import 'package:unchained/widgets/notification.dart';
import 'package:unchained/widgets/terminal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with
        AutomaticKeepAliveClientMixin<HomePage>,
        SingleTickerProviderStateMixin<HomePage> {
  final TextEditingController remoteAddrController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();

  List<String> formattedLines = [];
  List<RatholeServiceConfig> services = [];
  bool terminalVisible = false;
  bool processing = false;
  Process? _process;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeConfig();
    _initializeAnimations();
  }

  void _initializeConfig() {
    ConfigManager.readRatholeConfig().then((config) {
      remoteAddrController.text = config['remoteAddr'];
      services = config['services'];
      for (var i = 0; i < services.length; i++) {
        _listKey.currentState?.insertItem(i, duration: Duration.zero);
      }
      setState(() {});
    });
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          processing = false;
          terminalVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void runCommand(String command) async {
    setState(() {
      formattedLines.clear();
    });

    _process = await Process.start(
      'cmd',
      ['/c', command],
      workingDirectory: AppConstant.assetsPath,
    );
    _process!.stdout.transform(utf8.decoder).listen((data) {
      for (var line in data.split('\n')) {
        if (line.trim().isEmpty) continue;
        final f = LogFormatter.formatLine(line);
        setState(() => formattedLines.add(f));
      }
    });
    _process!.stderr.transform(utf8.decoder).listen((data) {
      for (var line in data.split('\n')) {
        if (line.trim().isEmpty) continue;
        final f = LogFormatter.formatLine(line);
        setState(() => formattedLines.add(f));
      }
    });

    await _process!.exitCode;
  }

  void _addService() {
    final newIndex = services.length;
    services.add(RatholeServiceConfig());
    _listKey.currentState?.insertItem(newIndex);
  }

  void _removeService(int index) {
    final removed = services.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => RatholeServiceTile(
        service: removed,
        index: index,
        animation: animation,
        processing: processing,
        onDelete: () {},
        onUpdate: () {},
      ),
      duration: const Duration(milliseconds: 150),
    );
  }

  void _handleToggleProcess() {
    if (processing) {
      _stopProcess();
    } else {
      _startProcess();
    }
  }

  void _stopProcess() {
    stopRathole();
    setState(() {
      _slideController.reverse();
    });
    showBottomNotification(context, '通知', '已停止转发服务。', InfoBarSeverity.warning);
  }

  void _startProcess() {
    if (!ConfigManager.saveRatholeConfig(remoteAddrController.text, services)) {
      showBottomNotification(
          context, '错误', '请检查输入内容是否为空。', InfoBarSeverity.error);
      return;
    }
    setState(() {
      processing = true;
      terminalVisible = true;
    });
    _slideController.forward();
    runCommand('rathole.exe client.toml');
    showBottomNotification(context, '通知',
        '请查看日志是否出现对应服务的Control channel established。', InfoBarSeverity.success);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaffoldPage(
      header: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('客户端配置', style: FluentTheme.of(context).typography.title),
      ),
      content: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InfoLabel(
                        label: '中继服务器地址',
                        child: TextBox(
                          enabled: !processing,
                          controller: remoteAddrController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: AnimatedList(
                        key: _listKey,
                        initialItemCount: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, index, animation) {
                          return RatholeServiceTile(
                            service: services[index],
                            index: index,
                            animation: animation,
                            processing: processing,
                            onDelete: () => _removeService(index),
                            onUpdate: () => setState(() {}),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Terminal(
                          lines: formattedLines,
                          visible: terminalVisible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: ActionButtons(
              processing: processing,
              onAddService: _addService,
              onToggleProcess: _handleToggleProcess,
            ),
          ),
        ],
      ),
    );
  }
}
