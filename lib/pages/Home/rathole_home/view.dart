import 'package:fluent_ui/fluent_ui.dart';
import 'package:unchained/app_constant.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:unchained/classes/log_formatter.dart';
import 'package:unchained/classes/service_config.dart';
import 'package:unchained/pages/home/rathole_home/widgets/action_buttons.dart';
import 'package:unchained/pages/home/rathole_home/widgets/rathole_service_tile.dart';
import 'package:unchained/classes/rathole_config_manager.dart';
import 'package:unchained/widgets/notification.dart';
import 'package:unchained/widgets/terminal.dart';

class RatholeHomePage extends StatefulWidget {
  final String configFileName;
  final ValueChanged<bool> onProcessingChanged;
  const RatholeHomePage({
    super.key,
    required this.configFileName,
    required this.onProcessingChanged,
  });

  @override
  RatholeHomePageState createState() => RatholeHomePageState();
}

class RatholeHomePageState extends State<RatholeHomePage>
    with
        AutomaticKeepAliveClientMixin<RatholeHomePage>,
        SingleTickerProviderStateMixin<RatholeHomePage> {
  final TextEditingController remoteAddrController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<String> formattedLines = [];
  List<RatholeServiceConfig> services = [];
  bool terminalVisible = false;
  bool processing = false;
  Process? _process;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeConfig();
    _initializeAnimations();
  }

  void _initializeConfig() {
    final fullPath =
        '${AppConstant.assetsPath}rathole/${widget.configFileName}';
    RatholeConfigManager.readRatholeConfigFrom(fullPath)
        .then((config) {
          if (!mounted) return;

          remoteAddrController.text = config['remoteAddr'];
          services = config['services'];
          for (var i = 0; i < services.length; i++) {
            _listKey.currentState?.insertItem(i, duration: Duration.zero);
          }
          setState(() {});
        })
        .catchError((error) {
          if (mounted) {
            showBottomNotification(
              context,
              '错误',
              '配置文件读取失败: $error',
              InfoBarSeverity.error,
            );
          }
        });
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {
          processing = false;
          terminalVisible = false;
        });
        widget.onProcessingChanged(false);
      }
    });
  }

  @override
  void dispose() {
    _stdoutSubscription?.cancel();
    _stderrSubscription?.cancel();

    _process?.kill();

    _slideController.dispose();
    remoteAddrController.dispose();

    super.dispose();
  }

  void runCommand(String command) async {
    await _stdoutSubscription?.cancel();
    await _stderrSubscription?.cancel();

    if (!mounted) return;

    setState(() {
      formattedLines.clear();
    });

    try {
      _process = await Process.start('cmd', [
        '/c',
        command,
      ], workingDirectory: "${AppConstant.assetsPath}rathole/");

      _stdoutSubscription = _process!.stdout
          .transform(utf8.decoder)
          .listen(
            (data) {
              if (!mounted) return;

              for (var line in data.split('\n')) {
                if (line.trim().isEmpty) continue;
                final f = LogFormatter.formatLine(line);
                if (mounted) {
                  setState(() => formattedLines.add(f));
                }
              }
            },
            onError: (error) {
              if (mounted) {
                showBottomNotification(
                  context,
                  '错误',
                  '$error',
                  InfoBarSeverity.error,
                );
              }
            },
          );

      _stderrSubscription = _process!.stderr.transform(utf8.decoder).listen((
        data,
      ) {
        if (!mounted) return;

        for (var line in data.split('\n')) {
          if (line.trim().isEmpty) continue;
          final f = LogFormatter.formatLine(line);
          if (mounted) {
            setState(() => formattedLines.add(f));
          }
        }
      });
    } catch (error) {
      if (mounted) {
        showBottomNotification(
          context,
          '错误',
          '启动进程失败: $error',
          InfoBarSeverity.error,
        );
      }
    }
  }

  void addService() {
    if (!mounted) return;

    final newIndex = services.length;
    services.add(RatholeServiceConfig());
    _listKey.currentState?.insertItem(newIndex);
  }

  void _removeService(int index) {
    if (!mounted) return;

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

  void runProcess() {
    processing ? _stopProcess() : _startProcess();
  }

  void _stopProcess() async {
    await _stdoutSubscription?.cancel();
    await _stderrSubscription?.cancel();

    _process?.kill();

    if (mounted) {
      setState(() {
        _slideController.reverse();
      });
      showBottomNotification(
        context,
        '通知',
        '已停止转发服务。',
        InfoBarSeverity.warning,
      );
    }
  }

  void _startProcess() async {
    if (!mounted) return;

    if (remoteAddrController.text.isEmpty) {
      showBottomNotification(
        context,
        '错误',
        '请输入中继服务器地址。',
        InfoBarSeverity.error,
      );
      return;
    }
    if (services.isEmpty) {
      showBottomNotification(context, '错误', '请添加服务。', InfoBarSeverity.error);
      return;
    }

    final fullPath =
        '${AppConstant.assetsPath}rathole/${widget.configFileName}';

    final success = await RatholeConfigManager.saveRatholeConfigTo(
      fullPath,
      remoteAddrController.text.trim(),
      services,
    );

    if (!success) {
      if (mounted) {
        showBottomNotification(
          context,
          '错误',
          '请检查是否所有服务的名称、token、local_addr、retry_interval 都已填写完整。',
          InfoBarSeverity.error,
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        processing = true;
        terminalVisible = true;
      });
      _slideController.forward();
      widget.onProcessingChanged(true);
      runCommand('rathole.exe --client ${widget.configFileName}');
      showBottomNotification(
        context,
        '通知',
        '请查看日志是否出现对应服务的 Control channel established。',
        InfoBarSeverity.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaffoldPage(
      header: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: Text(
          'Rathole客户端',
          style: FluentTheme.of(context).typography.title,
        ),
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
                            onUpdate: () {
                              if (mounted) setState(() {});
                            },
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
              onAddService: addService,
              onToggleProcess: runProcess,
            ),
          ),
        ],
      ),
    );
  }
}
