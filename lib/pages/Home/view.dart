import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import 'dart:convert';
import 'package:toml/toml.dart';
import 'package:unchained/classes/log_formatter.dart';
import 'package:unchained/classes/service_config.dart';
import 'package:unchained/utils/client.dart';
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

  List<String> formattedLines = [];
  List<ServiceConfig> services = [];
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
    _readFile().then((_) {
      for (var i = 0; i < services.length; i++) {
        _listKey.currentState?.insertItem(i, duration: Duration.zero);
      }
    });
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
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _readFile() async {
    final file = File('${Path}client.toml');
    if (!await file.exists()) return;

    final content = await file.readAsString();
    final tomlDocument = TomlDocument.parse(content);
    final tomlMap = tomlDocument.toMap();

    final client = (tomlMap['client'] ?? {}) as Map<String, dynamic>;
    remoteAddrController.text = client['remote_addr'] ?? '';

    final rawServices = client['services'];
    if (rawServices is Map<String, dynamic>) {
      services = rawServices.entries.map((e) {
        final m = e.value as Map<String, dynamic>;
        return ServiceConfig(
          name: e.key,
          token: m['token'] ?? '',
          localAddr: m['local_addr'] ?? '',
          type: m['type'] ?? 'tcp',
          nodelay: m['nodelay'] ?? false,
          retryInterval: (m['retry_interval']?.toString() ?? '1'),
        );
      }).toList();
    } else {
      services = [];
    }

    setState(() {});
  }

  void runCommand(String command) async {
    setState(() {
      formattedLines.clear();
    });

    _process = await Process.start(
      'cmd',
      ['/c', command],
      workingDirectory: '${Path}',
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
    services.add(ServiceConfig());
    _listKey.currentState?.insertItem(
      newIndex,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _removeService(int index) {
    final removed = services.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildServiceTile(removed, index, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  bool _saveConfig() {
    for (var s in services) {
      if (s.nameController.text.isEmpty ||
          s.tokenController.text.isEmpty ||
          s.localAddrController.text.isEmpty) {
        return false;
      }
    }
    final file = File('${Path}client.toml');
    final sb = StringBuffer();
    sb.writeln('# client.toml');
    sb.writeln('[client]');
    sb.writeln('remote_addr = "${remoteAddrController.text}"');
    for (var s in services) {
      final name = s.nameController.text;
      sb.writeln('\n[client.services.$name]');
      final m = s.toMap();
      sb.writeln('token = "${m['token']}"');
      sb.writeln('local_addr = "${m['local_addr']}"');
      sb.writeln('type = "${m['type']}"');
      sb.writeln('nodelay = ${m['nodelay']}');
      sb.writeln('retry_interval = ${m['retry_interval']}');
    }
    file.writeAsStringSync(sb.toString());
    return true;
  }

  Widget _buildServiceTile(
      ServiceConfig s, int i, Animation<double> animation) {
    return SizeTransition(
        sizeFactor: animation,
        axisAlignment: 0.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('服务 ${i + 1}',
                      style: FluentTheme.of(context).typography.subtitle),
                  IconButton(
                    icon: const Icon(FluentIcons.delete),
                    onPressed: processing ? null : () => _removeService(i),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              TextBox(
                enabled: !processing,
                placeholder: '服务名称',
                controller: s.nameController,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextBox(
                      enabled: !processing,
                      placeholder: '本地服务地址与端口',
                      controller: s.localAddrController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ComboBox<String>(
                    value: s.type,
                    items: ['tcp', 'udp']
                        .map((t) => ComboBoxItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged:
                        processing ? null : (v) => setState(() => s.type = v!),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              TextBox(
                enabled: !processing,
                placeholder: 'Token',
                controller: s.tokenController,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Row(
                    children: [
                      ToggleSwitch(
                        checked: s.nodelay,
                        onChanged: processing
                            ? null
                            : (v) => setState(() => s.nodelay = v),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Tooltip(
                          message: '通过降低部分带宽来优化延迟，关闭后带宽提高但延迟增加。',
                          child: Text('延迟优化'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextBox(
                      enabled: !processing,
                      placeholder: '重试间隔',
                      controller: s.retryIntervalController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
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
                          label: '服务端地址',
                          child: TextBox(
                              enabled: !processing,
                              controller: remoteAddrController),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          initialItemCount: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemBuilder: (context, index, animation) {
                            return _buildServiceTile(
                                services[index], index, animation);
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
                    child: processing
                        ? Column(
                            children: [
                              Expanded(
                                child: Terminal(
                                    lines: formattedLines,
                                    visible: terminalVisible),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            Positioned(
                right: 24,
                bottom: 24,
                child: Row(
                  children: [
                    FilledButton(
                        onPressed: processing ? null : _addService,
                        child: const SizedBox(
                          width: 100,
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FluentIcons.add),
                              SizedBox(width: 10),
                              Text("新增服务")
                            ],
                          ),
                        )),
                    const SizedBox(width: 20),
                    FilledButton(
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(processing
                                ? FluentIcons.stop
                                : FluentIcons.play),
                            const SizedBox(width: 10),
                            Text(processing ? "停止" : "运行")
                          ],
                        ),
                      ),
                      onPressed: () {
                        if (processing) {
                          stopCommand();
                          setState(() {
                            processing = false;
                            terminalVisible = false;
                            _slideController.reverse();
                          });
                          showContentDialog(context, '通知', '已停止');
                        } else {
                          if (!_saveConfig()) {
                            showContentDialog(context, '错误', '请检查输入');
                            return;
                          }
                          setState(() {
                            processing = true;
                            terminalVisible = true;
                          });
                          _slideController.forward();
                          runCommand('rathole.exe client.toml');
                          showContentDialog(context, '通知',
                              '请查看日志是否出现对应服务的Control channel established');
                        }
                      },
                    ),
                  ],
                )),
          ],
        ));
  }
}
